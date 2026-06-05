#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Mirror .squad/skills/ (source of truth) into .copilot/skills/, deterministically.
.DESCRIPTION
    Implements the Scribe charter's "Skills sync" step as a script so it no longer
    depends on an agent remembering to do it by hand (which let 7 skills drift):

      - For each skill in .squad/skills/: copy it to .copilot/skills/{name}, overwriting
        if the contents differ.
      - NEVER remove a .copilot/skills/ entry that doesn't exist in .squad/skills/
        (those are system-level / Copilot-global skills).

    .squad/skills/ is authoritative; .copilot/skills/ is a generated mirror plus its own
    system skills. Edit skills in .squad/skills/ and run this to propagate.
.PARAMETER Check
    Report drift and exit 1 if anything is out of sync. Makes no changes. Use in CI or a
    pre-commit hook.
.EXAMPLE
    pwsh scripts/sync-skills.ps1            # apply the sync
    pwsh scripts/sync-skills.ps1 -Check     # report only, non-zero exit if drifted
#>

param(
    [switch]$Check
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repo = Split-Path -Parent $PSScriptRoot
$srcRoot = Join-Path $repo '.squad/skills'
$dstRoot = Join-Path $repo '.copilot/skills'

if (-not (Test-Path $srcRoot)) { Write-Error "Source of truth not found: $srcRoot"; exit 2 }
if (-not (Test-Path $dstRoot)) { New-Item -ItemType Directory -Path $dstRoot -Force | Out-Null }

function Get-DirSignature {
    param([string]$Dir)
    if (-not (Test-Path $Dir)) { return $null }
    $files = @(Get-ChildItem -LiteralPath $Dir -Recurse -File | Sort-Object FullName)
    $parts = foreach ($f in $files) {
        $rel = $f.FullName.Substring($Dir.Length).TrimStart('/', '\')
        "$rel=$((Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash)"
    }
    return ($parts -join '|')
}

$added = [System.Collections.Generic.List[string]]::new()
$updated = [System.Collections.Generic.List[string]]::new()
$unchanged = 0

foreach ($skillDir in Get-ChildItem -LiteralPath $srcRoot -Directory | Sort-Object Name) {
    $name = $skillDir.Name
    $dst  = Join-Path $dstRoot $name

    $srcSig = Get-DirSignature $skillDir.FullName
    $dstSig = Get-DirSignature $dst

    if ($null -eq $dstSig) {
        $added.Add($name)
    } elseif ($srcSig -ne $dstSig) {
        $updated.Add($name)
    } else {
        $unchanged++
        continue
    }

    if (-not $Check) {
        if (Test-Path $dst) { Remove-Item -LiteralPath $dst -Recurse -Force }
        Copy-Item -LiteralPath $skillDir.FullName -Destination $dst -Recurse -Force
    }
}

$drift = $added.Count + $updated.Count

Write-Host ""
Write-Host "Skills sync — .squad/skills → .copilot/skills" -ForegroundColor Cyan
Write-Host ("─" * 60)
foreach ($n in $added)   { Write-Host ("  {0,-9} {1}" -f ($(if ($Check) { 'MISSING' } else { 'ADDED' }), $n)) -ForegroundColor Yellow }
foreach ($n in $updated) { Write-Host ("  {0,-9} {1}" -f ($(if ($Check) { 'DRIFTED' } else { 'UPDATED' }), $n)) -ForegroundColor DarkYellow }
Write-Host ("─" * 60)
Write-Host ("unchanged: {0}  added: {1}  updated: {2}" -f $unchanged, $added.Count, $updated.Count)

if ($Check) {
    if ($drift -gt 0) {
        Write-Host ""
        Write-Host "$drift skill(s) out of sync. Run: pwsh scripts/sync-skills.ps1" -ForegroundColor Red
        exit 1
    }
    Write-Host "In sync." -ForegroundColor Green
}
Write-Host ""
