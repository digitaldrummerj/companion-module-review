#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Move clones of fully signed-off modules into a staging folder for deletion.
.DESCRIPTION
    A clone is eligible when its module has at least one row in reviews/TRACKER.md and
    EVERY row for that module is ✅ (feedback submitted). A single ⬜ row anywhere blocks
    the whole module — that's the "reviewed but feedback pending" state, and a
    resubmission of that tag comes back to us as a re-review.

    Modules with no TRACKER row at all are left alone: they were never reviewed here,
    so the tracker can't say whether they're finished.

    Nothing is deleted. Eligible clones are moved to <modulesDir>/_removed so they can
    be inspected once and removed by hand. Any of them can be re-cloned later by
    bitfocus-setup-module.ps1.

    Dry run by default; pass -Apply to actually move.
.EXAMPLE
    pwsh scripts/archive-reviewed-clones.ps1
    pwsh scripts/archive-reviewed-clones.ps1 -Apply
#>

param(
    # Where to move eligible clones. Defaults to <modulesDir>/_removed.
    [string]$Destination,
    # Without this, the script only reports what it would move.
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/lib/ReviewState.ps1"

$workspace   = Split-Path -Parent $PSScriptRoot
$modulesDir  = Resolve-ModulesDir $workspace
$reviewsDir  = Resolve-ReviewsDir $workspace
$trackerPath = Join-Path $reviewsDir "TRACKER.md"

if (-not $Destination) { $Destination = Join-Path $modulesDir "_removed" }

if (-not (Test-Path $modulesDir)) {
    Write-Host "Modules directory does not exist: $modulesDir"
    return
}

function Get-DirSizeBytes {
    param([Parameter(Mandatory)][string]$Path)
    $files = Get-ChildItem -LiteralPath $Path -Recurse -File -Force -ErrorAction SilentlyContinue
    if (-not $files) { return [int64]0 }
    return [int64](($files | Measure-Object -Property Length -Sum).Sum)
}

function Format-Size {
    param([int64]$Bytes)
    if ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    if ($Bytes -ge 1MB) { return "{0:N0} MB" -f ($Bytes / 1MB) }
    return "{0:N0} KB" -f ($Bytes / 1KB)
}

# --- Work out which modules are fully signed off -----------------------------

$rows = @(Get-TrackerRows -TrackerPath $trackerPath)
if ($rows.Count -eq 0) {
    Write-Error "No rows parsed from $trackerPath — refusing to guess."
    exit 1
}

$signedOff = @(
    $rows | Group-Object Module | Where-Object {
        @($_.Group | Where-Object { -not $_.Submitted }).Count -eq 0
    } | ForEach-Object { $_.Name }
) | Sort-Object

$pending = @(
    $rows | Group-Object Module | Where-Object {
        @($_.Group | Where-Object { -not $_.Submitted }).Count -gt 0
    } | ForEach-Object { $_.Name }
) | Sort-Object

Write-Host "Workspace:   $modulesDir"
Write-Host "Destination: $Destination"
Write-Host "Tracker:     $($rows.Count) rows | $($signedOff.Count) modules fully submitted | $($pending.Count) with a pending row`n"

# --- Map to clones on disk ---------------------------------------------------

$candidates = foreach ($module in $signedOff) {
    $name = "companion-module-$module"
    if ($name -like 'companion-module-template-*') { continue }

    $dir = Join-Path $modulesDir $name
    if (-not (Test-Path -LiteralPath $dir -PathType Container)) { continue }

    $warnings = @()
    if (Test-Path -LiteralPath (Join-Path $dir '.git')) {
        $status = @(git -C $dir status --porcelain 2>$null)

        # Tracked edits are the only thing that could be lost work. Untracked files in
        # these clones are build output (.tgz, yarn.lock, dist/) from validate-template
        # -RunBuild, and node_modules churn comes from `yarn install` in the few modules
        # that commit their dependencies.
        # Porcelain v1 is "XY PATH", so drop the 3-char status prefix before matching paths.
        $tracked = @($status |
            Where-Object { $_ -notmatch '^\?\?' } |
            ForEach-Object { $_.Substring(3) } |
            Where-Object { $_ -notmatch '^node_modules/' })
        if ($tracked.Count -gt 0) {
            $files = ($tracked | Select-Object -First 3) -join ', '
            $more  = if ($tracked.Count -gt 3) { " +$($tracked.Count - 3) more" } else { "" }
            $warnings += "modified: $files$more"
        }

        $stashes = @(git -C $dir stash list 2>$null)
        if ($stashes.Count -gt 0) { $warnings += "$($stashes.Count) stash(es)" }

        # `branch --list` also prints a "(HEAD detached at <tag>)" pseudo-entry — the normal
        # state for a review checkout — so drop it before counting real branches.
        $branches = @(git -C $dir branch --list --format='%(refname:short)' 2>$null |
            Where-Object { $_ -notmatch '^\(HEAD detached' })
        if ($branches.Count -gt 1) { $warnings += "$($branches.Count) local branches: $($branches -join ', ')" }
    } else {
        $warnings += "not a git clone"
    }

    [pscustomobject]@{
        Name     = $name
        Path     = $dir
        Bytes    = Get-DirSizeBytes $dir
        Warnings = $warnings
    }
}
$candidates = @($candidates)

if ($candidates.Count -eq 0) {
    Write-Host "Nothing to archive — no signed-off module has a clone on disk." -ForegroundColor Green
    return
}

foreach ($c in $candidates) {
    $note = if ($c.Warnings.Count -gt 0) { "  ⚠️  $($c.Warnings -join ', ')" } else { "" }
    Write-Host ("  {0,-52} {1,10}{2}" -f $c.Name, (Format-Size $c.Bytes), $note)
}

$total = [int64](($candidates | Measure-Object -Property Bytes -Sum).Sum)
Write-Host "`n  $($candidates.Count) clone(s), $(Format-Size $total)"

$staying = @(Get-ChildItem -Path $modulesDir -Directory -Filter "companion-module-*" |
    Where-Object { $candidates.Name -notcontains $_.Name }) | Sort-Object Name
if ($staying.Count -gt 0) {
    Write-Host "`nStaying (pending feedback, untracked, or a template):" -ForegroundColor DarkGray
    foreach ($s in $staying) {
        $module = $s.Name -replace '^companion-module-', ''
        $why =
            if ($pending -contains $module)              { 'feedback pending' }
            elseif ($s.Name -like 'companion-module-template-*') { 'template' }
            else                                          { 'no tracker row' }
        Write-Host ("  {0,-52} {1}" -f $s.Name, $why) -ForegroundColor DarkGray
    }
}

if (-not $Apply) {
    Write-Host "`nDry run — nothing moved. Re-run with -Apply to move them." -ForegroundColor Yellow
    return
}

# --- Move --------------------------------------------------------------------

if (-not (Test-Path -LiteralPath $Destination)) {
    New-Item -ItemType Directory -Path $Destination | Out-Null
}

Write-Host ""
$moved = 0
$skipped = 0
$movedBytes = [int64]0

foreach ($c in $candidates) {
    $target = Join-Path $Destination $c.Name
    if (Test-Path -LiteralPath $target) {
        Write-Host "  ❌ Skipping $($c.Name) — already exists in $Destination" -ForegroundColor Red
        $skipped++
        continue
    }
    Move-Item -LiteralPath $c.Path -Destination $target
    Write-Host "  📦 Moved $($c.Name)"
    $moved++
    $movedBytes += $c.Bytes
}

Write-Host "`nMoved: $moved | Skipped: $skipped | Reclaimable: $(Format-Size $movedBytes)"
Write-Host "Delete when you're happy: rm -rf `"$Destination`""
