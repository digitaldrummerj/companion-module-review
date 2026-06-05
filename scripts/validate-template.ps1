#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Deterministic template-compliance validator for a Companion module.
.DESCRIPTION
    Performs the mechanical portion of the companion-template-compliance review against
    the official JS/TS template: required files, config-file parity, package.json /
    manifest.json field rules, HELP.md stub detection, husky (TS), no package-lock.json,
    and "gitignored files must not be committed". Optionally runs the build and lint.

    This is the part of a review that does NOT need an LLM — it is exact, repeatable, and
    cheap. The reviewer is left only with judgment calls (is HELP.md meaningful, is a
    tsconfig deviation justified).

    The official template repo is the authoritative reference. It is auto-detected in the
    sibling modules workspace (companion-module-template-js|ts) or passed via -TemplateDir.
.PARAMETER ModuleDir
    Path to the cloned module under review.
.PARAMETER TemplateDir
    Path to the matching template repo. Auto-detected from the modules workspace if omitted.
.PARAMETER ExpectedVersion
    The git tag under review (with or without leading 'v'). Enables the package.json
    version-match check. Skipped if omitted.
.PARAMETER RunBuild
    Also run `yarn install --immutable` + `yarn package` (and `yarn lint` for TS) and gate
    on success. Slow and requires network; off by default.
.PARAMETER Json
    Emit findings as JSON instead of a console report.
.EXAMPLE
    pwsh scripts/validate-template.ps1 -ModuleDir ../companion-modules-reviewing/companion-module-foo
    pwsh scripts/validate-template.ps1 -ModuleDir ./mod -ExpectedVersion v1.2.0 -RunBuild -Json
#>

param(
    [Parameter(Mandatory)][string]$ModuleDir,
    [string]$TemplateDir,
    [string]$ExpectedVersion,
    [switch]$RunBuild,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. "$PSScriptRoot/lib/ReviewState.ps1"

if (-not (Test-Path $ModuleDir)) { Write-Error "ModuleDir not found: $ModuleDir"; exit 2 }
$ModuleDir = (Resolve-Path $ModuleDir).Path

# ── Findings accumulator ─────────────────────────────────────────────────────
$findings = [System.Collections.Generic.List[object]]::new()
function Add-Finding {
    param(
        [string]$Id,
        [ValidateSet('Critical','High','Medium','Info')][string]$Severity,
        [string]$File,
        [string]$Message
    )
    $findings.Add([pscustomobject]@{ id = $Id; severity = $Severity; file = $File; message = $Message })
}

# ── Detect JS vs TS ──────────────────────────────────────────────────────────
$pkgPath = Join-Path $ModuleDir 'package.json'
$pkg = $null
if (Test-Path $pkgPath) {
    try { $pkg = Get-Content -Raw -LiteralPath $pkgPath | ConvertFrom-Json }
    catch { Add-Finding 'PKG-PARSE' 'Critical' 'package.json' "Not valid JSON: $($_.Exception.Message)" }
}

function Has-Prop { param($Obj, [string]$Name) $Obj -and ($Obj.PSObject.Properties.Name -contains $Name) }

$isTs = (Test-Path (Join-Path $ModuleDir 'tsconfig.json')) -or ((Has-Prop $pkg 'type') -and $pkg.type -eq 'module')
$lang = if ($isTs) { 'TS' } else { 'JS' }

# ── Resolve template dir ─────────────────────────────────────────────────────
if (-not $TemplateDir) {
    $workspace  = Split-Path -Parent $PSScriptRoot
    $modulesDir = Resolve-ModulesDir $workspace
    $candidate  = Join-Path $modulesDir ("companion-module-template-" + $lang.ToLower())
    if (Test-Path $candidate) { $TemplateDir = $candidate }
}
if (-not $TemplateDir -or -not (Test-Path $TemplateDir)) {
    Write-Error "Template repo for $lang not found. Clone companion-module-template-$($lang.ToLower()) into the modules workspace or pass -TemplateDir."
    exit 2
}
$TemplateDir = (Resolve-Path $TemplateDir).Path

# ── 1. Required files ────────────────────────────────────────────────────────
$requiredCommon = @('.gitattributes','.gitignore','.prettierignore','.yarnrc.yml','LICENSE','package.json','yarn.lock','companion/manifest.json','companion/HELP.md')
$requiredJs = @('src/main.js')
$requiredTs = @('eslint.config.mjs','tsconfig.build.json','tsconfig.json','.husky/pre-commit','src/main.ts')
$required = if ($isTs) { $requiredCommon + $requiredTs } else { $requiredCommon + $requiredJs }
foreach ($rel in $required) {
    if (-not (Test-Path (Join-Path $ModuleDir $rel))) {
        Add-Finding 'FILE-MISSING' 'Critical' $rel 'Required file is missing'
    }
}

# package-lock.json must NOT exist
if (Test-Path (Join-Path $ModuleDir 'package-lock.json')) {
    Add-Finding 'NPM-LOCK' 'Critical' 'package-lock.json' 'Present — module must use yarn, not npm (automatic rejection)'
}

# ── 2. Config-file parity vs template (normalized) ───────────────────────────
function Read-NormalizedLines {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return @() }
    $text = Get-Content -Raw -LiteralPath $Path
    if ($null -eq $text) { return @() }
    $lines = @($text -split "`r?`n" | ForEach-Object { $_.TrimEnd() })
    # drop trailing empty lines
    $i = $lines.Count - 1
    while ($i -ge 0 -and $lines[$i] -eq '') { $i-- }
    if ($i -lt 0) { return @() }
    return @($lines[0..$i])
}

$configFiles = @('.gitattributes','.gitignore','.prettierignore','.yarnrc.yml')
if ($isTs) { $configFiles += @('eslint.config.mjs','tsconfig.json','tsconfig.build.json') }

foreach ($rel in $configFiles) {
    $modFile = Join-Path $ModuleDir $rel
    $tplFile = Join-Path $TemplateDir $rel
    if (-not (Test-Path $modFile)) { continue }   # already reported as missing
    if (-not (Test-Path $tplFile)) { continue }   # template lacks it; nothing to compare
    $modLines = @(Read-NormalizedLines $modFile)
    $tplLines = @(Read-NormalizedLines $tplFile)
    if (($modLines -join "`n") -ne ($tplLines -join "`n")) {
        $firstDiff = ''
        $max = [math]::Max($modLines.Count, $tplLines.Count)
        for ($i = 0; $i -lt $max; $i++) {
            $m = if ($i -lt $modLines.Count) { $modLines[$i] } else { '<missing>' }
            $t = if ($i -lt $tplLines.Count) { $tplLines[$i] } else { '<missing>' }
            if ($m -ne $t) { $firstDiff = "line $($i+1): found '$m', template '$t'"; break }
        }
        Add-Finding 'CONFIG-DIFF' 'Critical' $rel "Differs from template ($firstDiff)"
    }
}

# ── 3. Gitignored files must not be committed ────────────────────────────────
function Test-PathMatchesIgnore {
    param([string]$RelPath, [string]$Pattern)
    $p = $Pattern.Trim()
    if (-not $p -or $p.StartsWith('#')) { return $false }
    $anchored = $p.StartsWith('/')
    $p = $p.TrimStart('/').TrimEnd('/')
    if (-not $p) { return $false }
    $escaped = [regex]::Escape($p).Replace('\*','[^/]*')
    if ($anchored) {
        # Anchored to repo root: whole path or a directory prefix.
        return $RelPath -match ('^' + $escaped + '(/|$)')
    }
    # Unanchored: match any path segment (e.g. node_modules/, DEBUG-*, package-lock.json).
    return @(($RelPath -split '/') | Where-Object { $_ -match ('^' + $escaped + '$') }).Count -gt 0
}

$tplGitignore = @(Read-NormalizedLines (Join-Path $TemplateDir '.gitignore'))
if ($tplGitignore -and (Test-Path (Join-Path $ModuleDir '.git'))) {
    $tracked = & git -C $ModuleDir ls-files 2>$null
    foreach ($f in $tracked) {
        foreach ($pat in $tplGitignore) {
            if (Test-PathMatchesIgnore $f $pat) {
                Add-Finding 'GITIGNORED-COMMITTED' 'Critical' $f "Committed but template .gitignore excludes it (pattern '$pat')"
                break
            }
        }
    }
}

# ── 4. package.json rules ────────────────────────────────────────────────────
if ($pkg) {
    $moduleName = (Split-Path $ModuleDir -Leaf) -replace '^companion-module-',''
    $expectedRepo = "git+https://github.com/bitfocus/companion-module-$moduleName.git"

    if ($ExpectedVersion) {
        $want = ConvertTo-NormalizedTag $ExpectedVersion
        if ((Has-Prop $pkg 'version') -and $pkg.version -ne $want) {
            Add-Finding 'PKG-VERSION' 'Critical' 'package.json' "version '$($pkg.version)' != git tag '$want'"
        }
    }
    $expectedMain = if ($isTs) { 'dist/main.js' } else { 'src/main.js' }
    if ((Has-Prop $pkg 'main') -and $pkg.main -ne $expectedMain) {
        Add-Finding 'PKG-MAIN' 'Critical' 'package.json' "main '$($pkg.main)' should be '$expectedMain'"
    }
    if ((Has-Prop $pkg 'repository') -and (Has-Prop $pkg.repository 'url') -and $pkg.repository.url -ne $expectedRepo) {
        Add-Finding 'PKG-REPO' 'Critical' 'package.json' "repository.url '$($pkg.repository.url)' should be '$expectedRepo'"
    }
    foreach ($field in @('engines','prettier','packageManager','license')) {
        if (-not (Has-Prop $pkg $field)) { Add-Finding 'PKG-FIELD' 'Critical' 'package.json' "Missing required field '$field'" }
    }
    if ((Has-Prop $pkg 'packageManager') -and $pkg.packageManager -notmatch '^yarn@4') {
        Add-Finding 'PKG-YARN' 'Critical' 'package.json' "packageManager '$($pkg.packageManager)' must start with 'yarn@4'"
    }
    $reqScripts = if ($isTs) { @('format','package','build','build:main','dev','lint','lint:raw','postinstall') } else { @('format','package') }
    foreach ($s in $reqScripts) {
        if (-not ((Has-Prop $pkg 'scripts') -and (Has-Prop $pkg.scripts $s))) {
            Add-Finding 'PKG-SCRIPT' 'Critical' 'package.json' "Missing required script '$s'"
        }
    }
    if (-not ((Has-Prop $pkg 'dependencies') -and (Has-Prop $pkg.dependencies '@companion-module/base'))) {
        Add-Finding 'PKG-DEP' 'Critical' 'package.json' "Missing dependency '@companion-module/base'"
    }
}

# ── 5. manifest.json rules ───────────────────────────────────────────────────
$manifestPath = Join-Path $ModuleDir 'companion/manifest.json'
if (Test-Path $manifestPath) {
    $man = $null
    try { $man = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json }
    catch { Add-Finding 'MAN-PARSE' 'Critical' 'companion/manifest.json' "Not valid JSON: $($_.Exception.Message)" }
    if ($man) {
        $moduleName = (Split-Path $ModuleDir -Leaf) -replace '^companion-module-',''
        if ((Has-Prop $man 'id') -and (Has-Prop $man 'name') -and $man.id -ne $man.name) {
            Add-Finding 'MAN-IDNAME' 'Critical' 'companion/manifest.json' "id '$($man.id)' != name '$($man.name)'"
        }
        if (-not (Has-Prop $man 'maintainers') -or @($man.maintainers).Count -eq 0) {
            Add-Finding 'MAN-MAINT' 'Critical' 'companion/manifest.json' 'maintainers is empty'
        } else {
            foreach ($m in $man.maintainers) {
                $badName  = (Has-Prop $m 'name')  -and ($m.name  -match '^(Your name)?$')
                $badEmail = (Has-Prop $m 'email') -and ($m.email -match '^(Your email)?$')
                if ($badName -or $badEmail) {
                    Add-Finding 'MAN-PLACEHOLDER' 'Critical' 'companion/manifest.json' "Placeholder maintainer: name='$($m.name)' email='$($m.email)'"
                }
            }
        }
        $banned = @('companion','module','stream deck','streamdeck','bitfocus')
        if (Has-Prop $man 'keywords') {
            foreach ($kw in $man.keywords) {
                $low = "$kw".ToLower()
                if ($banned -contains $low -or $low -eq $moduleName -or ($moduleName -split '-') -contains $low) {
                    Add-Finding 'MAN-KEYWORD' 'Critical' 'companion/manifest.json' "Banned/low-value keyword '$kw'"
                }
            }
        }
    }
}

# ── 6. HELP.md stub detection ────────────────────────────────────────────────
$helpPath = Join-Path $ModuleDir 'companion/HELP.md'
if (Test-Path $helpPath) {
    $help = Get-Content -Raw -LiteralPath $helpPath
    $meaningful = @($help -split "`r?`n" | Where-Object { $_.Trim() }).Count
    if ($help -match 'Write some help for your users here' -or $meaningful -lt 5) {
        Add-Finding 'HELP-STUB' 'Critical' 'companion/HELP.md' 'Looks like a stub — needs real user documentation'
    }
}

# ── 7. husky (TS) ────────────────────────────────────────────────────────────
if ($isTs) {
    $hook = Join-Path $ModuleDir '.husky/pre-commit'
    if (Test-Path $hook) {
        if ((Get-Content -Raw -LiteralPath $hook) -notmatch 'lint-staged') {
            Add-Finding 'HUSKY' 'Critical' '.husky/pre-commit' "Hook should run 'lint-staged'"
        }
    }
}

# ── 8. Optional build / lint ─────────────────────────────────────────────────
if ($RunBuild) {
    Push-Location $ModuleDir
    try {
        & yarn install --immutable *>$null
        if ($LASTEXITCODE -ne 0) { Add-Finding 'BUILD-INSTALL' 'Critical' 'package.json' 'yarn install --immutable failed' }
        & yarn package *>$null
        if ($LASTEXITCODE -ne 0) { Add-Finding 'BUILD-PACKAGE' 'Critical' 'package.json' 'yarn package (build) failed' }
        if ($isTs) {
            & yarn lint *>$null
            if ($LASTEXITCODE -ne 0) { Add-Finding 'LINT' 'High' 'package.json' 'yarn lint reported problems' }
        }
    } finally { Pop-Location }
}

# ── Output ───────────────────────────────────────────────────────────────────
$result = [pscustomobject]@{
    moduleDir   = $ModuleDir
    templateDir = $TemplateDir
    language    = $lang
    findings    = $findings
    counts      = [pscustomobject]@{
        critical = @($findings | Where-Object severity -eq 'Critical').Count
        high     = @($findings | Where-Object severity -eq 'High').Count
        medium   = @($findings | Where-Object severity -eq 'Medium').Count
    }
}

if ($Json) {
    $result | ConvertTo-Json -Depth 6
} else {
    Write-Host ""
    Write-Host "validate-template — $lang module" -ForegroundColor Cyan
    Write-Host "  module:   $ModuleDir"
    Write-Host "  template: $TemplateDir"
    Write-Host ("─" * 70)
    if ($findings.Count -eq 0) {
        Write-Host "No deterministic template violations found." -ForegroundColor Green
    } else {
        foreach ($f in $findings) {
            $c = switch ($f.severity) { 'Critical' { 'Red' } 'High' { 'DarkYellow' } default { 'Gray' } }
            Write-Host ("  [{0}] {1}  {2} — {3}" -f $f.severity, $f.id, $f.file, $f.message) -ForegroundColor $c
        }
    }
    Write-Host ("─" * 70)
    Write-Host ("Critical: {0}  High: {1}  Medium: {2}" -f $result.counts.critical, $result.counts.high, $result.counts.medium)
    Write-Host ""
    Write-Host "Reviewer judgment still required: is HELP.md meaningful, are any tsconfig deviations justified." -ForegroundColor DarkGray
}

exit ($(if ($result.counts.critical -gt 0) { 1 } else { 0 }))
