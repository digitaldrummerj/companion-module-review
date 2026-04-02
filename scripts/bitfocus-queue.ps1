#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Shows the BitFocus pending review queue, sorted oldest-first by submission date.
    Read-only — never clones anything.
.DESCRIPTION
    Fetches the pending review list from the BitFocus developer portal API,
    cross-references the workspace for already-cloned modules, and prints a
    ranked table sorted by how long each version has been waiting for review.

    "createdAt" is the per-version submission date (epoch ms) — the date that
    specific gitTag was submitted for review, not the module's original creation date.

    Status validation (PENDING vs WITHDRAWN) happens in bitfocus-setup-module.ps1
    before any action is taken.
.EXAMPLE
    pwsh scripts/bitfocus-queue.ps1
#>

$ErrorActionPreference = 'Stop'

$workspace = Split-Path -Parent $PSScriptRoot
$token = gh auth token

if (-not $token) {
    Write-Error "Could not get GitHub token. Run: gh auth login"
    exit 1
}

$headers = @{ Authorization = "Bearer $token" }

Write-Host "Fetching pending reviews from BitFocus..." -ForegroundColor DarkGray

$data = Invoke-RestMethod `
    -Uri "https://developer.bitfocus.io/api/v1/modules-pending-review" `
    -Headers $headers

$versions = $data.versions | Sort-Object createdAt

if (-not $versions -or $versions.Count -eq 0) {
    Write-Host "No pending reviews found." -ForegroundColor Green
    exit 0
}

$now = [DateTimeOffset]::UtcNow

Write-Host ""
Write-Host "Pending Reviews — $($versions.Count) total, oldest first" -ForegroundColor Cyan
Write-Host ("─" * 70)

$rank = 1
foreach ($v in $versions) {
    $submitted  = [DateTimeOffset]::FromUnixTimeMilliseconds($v.createdAt)
    $days       = [math]::Floor(($now - $submitted).TotalDays)
    $clonePath  = Join-Path $workspace "companion-module-$($v.moduleName)"
    $cloneLabel = if (Test-Path $clonePath) { "cloned" } else { "not cloned" }
    $rankLabel  = "$rank.".PadRight(4)

    Write-Host "$rankLabel $($v.moduleName) @ $($v.gitTag)  |  $days days waiting  |  $cloneLabel"
    $rank++
}

Write-Host ("─" * 70)
Write-Host ""
Write-Host "Next up: $($versions[0].moduleName) @ $($versions[0].gitTag)" -ForegroundColor Yellow
Write-Host "To set up:  pwsh scripts/bitfocus-setup-module.ps1" -ForegroundColor DarkGray
Write-Host "            pwsh scripts/bitfocus-setup-module.ps1 -ModuleName <name>" -ForegroundColor DarkGray
Write-Host ""
