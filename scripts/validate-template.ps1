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

    The official template repo is the authoritative reference, selected by API version ×
    language: v2 modules use companion-module-template-{js|ts}, v1 modules use the
    "-v1"-suffixed variant. Templates are auto-detected under COMPANION_TEMPLATES_DIR
    (default companion-module-templates/ inside the repo), or passed via -TemplateDir.

    BEFORE comparing anything, the local template clone is verified against its upstream
    with a read-only `git ls-remote` — no fetch, no pull, nothing written. A clone that is
    behind upstream would judge the module against outdated expectations and produce false
    findings, so it is a blocking TEMPLATE-STALE. Templates are NEVER auto-updated here:
    concurrent review sessions share these clones, so refreshing is a separate, deliberate
    act (scripts/update-templates.ps1). The "-v1" clones sit in detached HEAD by design and
    are exempt.

    Which files get compared is derived from the template's own tracked files
    (`git ls-files`) minus module-owned paths, so a file newly added upstream is compared
    automatically instead of waiting for someone to edit a list in this script. A template
    file matching no rule still gets compared, and raises an informational
    TEMPLATE-COVERAGE so the gap can't go silent.

    One exception: .yarnrc.yml is repo tooling rather than API surface, and Bitfocus only
    updates it on main, so it is always compared against the non-"-v1" template when one
    exists — and by parsed key, not raw text (key order, quote style, and blank lines are
    not divergences; a missing/extra key or a conflicting value is).
.PARAMETER ModuleDir
    Path to the cloned module under review.
.PARAMETER TemplateDir
    Path to the matching template repo. Auto-detected by API version × language if omitted.
.PARAMETER ExpectedVersion
    The git tag under review (with or without leading 'v'). Enables the package.json
    version-match check. Skipped if omitted.
.PARAMETER RunBuild
    Also run `yarn install --immutable` + `yarn package` (and `yarn lint` for TS) and gate
    on success. Slow and requires network; off by default.
.PARAMETER SkipTemplateFreshness
    Skip the upstream freshness check (deliberate offline runs). Equivalent to setting
    COMPANION_SKIP_TEMPLATE_FRESHNESS=1.
.PARAMETER Json
    Emit findings as JSON instead of a console report.
.OUTPUTS
    Exit codes: 0 clean · 1 one or more Critical findings · 2 unusable -ModuleDir or no
    template found · 3 the template clone is stale or could not be verified.
.EXAMPLE
    pwsh scripts/validate-template.ps1 -ModuleDir ../companion-modules-reviewing/companion-module-foo
    pwsh scripts/validate-template.ps1 -ModuleDir ./mod -ExpectedVersion v1.2.0 -RunBuild -Json
#>

param(
    [Parameter(Mandatory)][string]$ModuleDir,
    [string]$TemplateDir,
    [string]$ExpectedVersion,
    [switch]$RunBuild,
    [switch]$SkipTemplateFreshness,
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

# Language detection lives in lib/ReviewState.ps1 (Test-ModuleIsTypeScript) so this script
# and module-facts.ps1 share one rule: TS = tsconfig.json OR .ts sources — NOT a `typescript`
# devDependency (a typescript-eslint peer on plain-JS modules) and NOT package.json "type": "module".
$isTs = Test-ModuleIsTypeScript $ModuleDir
$lang = if ($isTs) { 'TS' } else { 'JS' }
$langLower = $lang.ToLower()

# Detect the @companion-module/base version. The MAJOR still picks the template (1.x → the
# pinned "-v1" clone, 2.x → main). The MINOR matters too since API 2.1: the v2 templates still
# pin base 2.0.x / node22, but a 2.1 module may legitimately run on node26 — so the runtime and
# tsconfig comparisons below need to know the level, or they'd flag a correct module.
$baseInfo   = Resolve-CompanionBaseVersion $ModuleDir
$apiMajor   = $baseInfo.major
$apiVer     = "v$apiMajor"
$apiProfile = Get-CompanionApiProfile -ApiLevel $baseInfo.apiLevel
$apiAtLeast21 = ($baseInfo.major -gt 2) -or ($baseInfo.major -eq 2 -and $baseInfo.minor -ge 1)

# The module's manifest runtime is needed before §2 (the tsconfig allowance depends on it),
# so it's read here; §5 still owns parsing errors and all MAN-* findings.
$modRuntimeType = $null
try {
    $mp = Join-Path $ModuleDir 'companion/manifest.json'
    if (Test-Path $mp) {
        $mj = Get-Content -Raw -LiteralPath $mp | ConvertFrom-Json
        if ((Has-Prop $mj 'runtime') -and (Has-Prop $mj.runtime 'type')) { $modRuntimeType = [string]$mj.runtime.type }
    }
} catch { }

# ── Resolve template dir by version × language ───────────────────────────────
# Templates live in companion-module-templates/ inside the repo (override:
# COMPANION_TEMPLATES_DIR). v1 templates use a "-v1" suffix; v2 templates have none.
$tplSuffix = if ($apiMajor -le 1) { '-v1' } else { '' }
$tplName   = "companion-module-template-$langLower$tplSuffix"
if (-not $TemplateDir) {
    $base = Resolve-TemplatesDir (Split-Path -Parent $PSScriptRoot)
    $candidate = Join-Path $base $tplName
    if (Test-Path $candidate) { $TemplateDir = $candidate }
}
if (-not $TemplateDir -or -not (Test-Path $TemplateDir)) {
    Write-Error "Template '$tplName' ($lang $apiVer) not found. Run setup.ps1 to clone the templates into companion-module-templates/, set COMPANION_TEMPLATES_DIR, or pass -TemplateDir."
    exit 2
}
$TemplateDir = (Resolve-Path $TemplateDir).Path

# .yarnrc.yml is repo tooling, not API-versioned — Bitfocus updates it on main only, so a
# v1 module is judged against the current (main) template's yarnrc rather than the pinned
# v1 template's stale copy. Falls back to $TemplateDir when there's no sibling to use.
$yarnrcTemplateDir = $TemplateDir
if ($TemplateDir -match '-v1$') {
    $sibling = $TemplateDir -replace '-v1$',''
    if (Test-Path (Join-Path $sibling '.yarnrc.yml')) { $yarnrcTemplateDir = $sibling }
}

# ── 0. Template freshness — MUST run before any comparison ───────────────────
# Ordering is load-bearing: a clone that is behind upstream produces false CONFIG-DIFF /
# FILE-MISSING / PKG-DEVDEP findings against a module that is actually correct (this has
# happened — see reviews/roland-v1-4k, where a pre-hardening .yarnrc.yml clone flagged the
# module's correct `enableScripts: false` as an extra line). Establishing "the reference is
# current" first is what makes every finding below trustworthy.
#
# Strictly read-only: `git ls-remote` against the configured origin. Nothing is fetched,
# pulled, or written — several review sessions share these clones and an automatic update
# would change the reference underneath a review already in progress.
$freshnessChecks = [System.Collections.Generic.List[object]]::new()
$seenTplDirs = [System.Collections.Generic.HashSet[string]]::new()

# The check set is every clone whose contents feed an expectation:
#   - the matched template;
#   - the yarnrc source, which for a v1 module is the *v2* sibling (see above);
#   - one hop through a pinned clone's local origin, since the "-v1" clones are cloned from
#     the v2 clone — that parent is the thing that can actually fall behind GitHub.
$freshnessTargets = @($TemplateDir, $yarnrcTemplateDir)
$tplInfo = Get-GitRepoInfo -Dir $TemplateDir
if ($tplInfo.IsRepo -and $tplInfo.Detached -and $tplInfo.OriginIsLocalDir) {
    $freshnessTargets += $tplInfo.OriginLocalPath
}
foreach ($dir in $freshnessTargets) {
    if (-not $dir) { continue }
    $key = try { (Resolve-Path -LiteralPath $dir -ErrorAction Stop).Path } catch { $dir }
    if (-not $seenTplDirs.Add($key)) { continue }

    $fr = Test-TemplateFreshness -TemplateDir $dir -SkipCheck:$SkipTemplateFreshness

    # A directory that isn't a git clone can't be verified. That only matters for the
    # templates this script resolved itself — an explicitly passed -TemplateDir pointing at a
    # plain copy or a test fixture is a deliberate choice, not an unverifiable production
    # reference, so it stays silent.
    if ($fr.status -eq 'unmanaged' -and -not $PSBoundParameters.ContainsKey('TemplateDir')) {
        $fr.status = 'unverified'
    }
    $freshnessChecks.Add($fr)

    if ($fr.status -eq 'stale') {
        Add-Finding 'TEMPLATE-STALE' 'Critical' $fr.leaf (
            "Local template clone is behind upstream — this review would be judged against an " +
            "outdated template. $($fr.message) Refresh explicitly (templates are NEVER " +
            "auto-updated): pwsh scripts/update-templates.ps1 — do this between review " +
            "sessions, not during one, then re-run the review.")
    } elseif ($fr.status -eq 'unverified') {
        Add-Finding 'TEMPLATE-UNVERIFIED' 'Critical' $fr.leaf (
            "Could not verify the template clone against upstream ($($fr.message)). A review " +
            "must attest which template revision it judged against. For a deliberate offline " +
            "run pass -SkipTemplateFreshness or set COMPANION_SKIP_TEMPLATE_FRESHNESS=1.")
    }
}
$freshnessStatuses = @($freshnessChecks | ForEach-Object { $_.status })
$freshnessOverall =
    if ($freshnessStatuses -contains 'stale')       { 'stale' }
    elseif ($freshnessStatuses -contains 'unverified') { 'unverified' }
    elseif ($freshnessStatuses -contains 'skipped')    { 'skipped' }
    elseif ($freshnessStatuses -contains 'fresh')      { 'fresh' }
    elseif ($freshnessStatuses -contains 'pinned')     { 'pinned' }
    else                                               { 'unmanaged' }

# Load the template's package.json + manifest so expectations are derived from the
# actual matched template (version-correct) rather than hardcoded.
$tplPkg = $null; $tplMan = $null
$tplPkgPath = Join-Path $TemplateDir 'package.json'
if (Test-Path $tplPkgPath) { try { $tplPkg = Get-Content -Raw -LiteralPath $tplPkgPath | ConvertFrom-Json } catch { } }
$tplManPath = Join-Path $TemplateDir 'companion/manifest.json'
if (Test-Path $tplManPath) { try { $tplMan = Get-Content -Raw -LiteralPath $tplManPath | ConvertFrom-Json } catch { } }

# ── 1. Required files ────────────────────────────────────────────────────────
# Only files that are required REGARDLESS of what the template happens to track live here.
# Everything else (.gitattributes, .gitignore, .prettierignore, .yarnrc.yml, and the TS-only
# eslint.config.mjs / tsconfig*.json / .husky/pre-commit) is derived from the template's own
# file list in §2 — which also gets the JS-vs-TS split right for free, since the JS template
# genuinely tracks no .husky/ or tsconfig.
#
# yarn.lock is the reason this list can't just be "whatever the template tracks": the v2
# templates deliberately don't commit one, but every module must ship one. The remaining four
# ARE template-tracked, but their contents are judged by their own dedicated sections below
# (LICENSE-DIFF, PKG-*, MAN-*, HELP-STUB), so they appear here for the presence check only.
#
# Entry-point filename is NOT hard-required — it may differ from the template (e.g. src/index.js).
# Its validity is enforced by the package.json main / manifest runtime.entrypoint checks below
# (existence + consistency) plus the -RunBuild build step.
$requiredExtra = @('yarn.lock','LICENSE','package.json','companion/manifest.json','companion/HELP.md')
foreach ($rel in $requiredExtra) {
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

function Get-FirstLineDiff {
    # Describe the first line where two normalized files diverge, in the phrasing the
    # config-parity and LICENSE checks both report. Returns '' if they are identical.
    param([string[]]$ModuleLines, [string[]]$TemplateLines)
    $max = [math]::Max($ModuleLines.Count, $TemplateLines.Count)
    for ($i = 0; $i -lt $max; $i++) {
        $m = if ($i -lt $ModuleLines.Count) { $ModuleLines[$i] } else { '<missing>' }
        $t = if ($i -lt $TemplateLines.Count) { $TemplateLines[$i] } else { '<missing>' }
        if ($m -ne $t) { return "line $($i+1): found '$m', template '$t'" }
    }
    return ''
}

function Normalize-TsconfigLine {
    # The template ships a commented-out jest hint in the compilerOptions "types"
    # array: ["node" /* , "jest" ] // uncomment this if using jest */]. Deleting that
    # dead comment (leaving ["node"]) is an accepted divergence, not a CONFIG-DIFF — so
    # strip inline comments and normalize bracket spacing before comparing tsconfig lines.
    param([string]$Line)
    $l = $Line -replace '/\*.*?\*/', ''   # drop inline block comments (incl. the jest hint)
    $l = $l -replace '//.*$', ''          # drop trailing line comments
    $l = $l -replace '\s*\]', ']'         # collapse whitespace before a closing bracket
    return $l.TrimEnd()
}

function ConvertTo-CanonicalJson {
    # Key-order-independent JSON text for deep comparison of parsed tsconfig values.
    param($Value)
    if ($Value -is [System.Collections.IDictionary]) {
        $sorted = [ordered]@{}
        foreach ($k in @($Value.Keys | Sort-Object)) { $sorted[$k] = ConvertTo-CanonicalJson $Value[$k] }
        return ($sorted | ConvertTo-Json -Compress -Depth 20)
    }
    if ($Value -is [System.Collections.IList]) {
        return '[' + ((@($Value) | ForEach-Object { ConvertTo-CanonicalJson $_ }) -join ',') + ']'
    }
    return ($Value | ConvertTo-Json -Compress -Depth 20)
}

function Test-TsconfigDevScope {
    <# Is tsconfig.json's divergence from the template ONLY the accepted dev-scope widening?

       tsconfig.json is the editor/typecheck config; the build uses tsconfig.build.json, which
       stays an exact match. Modules that ship tests (vitest/jest) legitimately widen
       tsconfig.json so the tests and the test-runner config are type-checked too:
         - extra `include` entries (tests/**/*.ts, scripts/**/*.ts, vitest.config.ts, …)
         - extra `exclude` entries
         - extra `compilerOptions.types` entries (vitest/globals, jest, …)
         - `compilerOptions.rootDir` (widened to ./ so tests/ sit inside it) and `noEmit`
       Everything the template sets must still be present with the same value. Anything else
       — a different `extends`, a changed or new compiler option, an extra top-level key — is
       a real divergence and stays a CONFIG-DIFF.

       Returns Acceptable, Extras (what was widened, for the Info note), Reason (why not). #>
    param([Parameter(Mandatory)][string]$ModuleFile, [Parameter(Mandatory)][string]$TemplateFile)

    $res = [pscustomobject]@{ Acceptable = $false; Extras = @(); Reason = $null }
    try {
        $mod = Get-Content -Raw -LiteralPath $ModuleFile | ConvertFrom-Json -AsHashtable
        $tpl = Get-Content -Raw -LiteralPath $TemplateFile | ConvertFrom-Json -AsHashtable
    } catch {
        $res.Reason = "could not parse as JSON ($($_.Exception.Message))"
        return $res
    }
    if ($mod -isnot [System.Collections.IDictionary] -or $tpl -isnot [System.Collections.IDictionary]) {
        $res.Reason = 'not a JSON object'
        return $res
    }

    $extras = [System.Collections.Generic.List[string]]::new()
    $listKeys = @('include', 'exclude')
    $allowedExtraCompilerOptions = @('rootDir', 'noEmit')

    foreach ($k in @($mod.Keys)) {
        if (-not $tpl.Contains($k)) { $res.Reason = "extra top-level key '$k'"; return $res }
    }
    foreach ($k in @($tpl.Keys)) {
        if (-not $mod.Contains($k)) { $res.Reason = "missing template key '$k'"; return $res }
        if ($listKeys -contains $k) {
            $have = @($mod[$k] | ForEach-Object { "$_" })
            $want = @($tpl[$k] | ForEach-Object { "$_" })
            $missing = @($want | Where-Object { $have -notcontains $_ })
            if ($missing.Count -gt 0) { $res.Reason = "$k is missing template entries: $($missing -join ', ')"; return $res }
            foreach ($e in @($have | Where-Object { $want -notcontains $_ })) { $extras.Add("$k += $e") }
            continue
        }
        if ($k -eq 'compilerOptions' -and $mod[$k] -is [System.Collections.IDictionary] -and $tpl[$k] -is [System.Collections.IDictionary]) {
            $mco = $mod[$k]; $tco = $tpl[$k]
            foreach ($ok in @($tco.Keys)) {
                if (-not $mco.Contains($ok)) { $res.Reason = "compilerOptions.$ok is missing"; return $res }
                if ($ok -eq 'types') {
                    $have = @($mco[$ok] | ForEach-Object { "$_" })
                    $want = @($tco[$ok] | ForEach-Object { "$_" })
                    $missing = @($want | Where-Object { $have -notcontains $_ })
                    if ($missing.Count -gt 0) { $res.Reason = "compilerOptions.types is missing: $($missing -join ', ')"; return $res }
                    foreach ($e in @($have | Where-Object { $want -notcontains $_ })) { $extras.Add("types += $e") }
                    continue
                }
                if ((ConvertTo-CanonicalJson $mco[$ok]) -ne (ConvertTo-CanonicalJson $tco[$ok])) {
                    $res.Reason = "compilerOptions.$ok differs"; return $res
                }
            }
            foreach ($ok in @($mco.Keys | Where-Object { -not $tco.Contains($_) })) {
                if ($allowedExtraCompilerOptions -notcontains $ok) { $res.Reason = "extra compilerOptions.$ok"; return $res }
                $extras.Add("compilerOptions.$ok = $(ConvertTo-CanonicalJson $mco[$ok])")
            }
            continue
        }
        if ((ConvertTo-CanonicalJson $mod[$k]) -ne (ConvertTo-CanonicalJson $tpl[$k])) {
            $res.Reason = "'$k' differs"; return $res
        }
    }
    $res.Acceptable = $true
    $res.Extras = @($extras)
    return $res
}

function Remove-JsComments {
    # Strip // and /* */ comments from JS source while leaving string contents alone, so the
    # eslint-config comparison below isn't thrown by explanatory comments in an override.
    param([string]$Text)
    $sb = [System.Text.StringBuilder]::new()
    $i = 0; $n = $Text.Length; $quote = $null
    while ($i -lt $n) {
        $c = $Text[$i]
        if ($quote) {
            [void]$sb.Append($c)
            if ($c -eq '\' -and $i + 1 -lt $n) { [void]$sb.Append($Text[$i + 1]); $i += 2; continue }
            if ($c -eq $quote) { $quote = $null }
            $i++; continue
        }
        if ($c -eq "'" -or $c -eq '"' -or $c -eq '`') { $quote = $c; [void]$sb.Append($c); $i++; continue }
        if ($c -eq '/' -and $i + 1 -lt $n -and $Text[$i + 1] -eq '/') {
            while ($i -lt $n -and $Text[$i] -ne "`n") { $i++ }
            continue
        }
        if ($c -eq '/' -and $i + 1 -lt $n -and $Text[$i + 1] -eq '*') {
            $end = $Text.IndexOf('*/', $i + 2)
            $i = if ($end -lt 0) { $n } else { $end + 2 }
            continue
        }
        [void]$sb.Append($c); $i++
    }
    return $sb.ToString()
}

function Split-JsTopLevel {
    # Split the inside of a JS array/object literal on commas at nesting depth 0.
    param([string]$Text)
    $parts = [System.Collections.Generic.List[string]]::new()
    $depth = 0; $quote = $null; $start = 0
    for ($i = 0; $i -lt $Text.Length; $i++) {
        $c = $Text[$i]
        if ($quote) {
            if ($c -eq '\') { $i++; continue }
            if ($c -eq $quote) { $quote = $null }
            continue
        }
        if ($c -eq "'" -or $c -eq '"' -or $c -eq '`') { $quote = $c; continue }
        if ('([{'.Contains($c)) { $depth++; continue }
        if (')]}'.Contains($c)) { $depth--; continue }
        if ($c -eq ',' -and $depth -eq 0) { $parts.Add($Text.Substring($start, $i - $start).Trim()); $start = $i + 1 }
    }
    $last = $Text.Substring($start).Trim()
    if ($last) { $parts.Add($last) }
    return @($parts | Where-Object { $_ })
}

function Get-JsBracketBody {
    # Given text and the index of an opening bracket, return what lies between it and its
    # matching close (string-aware), or $null if unbalanced.
    param([string]$Text, [int]$OpenIndex)
    $open = $Text[$OpenIndex]
    $close = switch ($open) { '[' { ']' } '{' { '}' } '(' { ')' } }
    $depth = 0; $quote = $null
    for ($i = $OpenIndex; $i -lt $Text.Length; $i++) {
        $c = $Text[$i]
        if ($quote) {
            if ($c -eq '\') { $i++; continue }
            if ($c -eq $quote) { $quote = $null }
            continue
        }
        if ($c -eq "'" -or $c -eq '"' -or $c -eq '`') { $quote = $c; continue }
        if ($c -eq $open) { $depth++ }
        elseif ($c -eq $close) { $depth--; if ($depth -eq 0) { return $Text.Substring($OpenIndex + 1, $i - $OpenIndex - 1) } }
    }
    return $null
}

function Test-EslintTestScope {
    <# Is eslint.config.mjs's divergence from the template ONLY test-scoped overrides?

       Modules that ship tests usually relax a couple of rules for test files (e.g.
       n/no-unpublished-import for vitest imports, unbound-method for vi.fn() assertions).
       Doing that requires turning the template's

           export default generateEslintConfig({ …options… })

       into

           const baseConfig = await generateEslintConfig({ …same options… })
           export default [ ...baseConfig, { files: ['tests/**/*.ts'], rules: { … } } ]

       Accepted ONLY when: the template's import lines are all present and no others are added;
       the generateEslintConfig options are identical; the base config is spread first; and every
       extra entry is an object whose `files` globs are all test/tooling paths, using only the
       keys files / rules / languageOptions / name. So nothing can change how the module's own
       src/ code is linted. Anything else stays a CONFIG-DIFF. #>
    param([Parameter(Mandatory)][string]$ModuleFile, [Parameter(Mandatory)][string]$TemplateFile)

    $res = [pscustomobject]@{ Acceptable = $false; Extras = @(); Reason = $null }
    $mod = Remove-JsComments (Get-Content -Raw -LiteralPath $ModuleFile)
    $tpl = Remove-JsComments (Get-Content -Raw -LiteralPath $TemplateFile)
    $squash = { param($s) ($s -replace '\s+', ' ').Trim() -replace ',\s*([}\]])', '$1' }

    # Template must be the plain `export default generateEslintConfig({...})` shape.
    $tplCall = [regex]::Match($tpl, 'export\s+default\s+generateEslintConfig\s*\(')
    if (-not $tplCall.Success) { $res.Reason = 'template eslint config has an unexpected shape'; return $res }
    $tplOpts = Get-JsBracketBody $tpl ($tplCall.Index + $tplCall.Length - 1)

    # Imports: exactly the template's.
    $importsOf = { param($s) @([regex]::Matches($s, '(?m)^\s*import\s[^\n]*') | ForEach-Object { & $squash $_.Value } | Sort-Object) }
    $tplImports = & $importsOf $tpl
    $modImports = & $importsOf $mod
    if (($tplImports -join "`n") -ne ($modImports -join "`n")) { $res.Reason = 'imports differ from the template'; return $res }

    # const <name> = await generateEslintConfig({ same options })
    $modCall = [regex]::Match($mod, '(?:const|let)\s+([A-Za-z_$][\w$]*)\s*=\s*(?:await\s+)?generateEslintConfig\s*\(')
    if (-not $modCall.Success) { $res.Reason = 'generateEslintConfig result is not assigned to a variable'; return $res }
    $baseVar = $modCall.Groups[1].Value
    $modOpts = Get-JsBracketBody $mod ($modCall.Index + $modCall.Length - 1)
    if ($null -eq $modOpts -or (& $squash $modOpts) -ne (& $squash $tplOpts)) { $res.Reason = 'generateEslintConfig options differ from the template'; return $res }

    # export default [ ...<name>, {test-scoped override}, … ]  — or the equivalent
    # `const <cfg> = [ … ]` + `export default <cfg>`.
    $spans = [System.Collections.Generic.List[object]]::new()
    $constOpen = $modCall.Index + $modCall.Length - 1
    $spans.Add(@($modCall.Index, ($constOpen + $modOpts.Length + 2)))
    $exp = [regex]::Match($mod, 'export\s+default\s*\[')
    if ($exp.Success) {
        $arrOpen = $exp.Index + $exp.Length - 1
        $arr = Get-JsBracketBody $mod $arrOpen
        if ($null -eq $arr) { $res.Reason = 'unbalanced export default array'; return $res }
        $spans.Add(@($exp.Index, ($arrOpen + $arr.Length + 2)))
    } else {
        $expId = [regex]::Match($mod, 'export\s+default\s+([A-Za-z_$][\w$]*)\s*;?')
        if (-not $expId.Success) { $res.Reason = 'export default is not an array'; return $res }
        $decl = [regex]::Match($mod, "(?:const|let)\s+$([regex]::Escape($expId.Groups[1].Value))\s*=\s*\[")
        if (-not $decl.Success) { $res.Reason = "export default $($expId.Groups[1].Value) is not an array literal"; return $res }
        $arrOpen = $decl.Index + $decl.Length - 1
        $arr = Get-JsBracketBody $mod $arrOpen
        if ($null -eq $arr) { $res.Reason = 'unbalanced exported array'; return $res }
        $spans.Add(@($decl.Index, ($arrOpen + $arr.Length + 2)))
        $spans.Add(@($expId.Index, ($expId.Index + $expId.Length)))
    }

    # Nothing else may sit at the top level besides the imports, the base config and the
    # exported array: cut those spans out by position (later first) and require only
    # whitespace/';' to remain.
    $rest = $mod
    foreach ($span in @($spans | Sort-Object { $_[0] } -Descending)) {
        $rest = $rest.Substring(0, $span[0]) + $rest.Substring([math]::Min($span[1], $rest.Length))
    }
    $rest = [regex]::Replace($rest, '(?m)^\s*import\s[^\n]*', '')
    if (($rest -replace '[\s;]', '') -ne '') { $res.Reason = 'extra top-level code besides the base config and overrides'; return $res }

    $items = @(Split-JsTopLevel $arr)
    if ($items.Count -lt 1 -or $items[0] -ne "...$baseVar") { $res.Reason = "the base config (...$baseVar) is not spread first"; return $res }

    $testGlob = '^(\./)?((tests?|__tests__|__mocks__|spec|specs|scripts)/|[^/]*\.config\.(c|m)?(js|ts)$)|\.(test|spec)\.(c|m)?(js|ts)x?$'
    $allowedKeys = @('files', 'rules', 'languageOptions', 'name')
    $extras = [System.Collections.Generic.List[string]]::new()
    foreach ($item in @($items | Select-Object -Skip 1)) {
        if (-not $item.StartsWith('{')) { $res.Reason = "override '$((& $squash $item))' is not an object literal"; return $res }
        $body = Get-JsBracketBody $item 0
        $props = @(Split-JsTopLevel $body)
        $keys = @($props | ForEach-Object { if ($_ -match '^[''"]?([A-Za-z_$][\w$]*)[''"]?\s*:') { $Matches[1] } else { '<' + (& $squash $_) + '>' } })
        $bad = @($keys | Where-Object { $allowedKeys -notcontains $_ })
        if ($bad.Count -gt 0) { $res.Reason = "override uses non-test-scoped key(s): $($bad -join ', ')"; return $res }
        $filesProp = @($props | Where-Object { $_ -match '^[''"]?files[''"]?\s*:' }) | Select-Object -First 1
        if (-not $filesProp) { $res.Reason = 'override has no files: scope, so it would apply to src/'; return $res }
        $globs = @([regex]::Matches($filesProp, '''([^'']*)''|"([^"]*)"') | ForEach-Object { if ($_.Groups[1].Success) { $_.Groups[1].Value } else { $_.Groups[2].Value } })
        if ($globs.Count -eq 0) { $res.Reason = 'override files: has no string globs'; return $res }
        $notTest = @($globs | Where-Object { $_ -notmatch $testGlob })
        if ($notTest.Count -gt 0) { $res.Reason = "override targets non-test files: $($notTest -join ', ')"; return $res }
        $extras.Add("files [$($globs -join ', ')]")
    }
    $res.Acceptable = $true
    $res.Extras = @($extras)
    return $res
}

function Read-YarnrcMap {
    # .yarnrc.yml is a flat, two-level file in practice (scalars plus the occasional
    # block sequence such as npmPreapprovedPackages), so a small hand-rolled parser is
    # enough and keeps this script dependency-free. Comparing parsed keys instead of raw
    # text means key order, quote style, and blank lines never produce a CONFIG-DIFF.
    param([string]$Path)
    $map = [ordered]@{}
    if (-not (Test-Path $Path)) { return $map }
    $text = Get-Content -Raw -LiteralPath $Path
    if ($null -eq $text) { return $map }

    function Get-Scalar {
        param([string]$Value)
        $v = $Value.Trim()
        if ($v.Length -ge 2) {
            $q = $v[0]
            if (($q -eq '"' -or $q -eq "'") -and $v[-1] -eq $q) { $v = $v.Substring(1, $v.Length - 2) }
        }
        return $v
    }

    $seq = @{}          # key -> list of sequence items
    $currentKey = $null
    foreach ($raw in ($text -split "`r?`n")) {
        $line = $raw -replace '\s+#.*$', ''      # trailing comment
        if ($line.Trim() -eq '' -or $line.TrimStart().StartsWith('#')) { continue }
        if ($line -match '^\s+-\s*(.+)$') {
            if ($currentKey -and $seq.ContainsKey($currentKey)) { $seq[$currentKey] += ,(Get-Scalar $Matches[1]) }
            continue
        }
        if ($line -match '^(\S[^:]*):\s*(.*)$') {
            $currentKey = $Matches[1].Trim()
            $value = $Matches[2]
            if ($value.Trim() -eq '') {
                $seq[$currentKey] = @()          # block key; items follow
                $map[$currentKey] = ''
            } else {
                $map[$currentKey] = Get-Scalar $value
            }
        }
    }
    # Sequences compare as a sorted set, so item order doesn't matter either.
    foreach ($k in @($seq.Keys)) {
        $map[$k] = '[' + ((@($seq[$k]) | Sort-Object) -join ', ') + ']'
    }
    return $map
}

function Get-TemplateTrackedFiles {
    # The set of files to compare is the template's own tracked file list, not a list
    # maintained by hand in this script — so a config file Bitfocus adds upstream is compared
    # on the next review instead of silently going unchecked until someone notices.
    param([Parameter(Mandatory)][string]$Dir)

    $tracked = Invoke-GitRead @('-C', $Dir, 'ls-files')
    if ($null -ne $tracked -and $tracked -ne '') {
        return @($tracked -split "`r?`n" | Where-Object { $_ } | Sort-Object -Unique)
    }
    # Not a git clone (a plain copy, or a test fixture): fall back to walking the tree.
    $root = (Resolve-Path -LiteralPath $Dir).Path.TrimEnd([IO.Path]::DirectorySeparatorChar)
    $files = @(Get-ChildItem -LiteralPath $Dir -Recurse -File -Force -ErrorAction SilentlyContinue |
        ForEach-Object { $_.FullName.Substring($root.Length + 1) -replace '\\', '/' } |
        Where-Object { $_ -notlike '.git/*' -and $_ -notlike 'node_modules/*' })
    return @($files | Sort-Object -Unique)
}

# How each template-tracked path is judged. FIRST MATCH WINS, so order matters.
#   exact             byte-for-byte after whitespace normalization
#   tsconfig          exact, after stripping comments (the template's jest hint is optional)
#   gitignore-subset  every template entry must be present; module extras are fine
#   yarnrc            parsed key/value comparison, sourced from the v2 template
#   covered-elsewhere a dedicated section below owns this file's content
#   module-owned      legitimately differs per module; never compared
#   skip-binary       not text; a line diff would be meaningless
# A path matching NO row is still compared (as 'exact') but raises TEMPLATE-COVERAGE, so a
# newly-added template file can never slip through unjudged.
$templateFileRules = @(
    @{ Pattern = '.yarnrc.yml';             Kind = 'yarnrc';           Severity = 'Critical'; Source = 'yarnrc' }
    @{ Pattern = '.gitignore';              Kind = 'gitignore-subset'; Severity = 'Critical' }
    @{ Pattern = 'tsconfig*.json';          Kind = 'tsconfig';         Severity = 'Critical' }
    @{ Pattern = '.gitattributes';          Kind = 'exact';            Severity = 'Critical' }
    @{ Pattern = '.prettierignore';         Kind = 'exact';            Severity = 'Critical' }
    @{ Pattern = 'eslint.config.mjs';       Kind = 'exact';            Severity = 'Critical' }
    @{ Pattern = '.husky/*';                Kind = 'exact';            Severity = 'Critical' }
    # CI workflows and issue templates are compared, but at Medium: the usual divergence is
    # GitHub Action pin churn (actions/checkout@v4 vs the template's @v7), which is not
    # something the module maintainer did wrong and must not block a release.
    @{ Pattern = '.github/*';               Kind = 'exact';            Severity = 'Medium' }
    @{ Pattern = 'LICENSE';                 Kind = 'covered-elsewhere' }   # §3b LICENSE-DIFF
    @{ Pattern = 'package.json';            Kind = 'covered-elsewhere' }   # §4 PKG-*
    @{ Pattern = 'companion/manifest.json'; Kind = 'covered-elsewhere' }   # §5 MAN-*
    @{ Pattern = 'companion/HELP.md';       Kind = 'covered-elsewhere' }   # §6 HELP-STUB
    @{ Pattern = 'README.md';               Kind = 'module-owned' }
    @{ Pattern = 'src/*';                   Kind = 'module-owned' }
    @{ Pattern = 'yarn.lock';               Kind = 'module-owned' }        # js-v1 tracks it; per-module by nature
    @{ Pattern = '*.png';                   Kind = 'skip-binary' }
    @{ Pattern = '*.jpg';                   Kind = 'skip-binary' }
    @{ Pattern = '*.ico';                   Kind = 'skip-binary' }
    @{ Pattern = '*.gif';                   Kind = 'skip-binary' }
    @{ Pattern = '*.webp';                  Kind = 'skip-binary' }
    @{ Pattern = '*.zip';                   Kind = 'skip-binary' }
)

function Resolve-TemplateFileRule {
    param([Parameter(Mandatory)][string]$Rel)
    foreach ($r in $templateFileRules) {
        if ($Rel -like $r.Pattern) {
            return [pscustomobject]@{
                Kind      = $r.Kind
                Severity  = if ($r.ContainsKey('Severity')) { $r.Severity } else { 'Critical' }
                Source    = if ($r.ContainsKey('Source'))   { $r.Source }   else { 'template' }
                Defaulted = $false
            }
        }
    }
    return [pscustomobject]@{ Kind = 'exact'; Severity = 'Critical'; Source = 'template'; Defaulted = $true }
}

foreach ($rel in (Get-TemplateTrackedFiles -Dir $TemplateDir)) {
    $rule = Resolve-TemplateFileRule $rel
    if ($rule.Kind -in @('module-owned', 'covered-elsewhere', 'skip-binary')) { continue }

    # .yarnrc.yml comes from the main template even for v1 modules (see $yarnrcTemplateDir).
    $tplFile = if ($rule.Source -eq 'yarnrc') { Join-Path $yarnrcTemplateDir $rel } else { Join-Path $TemplateDir $rel }
    if (-not (Test-Path $tplFile)) { continue }   # template lacks it; nothing to compare

    $modFile = Join-Path $ModuleDir $rel
    if (-not (Test-Path $modFile)) {
        # Presence and content are decided in one pass so a missing file is reported once,
        # as FILE-MISSING, and never also as a CONFIG-DIFF against an empty file.
        Add-Finding 'FILE-MISSING' $rule.Severity $rel 'Required file is missing (tracked by the template)'
        continue
    }
    if ($rule.Defaulted) {
        Add-Finding 'TEMPLATE-COVERAGE' 'Info' $rel (
            "Template tracks this file but validate-template.ps1 has no explicit rule for it — " +
            "compared by exact normalized text as a fallback. Add a row to `$templateFileRules " +
            "in scripts/validate-template.ps1 and a case to the compliance skill's finding table.")
    }
    if ($rule.Kind -eq 'yarnrc') {
        # Key-level comparison: the module must carry exactly the template's keys with
        # matching values. Missing keys drop the template's supply-chain hardening;
        # conflicting values and extra keys change install behaviour for everyone.
        $modMap = Read-YarnrcMap $modFile
        $tplMap = Read-YarnrcMap $tplFile
        if ($modMap.Count -eq 0 -and (Read-NormalizedLines $modFile).Count -gt 0) {
            Add-Finding 'CONFIG-DIFF' $rule.Severity $rel 'Could not parse .yarnrc.yml as YAML key/value pairs'
            continue
        }
        $missingKeys = @($tplMap.Keys | Where-Object { -not $modMap.Contains($_) })
        if ($missingKeys.Count -gt 0) {
            Add-Finding 'CONFIG-DIFF' $rule.Severity $rel "Missing template keys: $($missingKeys -join ', ')"
        }
        $mismatches = @($tplMap.Keys | Where-Object { $modMap.Contains($_) -and $modMap[$_] -ne $tplMap[$_] } |
            ForEach-Object { "$_ = '$($modMap[$_])' (template '$($tplMap[$_])')" })
        if ($mismatches.Count -gt 0) {
            Add-Finding 'CONFIG-DIFF' $rule.Severity $rel "Value mismatch: $($mismatches -join '; ')"
        }
        $extraKeys = @($modMap.Keys | Where-Object { -not $tplMap.Contains($_) })
        if ($extraKeys.Count -gt 0) {
            Add-Finding 'CONFIG-DIFF' $rule.Severity $rel "Extra keys not in template: $($extraKeys -join ', ')"
        }
        continue
    }
    $modLines = @(Read-NormalizedLines $modFile)
    $tplLines = @(Read-NormalizedLines $tplFile)
    if ($rule.Kind -eq 'tsconfig') {
        $modLines = @($modLines | ForEach-Object { Normalize-TsconfigLine $_ })
        $tplLines = @($tplLines | ForEach-Object { Normalize-TsconfigLine $_ })
    }
    if ($rule.Kind -eq 'gitignore-subset') {
        # Subset rule: every template entry must be present in the module's .gitignore.
        # Extra module entries are allowed and not flagged. Blank and comment lines in
        # the template are not entries, so they're skipped.
        $missing = @($tplLines | Where-Object {
            $_ -ne '' -and -not $_.StartsWith('#') -and ($modLines -notcontains $_)
        })
        if ($missing.Count -gt 0) {
            Add-Finding 'CONFIG-DIFF' $rule.Severity $rel "Missing template .gitignore entries: $($missing -join ', ')"
        }
        continue
    }
    if (($modLines -join "`n") -ne ($tplLines -join "`n")) {
        # Accepted deviation: tsconfig.json (NOT tsconfig.build.json, which drives the build)
        # may be widened so tests and the test-runner config are type-checked — extra
        # include/exclude/types entries plus rootDir/noEmit. See Test-TsconfigDevScope.
        if ($rule.Kind -eq 'tsconfig' -and $rel -eq 'tsconfig.json') {
            $dev = Test-TsconfigDevScope -ModuleFile $modFile -TemplateFile $tplFile
            if ($dev.Acceptable) {
                if ($dev.Extras.Count -gt 0) {
                    Add-Finding 'TSCONFIG-DEV-SCOPE' 'Info' $rel (
                        "Widens the editor/typecheck config beyond the template ($($dev.Extras -join '; ')) — " +
                        "an accepted deviation for type-checking tests; the build config is compared separately.")
                }
                continue
            }
            Add-Finding 'CONFIG-DIFF' $rule.Severity $rel "Differs from template ($($dev.Reason); $(Get-FirstLineDiff $modLines $tplLines))"
            continue
        }
        # Accepted deviation: eslint.config.mjs may add rule overrides scoped to test/tooling
        # files only (the base config and its options unchanged). See Test-EslintTestScope.
        if ($rel -eq 'eslint.config.mjs') {
            $es = Test-EslintTestScope -ModuleFile $modFile -TemplateFile $tplFile
            if ($es.Acceptable) {
                if ($es.Extras.Count -gt 0) {
                    Add-Finding 'ESLINT-TEST-SCOPE' 'Info' $rel (
                        "Adds lint overrides scoped to test/tooling files only ($($es.Extras -join '; ')) — " +
                        "an accepted deviation; the template's base config and options are unchanged.")
                }
                continue
            }
            Add-Finding 'CONFIG-DIFF' $rule.Severity $rel "Differs from template ($($es.Reason); $(Get-FirstLineDiff $modLines $tplLines))"
            continue
        }
        # API 2.1 allowance: the v2 templates still extend tools' node22 preset, but a 2.1
        # module that moved its manifest runtime to node26 is expected to extend the node26
        # preset instead. If swapping that ONE preset reference makes the file identical, it
        # is the documented upgrade path, not a divergence — an Info note, not a Critical.
        # Anything else that differs still raises CONFIG-DIFF, and a 2.0 module gets no
        # allowance (node26 needs base >= 2.1; §5 flags its runtime separately).
        $node26Preset = '@companion-module/tools/tsconfig/node26/recommended(?:\.json)?'
        $tplPreset = @($tplLines | ForEach-Object { if ($_ -match '(@companion-module/tools/tsconfig/node22/[A-Za-z0-9_-]+(?:\.json)?)') { $Matches[1] } }) | Select-Object -First 1
        if ($rule.Kind -eq 'tsconfig' -and $apiAtLeast21 -and $modRuntimeType -eq 'node26' -and $tplPreset -and
            (($modLines -join "`n") -match $node26Preset)) {
            $swapped = @($modLines | ForEach-Object { $_ -replace $node26Preset, $tplPreset })
            if (($swapped -join "`n") -eq ($tplLines -join "`n")) {
                Add-Finding 'TSCONFIG-NODE26' 'Info' $rel (
                    "Extends the node26 tools preset where the template extends '$tplPreset'. Expected for an " +
                    "API $($baseInfo.apiLevel) module whose manifest runtime is node26 — not a divergence.")
                continue
            }
        }
        Add-Finding 'CONFIG-DIFF' $rule.Severity $rel "Differs from template ($(Get-FirstLineDiff $modLines $tplLines))"
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

# ── 3b. LICENSE must match the template exactly ──────────────────────────────
# The template's LICENSE is the licence Bitfocus ships for every module, copyright line
# included — it is not a scaffold with placeholders to fill in. So this is a plain exact
# match: a different licence body, or a different copyright holder/year, is a divergence.
# Line endings and trailing whitespace are normalized away by Read-NormalizedLines, so a
# CRLF checkout of the correct text is not a finding.
$modLicense = Join-Path $ModuleDir 'LICENSE'
$tplLicense = Join-Path $TemplateDir 'LICENSE'
if ((Test-Path $modLicense) -and (Test-Path $tplLicense)) {
    $modL = @(Read-NormalizedLines $modLicense)
    $tplL = @(Read-NormalizedLines $tplLicense)
    if (($modL -join "`n") -ne ($tplL -join "`n")) {
        Add-Finding 'LICENSE-DIFF' 'High' 'LICENSE' "Differs from template ($(Get-FirstLineDiff $modL $tplL))"
    }
}

# ── 3c. Source files must live in src/ (none at the module root) ──────────────
# Tool config files (vitest.config.ts, vite.config.ts, jest.config.js, prettier.config.js, …)
# are not module source: the tools look for them at the repo root, so that is where they must
# live. Anything named <tool>.config.<js|ts> is exempt; every other root .js/.ts is flagged.
$rootSrc = @(Get-ChildItem -LiteralPath $ModuleDir -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Extension -in @('.js', '.ts') -and $_.Name -notmatch '^[A-Za-z0-9_-]+(\.[A-Za-z0-9_-]+)*\.config\.(js|ts)$' })
foreach ($f in $rootSrc) {
    Add-Finding 'SRC-AT-ROOT' 'Critical' $f.Name "Source file at module root — all source must be under src/"
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
    # main need not match the template filename, but if present it must reference an existing
    # entry file. Build outputs under dist/ are absent in a source checkout (the build step
    # validates those), so they are not existence-checked here.
    if ((Has-Prop $pkg 'main') -and "$($pkg.main)" -notmatch '(^|/)dist/') {
        if (-not (Test-Path (Join-Path $ModuleDir $pkg.main))) {
            Add-Finding 'PKG-MAIN' 'Critical' 'package.json' "main '$($pkg.main)' references a file that does not exist"
        }
    }
    if ((Has-Prop $pkg 'repository') -and (Has-Prop $pkg.repository 'url') -and $pkg.repository.url -ne $expectedRepo) {
        Add-Finding 'PKG-REPO' 'Critical' 'package.json' "repository.url '$($pkg.repository.url)' should be '$expectedRepo'"
    }
    # Required top-level fields = those present in the matched template (version-correct).
    $candidateFields = @('engines','prettier','packageManager','license','main','scripts','dependencies')
    foreach ($field in $candidateFields) {
        if ($tplPkg -and (Has-Prop $tplPkg $field) -and -not (Has-Prop $pkg $field)) {
            Add-Finding 'PKG-FIELD' 'Critical' 'package.json' "Missing required field '$field' (present in template)"
        }
    }
    # packageManager: must match the template's package manager + major (e.g. yarn@4).
    if ($tplPkg -and (Has-Prop $tplPkg 'packageManager') -and (Has-Prop $pkg 'packageManager')) {
        $wantPrefix = if ("$($tplPkg.packageManager)" -match '^([^@]+@\d+)') { $Matches[1] } else { "$($tplPkg.packageManager)" }
        if ($pkg.packageManager -notmatch ('^' + [regex]::Escape($wantPrefix))) {
            Add-Finding 'PKG-YARN' 'Critical' 'package.json' "packageManager '$($pkg.packageManager)' should start with '$wantPrefix'"
        }
    }
    # Required scripts = the template's script names.
    $reqScripts = if ($tplPkg -and (Has-Prop $tplPkg 'scripts')) {
        @($tplPkg.scripts.PSObject.Properties.Name)
    } elseif ($isTs) {
        @('format','package','build','build:main','dev','lint','lint:raw','postinstall')
    } else {
        @('format','package')
    }
    foreach ($s in $reqScripts) {
        if (-not ((Has-Prop $pkg 'scripts') -and (Has-Prop $pkg.scripts $s))) {
            Add-Finding 'PKG-SCRIPT' 'Critical' 'package.json' "Missing required script '$s'"
        }
    }
    if (-not ((Has-Prop $pkg 'dependencies') -and (Has-Prop $pkg.dependencies '@companion-module/base'))) {
        Add-Finding 'PKG-DEP' 'Critical' 'package.json' "Missing dependency '@companion-module/base'"
    }
    # devDependencies = every dev dep present in the matched template (version-correct).
    if ($tplPkg -and (Has-Prop $tplPkg 'devDependencies')) {
        foreach ($dd in @($tplPkg.devDependencies.PSObject.Properties.Name)) {
            if (-not ((Has-Prop $pkg 'devDependencies') -and (Has-Prop $pkg.devDependencies $dd))) {
                Add-Finding 'PKG-DEVDEP' 'Critical' 'package.json' "Missing devDependency '$dd' (present in template)"
            }
        }
    }
    # lint-staged section required if the template has it (TS).
    if ($tplPkg -and (Has-Prop $tplPkg 'lint-staged') -and -not (Has-Prop $pkg 'lint-staged')) {
        Add-Finding 'PKG-LINTSTAGED' 'Critical' 'package.json' "Missing 'lint-staged' section (present in template)"
    }
}

# ── 5. manifest.json rules ───────────────────────────────────────────────────
$manifestPath = Join-Path $ModuleDir 'companion/manifest.json'
if (Test-Path $manifestPath) {
    $man = $null
    try { $man = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json }
    catch { Add-Finding 'MAN-PARSE' 'Critical' 'companion/manifest.json' "Not valid JSON: $($_.Exception.Message)" }
    if ($man) {
        # NOTE: manifest `name` is the human-facing module name and is *expected* to differ
        # from the slug `id` (e.g. id "fblab-bpm2osc" / name "BPM2OSC"). Do not reinstate an
        # id == name check here — it is not a Bitfocus requirement.
        $moduleName = (Split-Path $ModuleDir -Leaf) -replace '^companion-module-',''
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
        # manifest.type: required only if the matched template has it (v2 'connection'; absent in v1).
        if ($tplMan -and (Has-Prop $tplMan 'type')) {
            if (-not (Has-Prop $man 'type')) {
                Add-Finding 'MAN-TYPE' 'Critical' 'companion/manifest.json' "Missing 'type' (template requires '$($tplMan.type)')"
            } elseif ($man.type -ne $tplMan.type) {
                Add-Finding 'MAN-TYPE' 'Critical' 'companion/manifest.json' "type '$($man.type)' should be '$($tplMan.type)'"
            }
        }
        # runtime.type / runtime.api must match the template (lang+version specific).
        # One exception for v2: runtime.type is judged against the API level's allowed runtimes
        # (plus whatever the template pins), not the template alone. The v2 templates still say
        # node22, yet API 2.1 added node26 — comparing to the template would flag every 2.1
        # module that took the documented node26 upgrade. A 2.0 module on node26 is still a
        # Critical, with a message that says why (node26 needs base >= 2.1, Companion 5.0+).
        # v1 keeps the plain template comparison (allowedRuntimes is $null for v1).
        if ($tplMan -and (Has-Prop $tplMan 'runtime') -and (Has-Prop $man 'runtime')) {
            foreach ($rp in @('type','api')) {
                if (-not ((Has-Prop $tplMan.runtime $rp) -and (Has-Prop $man.runtime $rp))) { continue }
                $have = "$($man.runtime.$rp)"; $want = "$($tplMan.runtime.$rp)"
                if ($rp -eq 'type' -and $null -ne $apiProfile.allowedRuntimes) {
                    $allowed = @(@($apiProfile.allowedRuntimes) + $want | Sort-Object -Unique)
                    if ($allowed -contains $have) { continue }
                    $msg = if ($have -eq 'node26') {
                        "runtime.type 'node26' requires @companion-module/base >= 2.1 (Companion 5.0+); this module resolves to $($baseInfo.version) (API $($baseInfo.apiLevel)). Use 'node22' or upgrade base to ~2.1.x"
                    } else {
                        "runtime.type '$have' should be one of: $($allowed -join ', ') (API $($baseInfo.apiLevel))"
                    }
                    Add-Finding 'MAN-RUNTIME' 'Critical' 'companion/manifest.json' $msg
                    continue
                }
                if ($have -ne $want) {
                    Add-Finding 'MAN-RUNTIME' 'Critical' 'companion/manifest.json' "runtime.$rp '$have' should be '$want'"
                }
            }
        }
        # runtime.entrypoint need NOT match the template filename. It must reference an existing
        # file (dist/ build outputs are skipped — absent until built) and resolve to the same
        # file as package.json main.
        if ((Has-Prop $man 'runtime') -and (Has-Prop $man.runtime 'entrypoint')) {
            $entryRel  = "$($man.runtime.entrypoint)"
            $entryFull = [System.IO.Path]::GetFullPath((Join-Path (Join-Path $ModuleDir 'companion') $entryRel))
            if ($entryRel -notmatch '(^|/)dist/' -and -not (Test-Path $entryFull)) {
                Add-Finding 'MAN-RUNTIME' 'Critical' 'companion/manifest.json' "runtime.entrypoint '$entryRel' references a file that does not exist"
            }
            if (Has-Prop $pkg 'main') {
                $mainFull = [System.IO.Path]::GetFullPath((Join-Path $ModuleDir "$($pkg.main)"))
                if ($mainFull -ne $entryFull) {
                    Add-Finding 'ENTRY-MISMATCH' 'Critical' 'companion/manifest.json' "runtime.entrypoint '$entryRel' and package.json main '$($pkg.main)' resolve to different files"
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
# The hook is now also content-compared in §2 (the template tracks it), so a hook that
# diverges *and* drops lint-staged would otherwise be reported twice for the same line.
# The CONFIG-DIFF is the more actionable of the two, so it wins.
if ($isTs) {
    $hook = Join-Path $ModuleDir '.husky/pre-commit'
    $alreadyReported = @($findings | Where-Object { $_.id -eq 'CONFIG-DIFF' -and $_.file -eq '.husky/pre-commit' }).Count -gt 0
    if ((Test-Path $hook) -and -not $alreadyReported) {
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
function Get-RevisionRecord {
    # Which template revision this verdict was rendered against — recorded so a finished
    # review is self-attesting and a disputed finding can be re-checked at that exact commit.
    param([Parameter(Mandatory)][string]$Dir)
    $i = Get-GitRepoInfo -Dir $Dir
    return [pscustomobject]@{
        dir         = $Dir
        leaf        = (Split-Path $Dir -Leaf)
        sha         = $i.Sha
        shortSha    = $i.ShortSha
        committedAt = if ($i.CommittedAt) { ($i.CommittedAt -split 'T')[0] } else { $null }
        branch      = $i.Branch
        pinned      = [bool]$i.Detached
    }
}

$result = [pscustomobject]@{
    moduleDir         = $ModuleDir
    templateDir       = $TemplateDir
    language          = $lang
    apiVersion        = $apiVer
    apiLevel          = $baseInfo.apiLevel
    baseVersion       = $baseInfo.version
    baseVersionSource = $baseInfo.source
    templateFreshness = [pscustomobject]@{ status = $freshnessOverall; checks = @($freshnessChecks) }
    templateRevision  = Get-RevisionRecord -Dir $TemplateDir
    yarnrcTemplate    = if ($yarnrcTemplateDir -ne $TemplateDir) { Get-RevisionRecord -Dir $yarnrcTemplateDir } else { $null }
    findings          = $findings
    counts            = [pscustomobject]@{
        critical = @($findings | Where-Object severity -eq 'Critical').Count
        high     = @($findings | Where-Object severity -eq 'High').Count
        medium   = @($findings | Where-Object severity -eq 'Medium').Count
        info     = @($findings | Where-Object severity -eq 'Info').Count
    }
}

if ($Json) {
    # Depth 8: templateFreshness.checks[] nests a level deeper than the old shape, and
    # ConvertTo-Json silently stringifies anything past the limit.
    $result | ConvertTo-Json -Depth 8
} else {
    $frColor = switch ($freshnessOverall) { 'fresh' { 'Green' } 'pinned' { 'Green' } 'skipped' { 'DarkYellow' } default { 'Red' } }
    Write-Host ""
    Write-Host "validate-template — $lang module ($apiVer, API $($baseInfo.apiLevel); base $($baseInfo.version) from $($baseInfo.source))" -ForegroundColor Cyan
    Write-Host "  module:   $ModuleDir"
    Write-Host "  template: $TemplateDir"
    foreach ($c in $freshnessChecks) {
        $cColor = switch ($c.status) { 'fresh' { 'Green' } 'pinned' { 'Green' } 'skipped' { 'DarkYellow' } 'unmanaged' { 'DarkGray' } default { 'Red' } }
        Write-Host ("    {0,-38} {1}" -f $c.leaf, $c.message) -ForegroundColor $cColor
    }
    if ($freshnessOverall -in @('stale','unverified')) {
        Write-Host "  >> Refresh first:  pwsh scripts/update-templates.ps1  (templates are never auto-updated)" -ForegroundColor $frColor
    }
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
    Write-Host ("Critical: {0}  High: {1}  Medium: {2}  Info: {3}" -f $result.counts.critical, $result.counts.high, $result.counts.medium, $result.counts.info)
    Write-Host ""
    Write-Host "Reviewer judgment still required: is HELP.md meaningful, are any tsconfig deviations justified." -ForegroundColor DarkGray
}

# A stale or unverifiable template outranks the findings: nothing below it can be trusted,
# so callers get a distinct code rather than having to tell "module is broken" (1) apart
# from "our reference is wrong" (3).
exit ($(
    if ($freshnessOverall -in @('stale','unverified')) { 3 }
    elseif ($result.counts.critical -gt 0) { 1 }
    else { 0 }
))
