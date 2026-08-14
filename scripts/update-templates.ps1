#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Fast-forward the official v2 module templates to their upstream main. Manual only.
.DESCRIPTION
    This is THE ONLY thing in this workspace that ever moves a template. Nothing in the
    review pipeline — no script, no skill, no hook — may call it, and setup.ps1 deliberately
    does not pull either.

    The reason is concurrency: several review sessions typically run at once and they all
    diff against the same clones. An automatic pull would change the reference underneath a
    review already in progress, so findings from the first half of a review would be judged
    against a different template than the second half. Refreshing is therefore a deliberate
    act you perform BETWEEN review sessions, not during one.

    What it does, per language:
      * v2 clone (companion-module-template-{js,ts}) — `git fetch` + `git merge --ff-only`.
        Refuses a dirty work tree, a detached clone, or a non-fast-forward. It never
        rebases, force-merges, or resets: a non-fast-forward means somebody committed
        locally to a template clone, which is a situation to look at, not to paper over.
      * v1 clone (…-v1) — never fetched. It is pinned in detached HEAD at the last v1.x
        commit so v1 modules are judged against the API surface of their own era. This
        script only ASSERTS the pin hasn't drifted; it never repairs it.

    Reviews block on a stale template (validate-template.ps1 raises TEMPLATE-STALE and the
    review orchestrator aborts), so this is the command those messages point at.
.PARAMETER TemplatesDir
    Override the templates directory. Defaults to COMPANION_TEMPLATES_DIR, else
    companion-module-templates/ inside the repo.
.PARAMETER DryRun
    Report what would change without fetching or merging anything.
.PARAMETER Yes
    Skip the confirmation prompt when reviews appear to be in flight.
.PARAMETER Json
    Emit a machine-readable result instead of a console report. Implies -Yes.
.EXAMPLE
    pwsh scripts/update-templates.ps1
    pwsh scripts/update-templates.ps1 -DryRun
#>

param(
    [string]$TemplatesDir,
    [switch]$DryRun,
    [switch]$Yes,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. "$PSScriptRoot/lib/ReviewState.ps1"

$workspace = Split-Path -Parent $PSScriptRoot
if (-not $TemplatesDir) { $TemplatesDir = Resolve-TemplatesDir $workspace }
if (-not (Test-Path $TemplatesDir)) {
    Write-Error "Templates directory not found: $TemplatesDir. Run setup.ps1 first."
    exit 2
}
$TemplatesDir = (Resolve-Path $TemplatesDir).Path

function Write-Line { param([string]$Text, [string]$Color = 'Gray') if (-not $Json) { Write-Host $Text -ForegroundColor $Color } }

# ── Are any reviews in flight? ───────────────────────────────────────────────
# A module is "in flight" when its clone is still on disk and TRACKER.md has at least one
# ⬜ row for it — the same signal archive-reviewed-clones.ps1 uses to decide a clone isn't
# finished with. Refreshing now would move the reference under those reviews.
function Get-InFlightModules {
    $modulesDir  = Resolve-ModulesDir $workspace
    $trackerPath = Join-Path (Resolve-ReviewsDir $workspace) 'TRACKER.md'
    if (-not (Test-Path $modulesDir)) { return @() }

    $rows = @(Get-TrackerRows -TrackerPath $trackerPath)
    $pending = @($rows | Group-Object Module |
        Where-Object { @($_.Group | Where-Object { -not $_.Submitted }).Count -gt 0 } |
        ForEach-Object { $_.Name })

    $cloned = @(Get-ChildItem -LiteralPath $modulesDir -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like 'companion-module-*' } |
        ForEach-Object { $_.Name -replace '^companion-module-', '' })

    return @($pending | Where-Object { $cloned -contains $_ } | Sort-Object)
}

# ── Serialize concurrent runs ────────────────────────────────────────────────
# Guards only against two update-templates.ps1 runs racing on the same clones. It does NOT
# guard against a review reading a template mid-merge — nothing can, which is exactly why
# this is a between-sessions command.
$lockPath   = Join-Path $TemplatesDir '.update-templates.lock'
$lockStream = $null
function Enter-UpdateLock {
    try {
        $script:lockStream = [System.IO.File]::Open($lockPath, 'CreateNew', 'Write', 'None')
        $bytes = [System.Text.Encoding]::UTF8.GetBytes("pid=$PID started=$([datetime]::UtcNow.ToString('o'))`n")
        $script:lockStream.Write($bytes, 0, $bytes.Length)
        $script:lockStream.Flush()
    } catch [System.IO.IOException] {
        $holder = try { Get-Content -Raw -LiteralPath $lockPath } catch { $null }
        if ([string]::IsNullOrWhiteSpace($holder)) { $holder = '(no owner recorded)' }
        Write-Error ("Another update-templates.ps1 run holds the lock: $($holder.Trim())`n" +
                     "If that process is gone, remove the stale lock by hand: $lockPath")
        exit 1
    }
}
function Exit-UpdateLock {
    if ($script:lockStream) { $script:lockStream.Dispose(); $script:lockStream = $null }
    Remove-Item -LiteralPath $lockPath -Force -ErrorAction SilentlyContinue
}

# ── Refresh one v2 clone ─────────────────────────────────────────────────────
function Update-V2Clone {
    param([Parameter(Mandatory)][string]$Dir, [Parameter(Mandatory)][string]$Name)

    $r = [ordered]@{ name = $Name; kind = 'v2'; ok = $false; changed = $false
                     from = $null; to = $null; status = 'error'; message = $null; commits = @() }

    if (-not (Test-Path $Dir)) {
        $r.status = 'missing'; $r.message = "Not cloned yet — run setup.ps1."
        return [pscustomobject]$r
    }
    $info = Get-GitRepoInfo -Dir $Dir
    if (-not $info.IsRepo) {
        $r.status = 'not-a-repo'; $r.message = "Not a git work tree. Delete it and re-run setup.ps1."
        return [pscustomobject]$r
    }
    if ($info.Detached) {
        $r.status = 'detached'
        $r.message = "v2 clone is in detached HEAD at $($info.ShortSha) — it should track a branch. " +
                     "Delete it and re-run setup.ps1 rather than repairing it here."
        return [pscustomobject]$r
    }
    $dirty = Invoke-GitRead @('-C', $Dir, 'status', '--porcelain')
    if (-not [string]::IsNullOrWhiteSpace($dirty)) {
        $r.status = 'dirty'
        $r.message = "Work tree has local changes — refusing to touch it. Inspect: git -C `"$Dir`" status"
        return [pscustomobject]$r
    }

    $r.from = $info.ShortSha
    $fr = Test-TemplateFreshness -TemplateDir $Dir
    if ($fr.status -eq 'unverified') {
        $r.status = 'unverified'; $r.message = $fr.message
        return [pscustomobject]$r
    }
    if ($fr.status -eq 'fresh') {
        $r.ok = $true; $r.status = 'up-to-date'; $r.to = $info.ShortSha
        $r.message = "already up to date at $($info.ShortSha) ($($fr.localDate))"
        return [pscustomobject]$r
    }

    if ($DryRun) {
        $r.ok = $true; $r.status = 'would-update'; $r.to = $fr.remoteSha.Substring(0, 7)
        $r.message = "would fast-forward $($info.ShortSha) -> $($r.to)"
        return [pscustomobject]$r
    }

    if ($null -eq (Invoke-GitRead @('-C', $Dir, 'fetch', '--quiet', $info.Remote, $info.Branch))) {
        $r.status = 'fetch-failed'; $r.message = "git fetch $($info.Remote) $($info.Branch) failed"
        return [pscustomobject]$r
    }
    # --ff-only, never --rebase and never a merge commit: if the local clone has diverged we
    # want to hear about it, not silently rewrite it.
    if ($null -eq (Invoke-GitRead @('-C', $Dir, 'merge', '--ff-only', 'FETCH_HEAD'))) {
        $r.status = 'not-fast-forward'
        $r.message = "Local commits diverge from $($info.Remote)/$($info.Branch) — refusing to merge or reset. " +
                     "Inspect: git -C `"$Dir`" log --oneline $($info.Remote)/$($info.Branch)..HEAD"
        return [pscustomobject]$r
    }

    $after = Get-GitRepoInfo -Dir $Dir
    $log = Invoke-GitRead @('-C', $Dir, 'log', '--oneline', '--no-decorate', "$($info.Sha)..HEAD")
    $r.ok = $true; $r.changed = $true; $r.status = 'updated'; $r.to = $after.ShortSha
    $r.commits = if ([string]::IsNullOrWhiteSpace($log)) { @() } else { @($log -split "`r?`n") }
    $r.message = "$($info.ShortSha) ($(($fr.localDate))) -> $($after.ShortSha) ($((($after.CommittedAt -split 'T')[0])))"
    return [pscustomobject]$r
}

# ── Assert one v1 pin ────────────────────────────────────────────────────────
function Test-V1Pin {
    param([Parameter(Mandatory)][string]$Dir, [Parameter(Mandatory)][string]$Name, [Parameter(Mandatory)][string]$Pin)

    $r = [ordered]@{ name = $Name; kind = 'v1'; ok = $false; changed = $false
                     from = $null; to = $null; status = 'error'; message = $null; commits = @() }

    if (-not (Test-Path $Dir)) {
        $r.status = 'missing'; $r.message = "Not created yet — run setup.ps1."
        return [pscustomobject]$r
    }
    $info = Get-GitRepoInfo -Dir $Dir
    if (-not $info.IsRepo) {
        $r.status = 'not-a-repo'; $r.message = "Not a git work tree. Delete it and re-run setup.ps1."
        return [pscustomobject]$r
    }
    $r.from = $info.ShortSha; $r.to = $info.ShortSha
    if ($info.Sha -ne $Pin) {
        $r.status = 'drifted'
        $r.message = "HEAD $($info.ShortSha) != pinned $($Pin.Substring(0,7)). Re-pin by hand: " +
                     "git -C `"$Dir`" checkout --detach $Pin"
        return [pscustomobject]$r
    }
    if (-not $info.Detached) {
        $r.status = 'not-detached'
        $r.message = "On branch '$($info.Branch)' but should be detached at the pin. " +
                     "Re-pin by hand: git -C `"$Dir`" checkout --detach $Pin"
        return [pscustomobject]$r
    }
    $r.ok = $true; $r.status = 'pinned'
    $r.message = "pinned at $($info.ShortSha) (detached) — unchanged"
    return [pscustomobject]$r
}

# ── Run ──────────────────────────────────────────────────────────────────────
if (-not $Json) {
    Write-Host ""
    Write-Host "=== update-templates ===" -ForegroundColor Cyan
    Write-Host "  templates: $TemplatesDir"
    if ($DryRun) { Write-Host "  DRY RUN — nothing will be fetched or merged" -ForegroundColor DarkYellow }
    Write-Host ""
}

$inFlight = @(Get-InFlightModules)
if ($inFlight.Count -gt 0 -and -not $DryRun) {
    Write-Line ("[!!] $($inFlight.Count) review(s) appear to be in flight: $($inFlight -join ', ')") 'DarkYellow'
    Write-Line "     Refreshing now changes the template underneath them; their findings would be" 'DarkYellow'
    Write-Line "     judged against a reference that moved mid-review." 'DarkYellow'
    if (-not ($Yes -or $Json)) {
        $answer = Read-Host "     Continue? [y/N]"
        if ($answer -notmatch '^(y|yes)$') { Write-Line "Aborted." 'Yellow'; exit 0 }
    }
    Write-Line ""
}

$pins    = Get-TemplateV1Pins
$results = [System.Collections.Generic.List[object]]::new()

Enter-UpdateLock
try {
    foreach ($lang in 'js', 'ts') {
        $v2Name = "companion-module-template-$lang"
        $v1Name = "$v2Name-v1"
        $results.Add((Update-V2Clone -Dir (Join-Path $TemplatesDir $v2Name) -Name $v2Name))
        $results.Add((Test-V1Pin    -Dir (Join-Path $TemplatesDir $v1Name) -Name $v1Name -Pin $pins[$lang]))
    }
} finally {
    Exit-UpdateLock
}

$failed = @($results | Where-Object { -not $_.ok })

if ($Json) {
    [pscustomobject]@{
        templatesDir = $TemplatesDir
        dryRun       = [bool]$DryRun
        inFlight     = $inFlight
        results      = @($results)
        ok           = ($failed.Count -eq 0)
    } | ConvertTo-Json -Depth 6
} else {
    foreach ($r in $results) {
        $tag, $color = switch ($r.status) {
            'updated'      { '[OK]', 'Green' }
            'up-to-date'   { '[OK]', 'Green' }
            'pinned'       { '[OK]', 'Green' }
            'would-update' { '[..]', 'Cyan' }
            default        { '[!!]', 'Red' }
        }
        Write-Host ("{0} {1,-38} {2}" -f $tag, $r.name, $r.message) -ForegroundColor $color
        foreach ($c in $r.commits) { Write-Host ("       $c") -ForegroundColor DarkGray }
    }
    Write-Host ""
    if ($failed.Count -gt 0) {
        Write-Host "$($failed.Count) template(s) need attention — see above." -ForegroundColor Red
    } elseif (@($results | Where-Object { $_.changed }).Count -gt 0) {
        Write-Host "Templates refreshed. Re-run any review that aborted on TEMPLATE-STALE." -ForegroundColor Cyan
    } else {
        Write-Host "Nothing to do." -ForegroundColor Green
    }
    Write-Host ""
}

exit ($(if ($failed.Count -gt 0) { 1 } else { 0 }))
