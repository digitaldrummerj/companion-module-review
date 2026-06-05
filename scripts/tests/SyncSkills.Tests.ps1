#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Self-contained tests for scripts/sync-skills.ps1 (no Pester).
.DESCRIPTION
    Builds a fixture repo (.squad/skills + .copilot/skills) exercising add / update /
    unchanged / preserve-system-skill, runs the script as a child process, and asserts.

    Run:  pwsh scripts/tests/SyncSkills.Tests.ps1
#>

$ErrorActionPreference = 'Stop'
$syncScript = Join-Path $PSScriptRoot '..' 'sync-skills.ps1'

$script:pass = 0; $script:fail = 0
function Ok($cond, $msg) {
    if ($cond) { $script:pass++; Write-Host "  PASS  $msg" -ForegroundColor Green }
    else       { $script:fail++; Write-Host "  FAIL  $msg" -ForegroundColor Red }
}
function Set-File($Path, $Content) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
    Set-Content -LiteralPath $Path -Value $Content -Encoding utf8 -NoNewline
}

# The script derives repo root as the parent of its own scripts/ dir, so the fixture
# must place a copy of sync-skills.ps1 under <fixtureRepo>/scripts/.
$root = Join-Path ([System.IO.Path]::GetTempPath()) "syncskills-$([System.IO.Path]::GetRandomFileName())"
try {
    $fixtureScript = Join-Path $root 'scripts' 'sync-skills.ps1'
    New-Item -ItemType Directory -Path (Split-Path -Parent $fixtureScript) -Force | Out-Null
    Copy-Item -LiteralPath $syncScript -Destination $fixtureScript -Force

    $squad   = Join-Path $root '.squad/skills'
    $copilot = Join-Path $root '.copilot/skills'

    Set-File (Join-Path $squad   'alpha/SKILL.md')  "alpha v2"          # exists in both, differs -> update
    Set-File (Join-Path $copilot 'alpha/SKILL.md')  "alpha v1"
    Set-File (Join-Path $squad   'beta/SKILL.md')   "beta"             # squad-only -> add
    Set-File (Join-Path $squad   'gamma/SKILL.md')  "gamma"            # identical in both -> unchanged
    Set-File (Join-Path $copilot 'gamma/SKILL.md')  "gamma"
    Set-File (Join-Path $copilot 'system-skill/SKILL.md') "system"     # copilot-only -> must be preserved

    # ── Check mode reports drift, writes nothing ─────────────────────────────
    & pwsh -NoProfile -File $fixtureScript -Check *>$null
    Ok ($LASTEXITCODE -eq 1) "-Check exits 1 when drifted"
    Ok (-not (Test-Path (Join-Path $copilot 'beta/SKILL.md'))) "-Check made no changes (beta not copied)"

    # ── Apply ────────────────────────────────────────────────────────────────
    & pwsh -NoProfile -File $fixtureScript *>$null
    Ok ((Get-Content -Raw (Join-Path $copilot 'alpha/SKILL.md')) -eq 'alpha v2') "drifted alpha overwritten with squad version"
    Ok (Test-Path (Join-Path $copilot 'beta/SKILL.md')) "squad-only beta added to copilot"
    Ok (Test-Path (Join-Path $copilot 'system-skill/SKILL.md')) "copilot-only system skill preserved"

    # ── Idempotent: second run reports in sync ───────────────────────────────
    & pwsh -NoProfile -File $fixtureScript -Check *>$null
    Ok ($LASTEXITCODE -eq 0) "-Check exits 0 after sync (idempotent)"
}
finally {
    if (Test-Path $root) { Remove-Item -Recurse -Force $root }
}

Write-Host ""
Write-Host "$($script:pass) passed, $($script:fail) failed" -ForegroundColor ($(if ($script:fail) { 'Red' } else { 'Green' }))
if ($script:fail) { exit 1 }
