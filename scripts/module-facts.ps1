#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Emit a compact "module fact sheet" for a Companion module under review — gathered once,
    shared with every reviewer agent so they don't each re-read package.json / manifest / tree.
.DESCRIPTION
    Produces the shared context for a review in one cheap pass: language (JS/TS), API version
    (v1/v2) and therefore which single api-compliance skill applies, package.json + manifest
    essentials, detected protocols, a source-tree summary, and a template-compliance summary
    (by invoking validate-template.ps1). The coordinator runs this at review start and hands
    the result to the reviewers instead of having five agents re-derive the basics.
.PARAMETER ModuleDir
    Path to the cloned module under review.
.PARAMETER GitTag
    The submitted git tag (passed through to the template check's version match).
.PARAMETER SkipTemplateCheck
    Don't invoke validate-template.ps1 (faster; omits the compliance summary).
.PARAMETER Json
    Emit JSON instead of the human-readable fact sheet.
.EXAMPLE
    pwsh scripts/module-facts.ps1 -ModuleDir ../companion-modules-reviewing/companion-module-foo -GitTag v1.2.0
    pwsh scripts/module-facts.ps1 -ModuleDir ./mod -Json
#>

param(
    [Parameter(Mandatory)][string]$ModuleDir,
    [string]$GitTag,
    [switch]$SkipTemplateCheck,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if (-not (Test-Path $ModuleDir)) { Write-Error "ModuleDir not found: $ModuleDir"; exit 2 }
$ModuleDir = (Resolve-Path $ModuleDir).Path

function Has-Prop { param($Obj, [string]$Name) $Obj -and ($Obj.PSObject.Properties.Name -contains $Name) }
function Read-Json { param([string]$Path) if (Test-Path $Path) { try { return Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json } catch { return $null } } return $null }

$pkg = Read-Json (Join-Path $ModuleDir 'package.json')
$man = Read-Json (Join-Path $ModuleDir 'companion/manifest.json')

# Language + API version (mirror validate-template.ps1's detection).
$isTs = (Test-Path (Join-Path $ModuleDir 'tsconfig.json')) -or ((Has-Prop $pkg 'type') -and $pkg.type -eq 'module')
$lang = if ($isTs) { 'TS' } else { 'JS' }
$baseRange = if ((Has-Prop $pkg 'dependencies') -and (Has-Prop $pkg.dependencies '@companion-module/base')) { [string]$pkg.dependencies.'@companion-module/base' } else { $null }
$apiMajor = 2
if ($baseRange -and $baseRange -match '(\d+)') { $apiMajor = [int]$Matches[1] }
$apiVer = "v$apiMajor"
$apiSkill = if ($apiMajor -le 1) { 'companion-v1-api-compliance' } else { 'companion-v2-api-compliance' }

# Protocol hints — scan deps + a shallow source grep for transport markers.
$depNames = @()
foreach ($sect in 'dependencies', 'devDependencies') {
    if (Has-Prop $pkg $sect) { $depNames += @($pkg.$sect.PSObject.Properties.Name) }
}
$srcText = ''
$srcDir = Join-Path $ModuleDir 'src'
if (Test-Path $srcDir) {
    $srcText = (Get-ChildItem -LiteralPath $srcDir -Recurse -File -Include '*.ts', '*.js' -ErrorAction SilentlyContinue |
        Get-Content -Raw -ErrorAction SilentlyContinue) -join "`n"
}
$haystack = ($depNames -join ' ') + ' ' + $srcText
$protocols = [ordered]@{
    OSC     = $haystack -match '(?i)osc'
    TCP     = $haystack -match "(?i)\bnet\b|createConnection|new Socket|node:net"
    UDP     = $haystack -match "(?i)dgram|createSocket"
    HTTP    = $haystack -match "(?i)axios|node-fetch|got\b|http\.request|fetch\("
    WebSocket = $haystack -match "(?i)websocket|\bws\b"
    Bonjour = $haystack -match "(?i)bonjour|mdns"
}
$detected = @($protocols.GetEnumerator() | Where-Object { $_.Value } | ForEach-Object { $_.Key })

# Source tree summary.
$srcFiles = @()
if (Test-Path $srcDir) {
    $srcFiles = @(Get-ChildItem -LiteralPath $srcDir -Recurse -File -Include '*.ts', '*.js' -ErrorAction SilentlyContinue |
        ForEach-Object { $_.FullName.Substring($ModuleDir.Length).TrimStart('/', '\') })
}

# Template-compliance summary (reuse validate-template.ps1; don't duplicate the rules).
$templateCheck = $null
if (-not $SkipTemplateCheck) {
    $vt = Join-Path $PSScriptRoot 'validate-template.ps1'
    $vtArgs = @('-NoProfile', '-File', $vt, '-ModuleDir', $ModuleDir, '-Json')
    if ($GitTag) { $vtArgs += @('-ExpectedVersion', $GitTag) }
    try {
        $raw = & pwsh @vtArgs 2>$null
        if ($raw) {
            $parsed = $raw | ConvertFrom-Json
            $templateCheck = [pscustomobject]@{
                critical      = $parsed.counts.critical
                high          = $parsed.counts.high
                criticalIds   = @($parsed.findings | Where-Object severity -eq 'Critical' | ForEach-Object { $_.id } | Sort-Object -Unique)
                templateUsed  = Split-Path $parsed.templateDir -Leaf
            }
        }
    } catch { $templateCheck = $null }
}

$facts = [pscustomobject]@{
    module        = (Split-Path $ModuleDir -Leaf) -replace '^companion-module-', ''
    moduleDir     = $ModuleDir
    gitTag        = $GitTag
    language      = $lang
    apiVersion    = $apiVer
    apiSkill      = $apiSkill
    baseRange     = $baseRange
    packageName   = if (Has-Prop $pkg 'name') { $pkg.name } else { $null }
    packageVersion = if (Has-Prop $pkg 'version') { $pkg.version } else { $null }
    manifestId    = if (Has-Prop $man 'id') { $man.id } else { $null }
    runtimeEntry  = if ((Has-Prop $man 'runtime') -and (Has-Prop $man.runtime 'entrypoint')) { $man.runtime.entrypoint } else { $null }
    protocols     = $detected
    srcFileCount  = $srcFiles.Count
    srcFiles      = $srcFiles
    templateCheck = $templateCheck
}

if ($Json) {
    $facts | ConvertTo-Json -Depth 6
    exit 0
}

Write-Host ""
Write-Host "Module Fact Sheet — $($facts.module)" -ForegroundColor Cyan
Write-Host ("─" * 64)
Write-Host ("  Language:        {0}   API: {1}" -f $facts.language, $facts.apiVersion)
Write-Host ("  Apply skill:     {0}  (load ONLY this api-compliance skill)" -f $facts.apiSkill) -ForegroundColor Yellow
Write-Host ("  @companion/base: {0}" -f $facts.baseRange)
Write-Host ("  package:         {0}@{1}   manifest id: {2}" -f $facts.packageName, $facts.packageVersion, $facts.manifestId)
Write-Host ("  runtime entry:   {0}" -f $facts.runtimeEntry)
Write-Host ("  Protocols:       {0}" -f $(if ($detected) { $detected -join ', ' } else { '(none detected)' }))
Write-Host ("  Source files:    {0} under src/" -f $facts.srcFileCount)
if ($templateCheck) {
    $col = if ($templateCheck.critical -gt 0) { 'Red' } else { 'Green' }
    Write-Host ("  Template check:  {0} critical, {1} high  (vs {2})" -f $templateCheck.critical, $templateCheck.high, $templateCheck.templateUsed) -ForegroundColor $col
    if ($templateCheck.criticalIds) { Write-Host ("                   {0}" -f ($templateCheck.criticalIds -join ', ')) -ForegroundColor Red }
} else {
    Write-Host "  Template check:  (skipped)"
}
Write-Host ("─" * 64)
Write-Host "Reviewers: read this instead of re-deriving package.json / manifest / tree." -ForegroundColor DarkGray
Write-Host ""
