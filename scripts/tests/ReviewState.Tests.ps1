#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Self-contained tests for scripts/lib/ReviewState.ps1 — no Pester required.
.DESCRIPTION
    Builds an isolated fixture (temp reviews/ + TRACKER.md + fake review files),
    exercises Get-TrackerRows / Get-ReviewState across every state and the known
    edge cases, and exits non-zero on any failure.

    Run:  pwsh scripts/tests/ReviewState.Tests.ps1
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../lib/ReviewState.ps1"

$script:pass = 0
$script:fail = 0

function Assert-Equal {
    param($Expected, $Actual, [string]$Because)
    if ($Expected -eq $Actual) {
        $script:pass++
        Write-Host "  PASS  $Because" -ForegroundColor Green
    } else {
        $script:fail++
        Write-Host "  FAIL  $Because (expected '$Expected', got '$Actual')" -ForegroundColor Red
    }
}

# ── Build fixture ────────────────────────────────────────────────────────────
$root = Join-Path ([System.IO.Path]::GetTempPath()) "reviewstate-test-$([System.IO.Path]::GetRandomFileName())"
$reviews = Join-Path $root "reviews"
$tracker = Join-Path $reviews "TRACKER.md"

function New-ReviewFile {
    param([string]$Module, [string]$Tag, [string]$Stamp)
    $dir = Join-Path $reviews $Module
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    New-Item -ItemType File -Path (Join-Path $dir "review-$Module-$Tag-$Stamp.md") -Force | Out-Null
}

try {
    New-Item -ItemType Directory -Path $reviews -Force | Out-Null

    # Review files
    New-ReviewFile 'alpha-mod'   'v1.0.0'  '20260101-000000'   # + submitted row  => re-review
    New-ReviewFile 'beta-mod'    'v2.0.0'  '20260201-000000'   # + unsubmitted row => feedback-pending
    New-ReviewFile 'gamma-mod'   'v1.0.0'  '20260301-000000'   # + two submitted rows => re-review
    New-ReviewFile 'epsilon-mod' 'v3.0.0'  '20260401-000000'   # file only, no row => feedback-pending
    New-ReviewFile 'zeta-mod'    'v1.0.0'  '20260501-000000'   # prefix-collision pair
    New-ReviewFile 'zeta-mod'    'v1.0.10' '20260502-000000'

    @'
# Module Review Tracker

| Feedback Submitted | Module | Version | Review Date | Review File |
|:-----------------:|--------|---------|-------------|-------------|
| ✅ | alpha-mod | v1.0.0 | 2026-01-01 | [review](alpha-mod/review-alpha-mod-v1.0.0-20260101-000000.md) |
| ⬜ | beta-mod | v2.0.0 | 2026-02-01 | [review](beta-mod/review-beta-mod-v2.0.0-20260201-000000.md) |
| ✅ | gamma-mod | v1.0.0 | 2026-03-01 | [review](gamma-mod/review-gamma-mod-v1.0.0-20260301-000000.md) |
| ✅ | gamma-mod | v1.0.0 | 2026-03-15 | [review](gamma-mod/review-gamma-mod-v1.0.0-20260315-000000.md) |
| ✅ | delta-mod | v1.2.1 | 2026-04-20 | published.  manual review. |
'@ | Set-Content -LiteralPath $tracker -Encoding utf8

    # ── Tests ────────────────────────────────────────────────────────────────
    Write-Host "Get-TrackerRows"
    $rows = @(Get-TrackerRows -TrackerPath $tracker)
    Assert-Equal 5 $rows.Count "parses 5 data rows (skips header + separator)"
    Assert-Equal $true ($rows | Where-Object { $_.Module -eq 'alpha-mod' }).Submitted "alpha-mod row is submitted"
    Assert-Equal $false ($rows | Where-Object { $_.Module -eq 'beta-mod' }).Submitted "beta-mod row is not submitted"
    Assert-Equal 'delta-mod' ($rows | Where-Object { $_.Version -eq 'v1.2.1' }).Module "freeform-cell row still parses"

    Write-Host "Get-ReviewState"
    function State($m, $t) {
        (Get-ReviewState -ReviewsDir $reviews -TrackerPath $tracker -ModuleName $m -GitTag $t -TrackerRows $rows)
    }

    Assert-Equal 're-review'        (State 'alpha-mod'   'v1.0.0').State  "alpha: file + submitted => re-review"
    Assert-Equal 're-review'        (State 'alpha-mod'   '1.0.0' ).State  "alpha: v-insensitive match"
    Assert-Equal 'feedback-pending' (State 'beta-mod'    'v2.0.0').State  "beta: file + unsubmitted => feedback-pending"
    Assert-Equal 're-review'        (State 'gamma-mod'   'v1.0.0').State  "gamma: two submitted rows => re-review"
    Assert-Equal 'feedback-pending' (State 'epsilon-mod' 'v3.0.0').State  "epsilon: file only, no row => feedback-pending"
    Assert-Equal 're-review'        (State 'delta-mod'   'v1.2.1').State  "delta: submitted row, no file => re-review"
    Assert-Equal 'needs-review'     (State 'omega-mod'   'v9.9.9').State  "omega: unknown => needs-review"
    Assert-Equal 'needs-review'     (State 'beta-mod'    'v9.9.9').State  "beta unknown tag => needs-review"

    # Prefix collision: v1.0.0 must not match v1.0.10
    Assert-Equal 1 (State 'zeta-mod' 'v1.0.0' ).ReviewFiles.Count "zeta v1.0.0 matches exactly 1 file"
    Assert-Equal 1 (State 'zeta-mod' 'v1.0.10').ReviewFiles.Count "zeta v1.0.10 matches exactly 1 file"

    # TrackerSubmitted nullability
    Assert-Equal $null (State 'epsilon-mod' 'v3.0.0').TrackerSubmitted "epsilon: no row => TrackerSubmitted null"
    Assert-Equal $false (State 'beta-mod' 'v2.0.0').TrackerSubmitted "beta: unsubmitted row => TrackerSubmitted false"
}
finally {
    if (Test-Path $root) { Remove-Item -Recurse -Force $root }
}

Write-Host ""
Write-Host "$($script:pass) passed, $($script:fail) failed" -ForegroundColor ($(if ($script:fail) { 'Red' } else { 'Green' }))
if ($script:fail) { exit 1 }
