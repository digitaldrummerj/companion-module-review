#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Run every test suite in scripts/tests/ and report a combined result.
.DESCRIPTION
    Each suite is self-contained (no Pester) and exits non-zero on failure, so this just
    runs them in child processes and adds up the outcomes. Suites are discovered by
    filename, so a new *.Tests.ps1 is picked up without editing this script.

    Everything here is hermetic — the template-freshness tests build local git repos and
    clone between them rather than touching GitHub.
.PARAMETER Quiet
    Print only each suite's summary line, not its individual assertions.
.EXAMPLE
    pwsh scripts/tests/run-all.ps1
    pwsh scripts/tests/run-all.ps1 -Quiet
#>

param([switch]$Quiet)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$suites = @(Get-ChildItem -LiteralPath $PSScriptRoot -Filter '*.Tests.ps1' -File | Sort-Object Name)
if ($suites.Count -eq 0) { Write-Error "No *.Tests.ps1 suites found in $PSScriptRoot"; exit 2 }

$results = [System.Collections.Generic.List[object]]::new()
foreach ($s in $suites) {
    Write-Host ""
    Write-Host "=== $($s.Name) ===" -ForegroundColor Cyan
    $output = & pwsh -NoProfile -File $s.FullName 2>&1
    $code = $LASTEXITCODE

    $summary = @($output | Where-Object { $_ -match '^\d+ passed, \d+ failed$' } | Select-Object -Last 1)
    $passed = 0; $failed = 0
    if ($summary.Count -gt 0 -and "$($summary[0])" -match '^(\d+) passed, (\d+) failed$') {
        $passed = [int]$Matches[1]; $failed = [int]$Matches[2]
    }

    if ($Quiet) {
        # Still surface failures — a quiet run that hides which assertion broke is useless.
        # -cmatch, anchored: PowerShell's -match is case-insensitive, so a plain 'FAIL' also
        # matches the "0 failed" summary line.
        $output | Where-Object { $_ -cmatch '^\s*FAIL\s' } | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        Write-Host ("  {0} passed, {1} failed" -f $passed, $failed) -ForegroundColor ($(if ($failed -or $code -ne 0) { 'Red' } else { 'Green' }))
    } else {
        $output | ForEach-Object { Write-Host $_ }
    }

    $results.Add([pscustomobject]@{ Name = $s.Name; Passed = $passed; Failed = $failed; ExitCode = $code })
}

$totalPassed = ($results | Measure-Object -Property Passed -Sum).Sum
$totalFailed = ($results | Measure-Object -Property Failed -Sum).Sum
$broken = @($results | Where-Object { $_.ExitCode -ne 0 -and $_.Failed -eq 0 })

Write-Host ""
Write-Host ("─" * 64)
foreach ($r in $results) {
    $col = if ($r.Failed -gt 0 -or $r.ExitCode -ne 0) { 'Red' } else { 'Green' }
    Write-Host ("  {0,-32} {1,4} passed  {2,4} failed" -f $r.Name, $r.Passed, $r.Failed) -ForegroundColor $col
}
Write-Host ("─" * 64)
Write-Host ("$totalPassed passed, $totalFailed failed") -ForegroundColor ($(if ($totalFailed -or $broken.Count) { 'Red' } else { 'Green' }))
foreach ($r in $broken) {
    Write-Host ("  $($r.Name) exited $($r.ExitCode) without reporting failures — it probably crashed.") -ForegroundColor Red
}
Write-Host ""

exit ($(if ($totalFailed -gt 0 -or $broken.Count -gt 0) { 1 } else { 0 }))
