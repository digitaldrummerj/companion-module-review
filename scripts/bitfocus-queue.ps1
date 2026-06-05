#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Shows the BitFocus pending review queue, sorted oldest-first by submission date,
    annotated with local review state so already-reviewed work isn't recommended again.
    Read-only — never clones anything.
.DESCRIPTION
    Fetches the pending review list from the BitFocus developer portal API,
    cross-references the workspace for already-cloned modules AND the local
    reviews/ + TRACKER.md for review state, and prints a ranked table sorted by
    how long each version has been waiting.

    "createdAt" is the per-version submission date (epoch ms) — the date that
    specific gitTag was submitted for review, not the module's original creation date.

    The online queue only drops a module once feedback is uploaded to the portal,
    so a module can be reviewed locally but still appear here. Each row is labeled:
      needs review                 — not yet reviewed locally
      reviewed - feedback pending  — reviewed, feedback not yet submitted (hidden from "Next up")
      re-review?                   — previously reviewed AND submitted, back in the queue (re-push)

    Status validation (PENDING vs WITHDRAWN) happens in bitfocus-setup-module.ps1
    before any action is taken.
.PARAMETER Json
    Emit the annotated queue as JSON (no console formatting) for automation.
.EXAMPLE
    pwsh scripts/bitfocus-queue.ps1
    pwsh scripts/bitfocus-queue.ps1 -Json | ConvertFrom-Json
#>

param(
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/lib/ReviewState.ps1"

$workspace  = Split-Path -Parent $PSScriptRoot
$modulesDir = Resolve-ModulesDir $workspace
$reviewsDir = Resolve-ReviewsDir $workspace
$trackerPath = Join-Path $reviewsDir "TRACKER.md"

$token = gh auth token

if (-not $token) {
    Write-Error "Could not get GitHub token. Run: gh auth login"
    exit 1
}

$headers = @{ Authorization = "Bearer $token" }

if (-not $Json) { Write-Host "Fetching pending reviews from BitFocus..." -ForegroundColor DarkGray }

$data = Invoke-RestMethod `
    -Uri "https://developer.bitfocus.io/api/v1/modules-pending-review" `
    -Headers $headers

$versions = @($data.versions | Sort-Object createdAt)

if (-not $versions -or $versions.Count -eq 0) {
    if ($Json) { '[]' } else { Write-Host "No pending reviews found." -ForegroundColor Green }
    exit 0
}

# Parse TRACKER.md once for the whole queue.
$trackerRows = @(Get-TrackerRows -TrackerPath $trackerPath)
$now = [DateTimeOffset]::UtcNow

# Enrich each version with days-waiting, clone status, and local review state.
$rows = foreach ($v in $versions) {
    $submitted = [DateTimeOffset]::FromUnixTimeMilliseconds($v.createdAt)
    $days      = [math]::Floor(($now - $submitted).TotalDays)
    $clonePath = Join-Path $modulesDir "companion-module-$($v.moduleName)"
    $state     = Get-ReviewState -ReviewsDir $reviewsDir -TrackerPath $trackerPath `
                    -ModuleName $v.moduleName -GitTag $v.gitTag -TrackerRows $trackerRows

    [pscustomobject]@{
        moduleName     = $v.moduleName
        gitTag         = $v.gitTag
        daysWaiting    = $days
        cloned         = Test-Path $clonePath
        state          = $state.State
        reviewFiles    = $state.ReviewFiles
        lastReviewDate = $state.LastReviewDate
    }
}
$rows = @($rows)

if ($Json) {
    $rows | ConvertTo-Json -Depth 5
    exit 0
}

# "Next up": oldest needs-review, else oldest re-review; never feedback-pending.
$nextUp = $rows | Where-Object { $_.state -eq 'needs-review' } | Select-Object -First 1
if (-not $nextUp) { $nextUp = $rows | Where-Object { $_.state -eq 're-review' } | Select-Object -First 1 }
$pendingCount = @($rows | Where-Object { $_.state -eq 'feedback-pending' }).Count

Write-Host ""
Write-Host "Pending Reviews — $($rows.Count) total, oldest first" -ForegroundColor Cyan
Write-Host ("─" * 78)

$rank = 1
foreach ($r in $rows) {
    $clone = if ($r.cloned) { "cloned" } else { "not cloned" }
    $label = Get-ReviewStateLabel $r.state
    $color = switch ($r.state) {
        'needs-review'     { 'Gray' }
        'feedback-pending' { 'DarkYellow' }
        're-review'        { 'Magenta' }
        default            { 'Gray' }
    }
    $rankLabel = "$rank.".PadRight(4)
    Write-Host ("$rankLabel $($r.moduleName) @ $($r.gitTag)  |  $($r.daysWaiting) days  |  $clone  |  ") -NoNewline
    Write-Host $label -ForegroundColor $color
    $rank++
}

Write-Host ("─" * 78)
if ($pendingCount -gt 0) {
    Write-Host "$pendingCount already reviewed, feedback pending — hidden from Next up" -ForegroundColor DarkYellow
}
Write-Host ""
if ($nextUp) {
    $suffix = if ($nextUp.state -eq 're-review') { "  (re-review — previously submitted)" } else { "" }
    Write-Host "Next up: $($nextUp.moduleName) @ $($nextUp.gitTag)$suffix" -ForegroundColor Yellow
    Write-Host "To set up:  pwsh scripts/bitfocus-setup-module.ps1" -ForegroundColor DarkGray
    Write-Host "            pwsh scripts/bitfocus-setup-module.ps1 -ModuleName <name>" -ForegroundColor DarkGray
} else {
    Write-Host "Nothing to review — every pending module is reviewed with feedback still to send." -ForegroundColor Green
}
Write-Host ""
