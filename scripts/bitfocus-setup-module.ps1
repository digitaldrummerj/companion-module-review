#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Prepares a BitFocus module for review: validates PENDING status, looks up tags, and clones if needed.
.DESCRIPTION
    If -ModuleName is not provided, automatically selects the oldest pending module from the queue
    that still needs review — skipping any that are already reviewed locally but whose feedback
    hasn't been submitted yet (those remain in the online queue but must not be reviewed twice).

    Steps performed:
      1. Fetch the pending queue from BitFocus API
      2. Resolve the target (auto-select oldest reviewable, or the named module)
      3. Guard against re-reviewing an already-reviewed module (see -Force)
      4. Verify the target version has status PENDING (not WITHDRAWN or other)
      5. Look up the previous approved tag for diff context
      6. Clone the GitHub repo into the workspace if not already present
      7. Print a summary for the Coordinator to hand off to the review team

    "createdAt" sorting uses the per-version submission date (epoch ms) from
    /modules-pending-review — not the module's original creation date.
.PARAMETER ModuleName
    Optional. The module name without the "companion-module-" prefix (e.g. "allenheath-sq").
    If omitted, the oldest reviewable pending module is selected automatically.
.PARAMETER ReviewTag
    Optional. The specific pending version/tag to review (e.g. "v2.1.0" or "2.1.0"). Requires
    -ModuleName. When a module has more than one version pending, this selects which one; without
    it, the oldest pending version is used. Errors (listing the pending versions) if the requested
    version is not pending review for that module.
.PARAMETER Force
    Required to set up a module that is already reviewed locally with feedback still pending.
    Without it, such a module is refused (auto-select skips it; explicit -ModuleName errors out).
.PARAMETER Json
    Emit the coordinator summary as JSON instead of the console banner.
.EXAMPLE
    pwsh scripts/bitfocus-setup-module.ps1
    pwsh scripts/bitfocus-setup-module.ps1 -ModuleName allenheath-sq
    pwsh scripts/bitfocus-setup-module.ps1 -ModuleName allenheath-sq -ReviewTag v2.1.0
    pwsh scripts/bitfocus-setup-module.ps1 -ModuleName allenheath-sq -Force
#>

param(
    [string]$ModuleName,
    [string]$ReviewTag,
    [switch]$Force,
    [switch]$Json
)

if ($ReviewTag -and -not $ModuleName) {
    Write-Error "-ReviewTag requires -ModuleName (a version can only be chosen for a named module)."
    exit 1
}

$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/lib/ReviewState.ps1"

$workspace   = Split-Path -Parent $PSScriptRoot
$modulesDir  = Resolve-ModulesDir $workspace
$reviewsDir  = Resolve-ReviewsDir $workspace
$trackerPath = Join-Path $reviewsDir "TRACKER.md"
$baseUrl     = "https://developer.bitfocus.io/api/v1"
$token       = gh auth token

if (-not $token) {
    Write-Error "Could not get GitHub token. Run: gh auth login"
    exit 1
}

$headers = @{ Authorization = "Bearer $token" }

function Write-Status {
    param([string]$Message, [string]$Color = 'DarkGray')
    if (-not $Json) { Write-Host $Message -ForegroundColor $Color }
}

# ── Step 1: Fetch the pending queue ──────────────────────────────────────────

Write-Status "Fetching pending queue..."

$queueData = Invoke-RestMethod -Uri "$baseUrl/modules-pending-review" -Headers $headers
$queue = @($queueData.versions | Sort-Object createdAt)

if (-not $queue -or $queue.Count -eq 0) {
    Write-Status "No pending reviews found." 'Green'
    exit 0
}

$trackerRows = @(Get-TrackerRows -TrackerPath $trackerPath)

function Get-EntryState {
    param($Entry)
    Get-ReviewState -ReviewsDir $reviewsDir -TrackerPath $trackerPath `
        -ModuleName $Entry.moduleName -GitTag $Entry.gitTag -TrackerRows $trackerRows
}

# ── Step 2: Resolve the target module + Step 3: guard against re-review ───────

if ($ModuleName) {
    $candidates = @($queue | Where-Object { $_.moduleName -eq $ModuleName })
    if ($candidates.Count -eq 0) {
        Write-Error "Module '$ModuleName' not found in the pending queue."
        exit 1
    }

    if ($ReviewTag) {
        $normWanted = ConvertTo-NormalizedTag $ReviewTag
        $target = $candidates | Where-Object { (ConvertTo-NormalizedTag $_.gitTag) -eq $normWanted } | Select-Object -First 1
        if (-not $target) {
            $available = ($candidates | ForEach-Object { $_.gitTag }) -join ', '
            Write-Error "Version '$ReviewTag' is not pending review for '$ModuleName'. Pending versions: $available"
            exit 1
        }
    } else {
        # No version specified — oldest pending (queue is sorted createdAt ascending).
        $target = $candidates | Select-Object -First 1
    }

    $state = Get-EntryState $target
    if ($state.State -eq 'feedback-pending' -and -not $Force) {
        Write-Error ("Module '$ModuleName' @ $($target.gitTag) was already reviewed on $($state.LastReviewDate), " +
            "feedback not yet submitted. Re-run with -Force to review it again.")
        exit 1
    }
    if ($state.State -eq 'feedback-pending' -and $Force) {
        Write-Status "Re-reviewing despite pending feedback (-Force)." 'Yellow'
    }
    if ($state.State -eq 're-review') {
        Write-Status "Note: previously reviewed and submitted — this is a re-review of a re-pushed tag." 'Magenta'
    }
} else {
    # Auto-select: oldest needs-review, else oldest re-review; skip feedback-pending.
    $skipped = 0
    $target = $null
    foreach ($entry in $queue) {
        $s = Get-EntryState $entry
        if ($s.State -eq 'feedback-pending') { $skipped++; continue }
        if ($s.State -eq 'needs-review') { $target = $entry; break }
    }
    if (-not $target) {
        # No fresh work — fall back to the oldest re-review.
        foreach ($entry in $queue) {
            $s = Get-EntryState $entry
            if ($s.State -eq 're-review') {
                $target = $entry
                Write-Status "No un-reviewed modules — selecting oldest re-review." 'Magenta'
                break
            }
        }
    }
    if (-not $target) {
        Write-Status "Nothing to set up — every pending module is reviewed with feedback still to send." 'Green'
        exit 0
    }
    if ($skipped -gt 0) {
        Write-Status "Skipped $skipped already-reviewed (feedback pending) module(s) during auto-select." 'DarkYellow'
    }
    Write-Status "Auto-selected: $($target.moduleName)"
}

$pendingTag = $target.gitTag
$name       = $target.moduleName

Write-Status "Target: $name @ $pendingTag" 'Cyan'

# ── Step 4: Verify status is PENDING ─────────────────────────────────────────

Write-Status "Verifying status..."

$versionsData = Invoke-RestMethod `
    -Uri "$baseUrl/public/modules/companion-connection/$name/versions" `
    -Headers $headers

$normalizedPending = ConvertTo-NormalizedTag $pendingTag

$versionEntry = $versionsData.versions | Where-Object {
    (ConvertTo-NormalizedTag $_.gitTag) -eq $normalizedPending
} | Select-Object -First 1

if (-not $versionEntry) {
    Write-Error "Could not find version entry for $name @ $pendingTag in the versions list."
    exit 1
}

if ($versionEntry.status -ne 'PENDING') {
    Write-Error "Version $name @ $pendingTag has status '$($versionEntry.status)', not PENDING. Skipping."
    exit 1
}

Write-Status "Status confirmed: PENDING" 'Green'

# ── Step 5: Find previous approved tag ───────────────────────────────────────

$previousTag = $versionsData.versions |
    Where-Object { $_.status -eq 'APPROVED' } |
    Sort-Object createdAt -Descending |
    Select-Object -First 1 -ExpandProperty gitTag

if (-not $previousTag) {
    $previousTag = '(none — first release)'
    Write-Status "No previous approved tag found — treat as first release." 'Yellow'
} else {
    Write-Status "Previous approved tag: $previousTag"
}

# ── Step 6: Clone if not already present ─────────────────────────────────────

$cloneDir = Join-Path $modulesDir "companion-module-$name"

if (Test-Path $cloneDir) {
    Write-Status "Already cloned at: $cloneDir"
} else {
    $repoUrl = "https://github.com/bitfocus/companion-module-$name"
    Write-Status "Cloning $repoUrl ..."
    git clone $repoUrl $cloneDir
    Write-Status "Cloned to: $cloneDir" 'Green'
}

# ── Step 6b: Check out the exact review tag ──────────────────────────────────
# Review the version actually being submitted (not whatever the default branch is at).
Write-Status "Checking out $pendingTag ..."
git -C $cloneDir fetch --tags --quiet
git -C $cloneDir checkout --quiet $pendingTag
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to check out tag '$pendingTag' in $cloneDir."
    exit 1
}
Write-Status "Checked out: $pendingTag" 'Green'

# ── Step 7: Print coordinator summary ────────────────────────────────────────

if ($Json) {
    [pscustomobject]@{
        module      = $name
        reviewTag   = $pendingTag
        previousTag = $previousTag
        directory   = $cloneDir
    } | ConvertTo-Json
    exit 0
}

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
