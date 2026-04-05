#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Prepares a BitFocus module for review: validates PENDING status, looks up tags, and clones if needed.
.DESCRIPTION
    If -ModuleName is not provided, automatically selects the oldest PENDING module from the queue.

    Steps performed:
      1. Fetch the pending queue from BitFocus API
      2. Verify the target version has status PENDING (not WITHDRAWN or other)
      3. Look up the previous approved tag for diff context
      4. Clone the GitHub repo into the workspace if not already present
      5. Print a summary for the Coordinator to hand off to the review team

    "createdAt" sorting uses the per-version submission date (epoch ms) from
    /modules-pending-review — not the module's original creation date.
.PARAMETER ModuleName
    Optional. The module name without the "companion-module-" prefix (e.g. "allenheath-sq").
    If omitted, the oldest pending module is selected automatically.
.EXAMPLE
    pwsh scripts/bitfocus-setup-module.ps1
    pwsh scripts/bitfocus-setup-module.ps1 -ModuleName allenheath-sq
#>

param(
    [string]$ModuleName
)

$ErrorActionPreference = 'Stop'

$workspace   = Split-Path -Parent $PSScriptRoot
$modulesDir  = if ($env:COMPANION_MODULES_DIR) { $env:COMPANION_MODULES_DIR } else { Join-Path (Split-Path -Parent $workspace) "companion-modules-reviewing" }
$baseUrl     = "https://developer.bitfocus.io/api/v1"
$token      = gh auth token

if (-not $token) {
    Write-Error "Could not get GitHub token. Run: gh auth login"
    exit 1
}

$headers = @{ Authorization = "Bearer $token" }

# ── Step 1: Fetch the pending queue ──────────────────────────────────────────

Write-Host "Fetching pending queue..." -ForegroundColor DarkGray

$queueData = Invoke-RestMethod `
    -Uri "$baseUrl/modules-pending-review" `
    -Headers $headers

$queue = $queueData.versions | Sort-Object createdAt

if (-not $queue -or $queue.Count -eq 0) {
    Write-Host "No pending reviews found." -ForegroundColor Green
    exit 0
}

# ── Step 2: Resolve the target module ────────────────────────────────────────

if ($ModuleName) {
    $target = $queue | Where-Object { $_.moduleName -eq $ModuleName } | Select-Object -First 1
    if (-not $target) {
        Write-Error "Module '$ModuleName' not found in the pending queue."
        exit 1
    }
} else {
    $target = $queue[0]
    Write-Host "No module specified — auto-selecting oldest pending: $($target.moduleName)" -ForegroundColor DarkGray
}

$pendingTag = $target.gitTag
$name       = $target.moduleName

Write-Host "Target: $name @ $pendingTag" -ForegroundColor Cyan

# ── Step 3: Verify status is PENDING ─────────────────────────────────────────

Write-Host "Verifying status..." -ForegroundColor DarkGray

$versionsData = Invoke-RestMethod `
    -Uri "$baseUrl/public/modules/companion-connection/$name/versions" `
    -Headers $headers

# Normalize tags for comparison (strip leading "v" for matching)
$normalizedPending = $pendingTag -replace '^v', ''

$versionEntry = $versionsData.versions | Where-Object {
    ($_.gitTag -replace '^v', '') -eq $normalizedPending
} | Select-Object -First 1

if (-not $versionEntry) {
    Write-Error "Could not find version entry for $name @ $pendingTag in the versions list."
    exit 1
}

if ($versionEntry.status -ne 'PENDING') {
    Write-Error "Version $name @ $pendingTag has status '$($versionEntry.status)', not PENDING. Skipping."
    exit 1
}

Write-Host "Status confirmed: PENDING" -ForegroundColor Green

# ── Step 4: Find previous approved tag ───────────────────────────────────────

$previousTag = $versionsData.versions |
    Where-Object { $_.status -eq 'APPROVED' } |
    Sort-Object createdAt -Descending |
    Select-Object -First 1 -ExpandProperty gitTag

if (-not $previousTag) {
    $previousTag = '(none — first release)'
    Write-Host "No previous approved tag found — treat as first release." -ForegroundColor Yellow
} else {
    Write-Host "Previous approved tag: $previousTag" -ForegroundColor DarkGray
}

# ── Step 5: Clone if not already present ─────────────────────────────────────

$cloneDir = Join-Path $modulesDir "companion-module-$name"

if (Test-Path $cloneDir) {
    Write-Host "Already cloned at: $cloneDir" -ForegroundColor DarkGray
} else {
    $repoUrl = "https://github.com/bitfocus/companion-module-$name"
    Write-Host "Cloning $repoUrl ..." -ForegroundColor DarkGray
    git clone $repoUrl $cloneDir
    Write-Host "Cloned to: $cloneDir" -ForegroundColor Green
}

# ── Step 6: Print coordinator summary ────────────────────────────────────────

Write-Host ""
Write-Host ("─" * 60)
Write-Host "Ready for review" -ForegroundColor Green
Write-Host ("─" * 60)
Write-Host "Module:        $name"
Write-Host "Review tag:    $pendingTag"
Write-Host "Previous tag:  $previousTag"
Write-Host "Directory:     $cloneDir"
Write-Host ("─" * 60)
Write-Host ""
