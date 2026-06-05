#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Shared helpers for the BitFocus review scripts: workspace path resolution,
    tag normalization, TRACKER.md parsing, and local review-state lookup.
.DESCRIPTION
    Dot-source this file from a script in the scripts/ directory:

        . "$PSScriptRoot/lib/ReviewState.ps1"

    The functions here are the single source of truth for "has this module @ tag
    already been reviewed locally?" — used to keep the queue and setup scripts from
    recommending or re-reviewing work that's already done but whose feedback hasn't
    been uploaded to the developer portal yet.

    Review-state model (see reviews/TRACKER.md):
      needs-review     — no local review file AND no TRACKER row
      feedback-pending — a review file exists but feedback not marked submitted (the protect case)
      re-review        — a review file exists AND a TRACKER row is marked submitted (maintainer
                         re-pushed the same tag after we sent feedback, so it's back in the queue)
#>

Set-StrictMode -Version Latest

# Char that marks "feedback submitted" in the TRACKER.md first column.
$script:SubmittedMark = [char]0x2705   # ✅

function Resolve-ModulesDir {
    <# Resolve the sibling workspace where modules are cloned. Honors COMPANION_MODULES_DIR. #>
    param([Parameter(Mandatory)][string]$RepoRoot)

    if ($env:COMPANION_MODULES_DIR) { return $env:COMPANION_MODULES_DIR }
    return Join-Path (Split-Path -Parent $RepoRoot) "companion-modules-reviewing"
}

function Resolve-ReviewsDir {
    <# Resolve the reviews/ directory inside the review repo. #>
    param([Parameter(Mandatory)][string]$RepoRoot)
    return Join-Path $RepoRoot "reviews"
}

function ConvertTo-NormalizedTag {
    <# Strip a single leading 'v' so 'v2.1.0' and '2.1.0' compare equal. #>
    param([string]$Tag)
    if ($null -eq $Tag) { return '' }
    return ($Tag -replace '^v', '').Trim()
}

function Get-TrackerRows {
    <#
    .SYNOPSIS
        Parse reviews/TRACKER.md into row objects.
    .OUTPUTS
        [pscustomobject] with: Submitted (bool), Module, Version, Date, ReviewFile
        Tolerates freeform Review-File cells (e.g. "published. manual review.").
    #>
    param([Parameter(Mandatory)][string]$TrackerPath)

    if (-not (Test-Path $TrackerPath)) { return @() }

    $rows = foreach ($line in (Get-Content -LiteralPath $TrackerPath)) {
        $trimmed = $line.Trim()
        if (-not $trimmed.StartsWith('|')) { continue }            # not a table row
        if ($trimmed -match '^\|\s*:?-{2,}') { continue }          # separator row |:--|...
        if ($trimmed -match 'Feedback Submitted') { continue }     # header row

        # Split on '|'; outer empties from leading/trailing pipes are dropped by indexing.
        $cells = $trimmed.Trim('|').Split('|') | ForEach-Object { $_.Trim() }
        if ($cells.Count -lt 4) { continue }                       # malformed; skip

        [pscustomobject]@{
            Submitted  = $cells[0].Contains($script:SubmittedMark)
            Module     = $cells[1]
            Version    = $cells[2]
            Date       = $cells[3]
            ReviewFile = if ($cells.Count -ge 5) { $cells[4] } else { '' }
        }
    }
    return @($rows)
}

function Get-ReviewFile {
    <# Return review files under reviews/{Module}/ matching {Module} @ {GitTag} (v-insensitive). #>
    param(
        [Parameter(Mandatory)][string]$ReviewsDir,
        [Parameter(Mandatory)][string]$ModuleName,
        [Parameter(Mandatory)][string]$GitTag
    )

    $moduleDir = Join-Path $ReviewsDir $ModuleName
    if (-not (Test-Path $moduleDir)) { return @() }

    $normTag = ConvertTo-NormalizedTag $GitTag
    # Match both with and without the leading 'v' as written in the filename.
    $patterns = @(
        "review-$ModuleName-v$normTag-*.md",
        "review-$ModuleName-$normTag-*.md"
    )
    $files = foreach ($p in $patterns) {
        Get-ChildItem -LiteralPath $moduleDir -Filter $p -File -ErrorAction SilentlyContinue
    }
    return @($files | Sort-Object FullName -Unique)
}

function Get-ReviewState {
    <#
    .SYNOPSIS
        Determine the local review state for a module @ tag.
    .OUTPUTS
        [pscustomobject] with: State, ReviewFiles[], TrackerSubmitted (bool?), LastReviewDate
    #>
    param(
        [Parameter(Mandatory)][string]$ReviewsDir,
        [Parameter(Mandatory)][string]$TrackerPath,
        [Parameter(Mandatory)][string]$ModuleName,
        [Parameter(Mandatory)][string]$GitTag,
        # Optional pre-parsed rows so callers can parse TRACKER.md once for the whole queue.
        [object[]]$TrackerRows
    )

    $normTag = ConvertTo-NormalizedTag $GitTag

    if ($null -eq $TrackerRows) { $TrackerRows = @(Get-TrackerRows -TrackerPath $TrackerPath) }
    $matchingRows = @($TrackerRows | Where-Object {
        $_.Module -eq $ModuleName -and (ConvertTo-NormalizedTag $_.Version) -eq $normTag
    })

    $files = @(Get-ReviewFile -ReviewsDir $ReviewsDir -ModuleName $ModuleName -GitTag $GitTag)

    $hasReview    = ($files.Count -gt 0) -or ($matchingRows.Count -gt 0)
    $anySubmitted = @($matchingRows | Where-Object { $_.Submitted }).Count -gt 0

    $state =
        if (-not $hasReview)  { 'needs-review' }
        elseif ($anySubmitted) { 're-review' }
        else                   { 'feedback-pending' }

    $trackerSubmitted = if ($matchingRows.Count -eq 0) { $null } else { [bool]$anySubmitted }

    # Latest review date: prefer TRACKER row dates (YYYY-MM-DD sorts lexically), else file mtime.
    $lastDate = $null
    if ($matchingRows.Count -gt 0) {
        $lastDate = ($matchingRows | Sort-Object Date -Descending | Select-Object -First 1).Date
    } elseif ($files.Count -gt 0) {
        $lastDate = ($files | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime.ToString('yyyy-MM-dd')
    }

    return [pscustomobject]@{
        State           = $state
        ReviewFiles     = @($files | ForEach-Object { $_.Name })
        TrackerSubmitted = $trackerSubmitted
        LastReviewDate  = $lastDate
    }
}

function Get-ReviewStateLabel {
    <# Human-readable label for a state value. #>
    param([Parameter(Mandatory)][string]$State)
    switch ($State) {
        'needs-review'     { 'needs review' }
        'feedback-pending' { 'reviewed - feedback pending' }
        're-review'        { 're-review?' }
        default            { $State }
    }
}
