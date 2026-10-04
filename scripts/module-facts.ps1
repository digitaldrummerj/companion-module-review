#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Emit a compact "module fact sheet" for a Companion module under review — gathered once,
    shared with every reviewer agent so they don't each re-read package.json / manifest / tree.
.DESCRIPTION
    Produces the shared context for a review in one cheap pass: language (JS/TS), API version
    (v1/v2) and therefore which single api-compliance skill applies, the exact API level
    (1 / 2.0 / 2.1 …, from the lockfile) and which of that skill's per-version reference files
    to load, package.json + manifest essentials, detected protocols, a source-tree summary, a
    template-compliance summary (by invoking validate-template.ps1), and the API-usage hints
    from api-scan.ps1. The coordinator runs this at review start and hands the result to the
    reviewers instead of having five agents re-derive the basics.
.PARAMETER ModuleDir
    Path to the cloned module under review.
.PARAMETER GitTag
    The submitted git tag (passed through to the template check's version match).
.PARAMETER SkipTemplateCheck
    Don't invoke validate-template.ps1 (faster; omits the compliance summary).
.PARAMETER SkipTemplateFreshness
    Passed through to validate-template.ps1: don't verify the template clone against
    upstream. For deliberate offline runs only.
.PARAMETER SkipApiScan
    Don't invoke api-scan.ps1 (omits the apiScan hints).
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
    [switch]$SkipTemplateFreshness,
    [switch]$SkipApiScan,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. "$PSScriptRoot/lib/ReviewState.ps1"

if (-not (Test-Path $ModuleDir)) { Write-Error "ModuleDir not found: $ModuleDir"; exit 2 }
$ModuleDir = (Resolve-Path $ModuleDir).Path

function Has-Prop { param($Obj, [string]$Name) $Obj -and ($Obj.PSObject.Properties.Name -contains $Name) }
function Read-Json { param([string]$Path) if (Test-Path $Path) { try { return Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json } catch { return $null } } return $null }

$pkg = Read-Json (Join-Path $ModuleDir 'package.json')
$man = Read-Json (Join-Path $ModuleDir 'companion/manifest.json')

# Language + API version. Shares Test-ModuleIsTypeScript with validate-template.ps1
# (lib/ReviewState.ps1) so the two stay in lockstep: TS = tsconfig.json OR .ts sources.
$isTs = Test-ModuleIsTypeScript $ModuleDir
$lang = if ($isTs) { 'TS' } else { 'JS' }
$baseRange = if ((Has-Prop $pkg 'dependencies') -and (Has-Prop $pkg.dependencies '@companion-module/base')) { [string]$pkg.dependencies.'@companion-module/base' } else { $null }

# API level, not just the major: 2.0 and 2.1 are reviewed against different reference files
# of the same skill, and a 2.0 module must never be asked for 2.1 features. The version comes
# from the lockfile when there is one (shared resolver in lib/ReviewState.ps1, mirroring the
# compliance skill's Step 1). apiVersion / apiSkill keep their old meaning for consumers that
# only know about the major.
$base = Resolve-CompanionBaseVersion $ModuleDir
$apiMajor = $base.major
$apiVer = "v$apiMajor"
$apiProfile = Get-CompanionApiProfile -ApiLevel $base.apiLevel -SkillsDir (Join-Path (Split-Path -Parent $PSScriptRoot) '.claude/skills')
$apiSkill = $apiProfile.apiSkill

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
# This is also where template freshness is established, which is why the orchestrator can
# abort on a stale clone here — before the expensive -RunBuild pass and before any reviewer
# agent is dispatched against expectations that would have been wrong anyway.
$templateCheck = $null
$templateFreshness = if ($SkipTemplateCheck) { 'not-checked' } else { 'unknown' }
if (-not $SkipTemplateCheck) {
    $vt = Join-Path $PSScriptRoot 'validate-template.ps1'
    $vtArgs = @('-NoProfile', '-File', $vt, '-ModuleDir', $ModuleDir, '-Json')
    if ($GitTag) { $vtArgs += @('-ExpectedVersion', $GitTag) }
    if ($SkipTemplateFreshness) { $vtArgs += '-SkipTemplateFreshness' }
    # Capture stderr rather than discarding it: this used to be `2>$null` + a bare catch,
    # which rendered a crashed validator as "(skipped)" — a failure that looked like a
    # deliberate omission. A check that silently doesn't run is the exact thing this whole
    # freshness mechanism exists to prevent.
    $stderrFile = [System.IO.Path]::GetTempFileName()
    try {
        $raw = & pwsh @vtArgs 2>$stderrFile
        if ($raw) {
            $parsed = $raw | ConvertFrom-Json
            $templateFreshness = $parsed.templateFreshness.status
            $templateCheck = [pscustomobject]@{
                critical     = $parsed.counts.critical
                high         = $parsed.counts.high
                criticalIds  = @($parsed.findings | Where-Object severity -eq 'Critical' | ForEach-Object { $_.id } | Sort-Object -Unique)
                templateUsed = Split-Path $parsed.templateDir -Leaf
                templateSha  = $parsed.templateRevision.shortSha
                templateDate = $parsed.templateRevision.committedAt
                freshness    = $templateFreshness
                error        = $null
            }
        } else {
            $err = (Get-Content -Raw -LiteralPath $stderrFile -ErrorAction SilentlyContinue)
            $templateFreshness = 'error'
            $templateCheck = [pscustomobject]@{
                critical = $null; high = $null; criticalIds = @(); templateUsed = $null
                templateSha = $null; templateDate = $null; freshness = 'error'
                error = if ($err) { $err.Trim() } else { 'validate-template.ps1 produced no output' }
            }
        }
    } catch {
        $templateFreshness = 'error'
        $templateCheck = [pscustomobject]@{
            critical = $null; high = $null; criticalIds = @(); templateUsed = $null
            templateSha = $null; templateDate = $null; freshness = 'error'
            error = $_.Exception.Message
        }
    } finally {
        Remove-Item -LiteralPath $stderrFile -Force -ErrorAction SilentlyContinue
    }
}

# API-usage hints (api-scan.ps1). Leads for the compliance reviewer, keyed to apiLevel — never
# findings on their own. Run as a child process like validate-template so a crash shows up as
# an error in the fact sheet instead of an empty-looking "no hints". The hint list is capped:
# the fact sheet is handed to every reviewer, and the full list is one api-scan run away.
$apiScan = $null
if (-not $SkipApiScan) {
    $maxHints = 50
    $as = Join-Path $PSScriptRoot 'api-scan.ps1'
    try {
        $raw = & pwsh -NoProfile -File $as -ModuleDir $ModuleDir -Json 2>$null
        $parsed = if ($raw) { $raw | ConvertFrom-Json } else { $null }
        if ($parsed) {
            $all = @($parsed.hints)
            $apiScan = [pscustomobject]@{
                count     = $parsed.counts.total
                byId      = $parsed.counts.byId
                hints     = @($all | Select-Object -First $maxHints)
                truncated = $all.Count -gt $maxHints
                error     = $null
            }
        } else {
            $apiScan = [pscustomobject]@{ count = $null; byId = $null; hints = @(); truncated = $false; error = 'api-scan.ps1 produced no output' }
        }
    } catch {
        $apiScan = [pscustomobject]@{ count = $null; byId = $null; hints = @(); truncated = $false; error = $_.Exception.Message }
    }
}

$facts = [pscustomobject]@{
    module        = (Split-Path $ModuleDir -Leaf) -replace '^companion-module-', ''
    moduleDir     = $ModuleDir
    gitTag        = $GitTag
    language      = $lang
    apiVersion    = $apiVer
    apiSkill      = $apiSkill
    apiLevel      = $base.apiLevel
    baseVersion   = $base.version
    baseVersionSource = $base.source
    # true when only a minor-floating range (^2.0.0) was available: apiLevel is the lowest the
    # range allows, and the review should suggest pinning.
    apiAmbiguous  = $base.ambiguous
    minCompanion  = $apiProfile.minCompanion
    # The compliance reviewer loads apiSkill plus exactly these files, and nothing newer.
    apiReferences = @($apiProfile.apiReferences)
    apiReferencesMissing = @($apiProfile.referencesMissing)
    baseRange     = $baseRange
    packageName   = if (Has-Prop $pkg 'name') { $pkg.name } else { $null }
    packageVersion = if (Has-Prop $pkg 'version') { $pkg.version } else { $null }
    manifestId    = if (Has-Prop $man 'id') { $man.id } else { $null }
    runtimeEntry  = if ((Has-Prop $man 'runtime') -and (Has-Prop $man.runtime 'entrypoint')) { $man.runtime.entrypoint } else { $null }
    protocols     = $detected
    srcFileCount  = $srcFiles.Count
    srcFiles      = $srcFiles
    # Hoisted to the top level so the review orchestrator can gate on one field: anything
    # other than 'fresh' / 'pinned' / 'skipped' means stop, refresh, and re-run.
    templateFreshness = $templateFreshness
    templateCheck = $templateCheck
    apiScan       = $apiScan
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
$apiLine = "$(if ($facts.apiLevel -eq '1') { '1.x' } else { $facts.apiLevel }) (base $($facts.baseVersion) from $($facts.baseVersionSource))"
if ($facts.minCompanion) { $apiLine += " -> Companion $($facts.minCompanion)+" }
Write-Host ("  API level:       {0}" -f $apiLine) -ForegroundColor Yellow
if ($facts.apiReferences.Count -gt 0) {
    Write-Host ("  Load references: {0}  (and nothing newer)" -f ($facts.apiReferences -join ', ')) -ForegroundColor Yellow
}
if ($facts.apiAmbiguous) {
    Write-Host  "  API level AMBIGUOUS — no lockfile entry; the range lets the minor float. Assumed the lowest; suggest pinning ~2.N.x." -ForegroundColor DarkYellow
}
if ($facts.apiReferencesMissing.Count -gt 0) {
    Write-Host ("  Not in the skill copy: {0} — review against the files that exist and say so." -f ($facts.apiReferencesMissing -join ', ')) -ForegroundColor DarkYellow
}
Write-Host ("  @companion/base: {0}" -f $facts.baseRange)
Write-Host ("  package:         {0}@{1}   manifest id: {2}" -f $facts.packageName, $facts.packageVersion, $facts.manifestId)
Write-Host ("  runtime entry:   {0}" -f $facts.runtimeEntry)
Write-Host ("  Protocols:       {0}" -f $(if ($detected) { $detected -join ', ' } else { '(none detected)' }))
Write-Host ("  Source files:    {0} under src/" -f $facts.srcFileCount)
if ($templateCheck -and $templateCheck.error) {
    Write-Host ("  Template check:  FAILED TO RUN — {0}" -f $templateCheck.error) -ForegroundColor Red
} elseif ($templateCheck) {
    $rev = if ($templateCheck.templateSha) { " @ $($templateCheck.templateSha) $($templateCheck.templateDate)" } else { '' }
    $col = if ($templateCheck.critical -gt 0) { 'Red' } else { 'Green' }
    Write-Host ("  Template check:  {0} critical, {1} high  (vs {2}{3})" -f $templateCheck.critical, $templateCheck.high, $templateCheck.templateUsed, $rev) -ForegroundColor $col
    if ($templateCheck.criticalIds) { Write-Host ("                   {0}" -f ($templateCheck.criticalIds -join ', ')) -ForegroundColor Red }
    if ($templateFreshness -in @('stale', 'unverified')) {
        Write-Host ("  TEMPLATE $($templateFreshness.ToUpper()) — findings above are judged against the wrong reference.") -ForegroundColor Red
        Write-Host  "  Run: pwsh scripts/update-templates.ps1   then re-run the review." -ForegroundColor Red
    }
} else {
    Write-Host "  Template check:  (skipped)"
}
if ($apiScan -and $apiScan.error) {
    Write-Host ("  API scan:        FAILED TO RUN — {0}" -f $apiScan.error) -ForegroundColor Red
} elseif ($apiScan) {
    $ids = @($apiScan.byId.PSObject.Properties | ForEach-Object { "$($_.Name)×$($_.Value)" })
    $col = if ($apiScan.count -gt 0) { 'DarkYellow' } else { 'Green' }
    Write-Host ("  API scan:        {0} hints{1}  (leads to verify, not findings)" -f $apiScan.count, $(if ($ids) { " — $($ids -join ', ')" } else { '' })) -ForegroundColor $col
} else {
    Write-Host "  API scan:        (skipped)"
}
Write-Host ("─" * 64)
Write-Host "Reviewers: read this instead of re-deriving package.json / manifest / tree." -ForegroundColor DarkGray
Write-Host ""
