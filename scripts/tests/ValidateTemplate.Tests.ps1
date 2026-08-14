#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Self-contained integration tests for scripts/validate-template.ps1 (no Pester).
.DESCRIPTION
    Builds a fixture v2-style JS template + a known-good module + a known-bad module,
    runs the validator as a child process (so its `exit` doesn't kill this runner), and
    asserts on the -Json findings. Expectations are derived from the template, so the
    fixture template ships a package.json, manifest.json, LICENSE, and devDependencies.

    Run:  pwsh scripts/tests/ValidateTemplate.Tests.ps1
#>

$ErrorActionPreference = 'Stop'
$validator = Join-Path $PSScriptRoot '..' 'validate-template.ps1'

$script:pass = 0; $script:fail = 0
function Ok($cond, $msg) {
    if ($cond) { $script:pass++; Write-Host "  PASS  $msg" -ForegroundColor Green }
    else       { $script:fail++; Write-Host "  FAIL  $msg" -ForegroundColor Red }
}
function Set-File($Path, $Content) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
    Set-Content -LiteralPath $Path -Value $Content -Encoding utf8 -NoNewline
}
function Invoke-Validator($ModuleDir, $TemplateDir) {
    $out = & pwsh -NoProfile -File $validator -ModuleDir $ModuleDir -TemplateDir $TemplateDir -Json 2>$null
    return ($out | ConvertFrom-Json)
}
# Same, but with extra switches and the child's exit code captured. The plain
# Invoke-Validator above deliberately passes no freshness switch: every legacy fixture
# template is a non-git directory, so those calls double as the regression guard proving
# the freshness gate stays silent on an explicitly-passed -TemplateDir.
function Invoke-ValidatorArgs($ModuleDir, $TemplateDir, [string[]]$Extra) {
    $argv = @('-NoProfile', '-File', $validator, '-ModuleDir', $ModuleDir, '-TemplateDir', $TemplateDir, '-Json') + @($Extra)
    $out = & pwsh @argv 2>$null
    $code = $LASTEXITCODE
    $parsed = if ($out) { $out | ConvertFrom-Json } else { $null }
    return [pscustomobject]@{ Result = $parsed; ExitCode = $code }
}

# Git fixtures for the freshness tests. `git clone <local path>` produces a clone whose
# origin is a filesystem path and whose HEAD tracks a branch — `git ls-remote` resolves it
# with zero network, so advancing the "upstream" by one commit makes the clone
# deterministically stale. Nothing here touches GitHub.
function Git-Q($Dir, [string[]]$Argv) {
    & git -C $Dir -c user.name='t' -c user.email='t@t' -c commit.gpgsign=false @Argv 2>$null | Out-Null
}
function New-GitTemplate($Dir) {
    & git -C $Dir init -q 2>$null | Out-Null
    Git-Q $Dir @('checkout', '-q', '-B', 'main')
    Git-Q $Dir @('add', '-A')
    Git-Q $Dir @('commit', '-q', '-m', 'init')
    return $Dir
}
function New-TemplateClone($Upstream, $Dest) {
    & git clone -q $Upstream $Dest 2>$null | Out-Null
    return $Dest
}
function Add-UpstreamCommit($Dir, $RelPath, $Content) {
    Set-File (Join-Path $Dir $RelPath) $Content
    Git-Q $Dir @('add', '-A')
    Git-Q $Dir @('commit', '-q', '-m', "add $RelPath")
}
function Find-Findings($Result, $Id, $File) {
    return @($Result.findings | Where-Object { $_.id -eq $Id -and ($null -eq $File -or $_.file -eq $File) })
}

# The cache would make "advance upstream, re-check" non-deterministic. Disabled for the
# whole suite except where a test explicitly re-enables it.
$script:prevTtl = $env:COMPANION_TEMPLATE_FRESHNESS_TTL
$env:COMPANION_TEMPLATE_FRESHNESS_TTL = '0'

$gitignore = "node_modules/`npackage-lock.json`n/pkg`n/*.tgz`nDEBUG-*`n/.yarn"

# .yarnrc.yml — Bitfocus hardened the template's copy on 2026-06-24 (1 key → 4). It is
# compared by parsed key, not raw text, so only a missing/extra key or a conflicting
# value is a divergence.
$yarnrcTpl   = "nodeLinker: node-modules`nenableScripts: false`nnpmMinimalAgeGate: 3d`nnpmPreapprovedPackages:`n  - `"@companion-module/*`""
# Same four keys reordered, with blank lines and a single-quoted glob: cosmetic only.
$yarnrcCosmetic = "npmPreapprovedPackages:`n  - '@companion-module/*'`n`nenableScripts: false`n`nnodeLinker: node-modules`n`nnpmMinimalAgeGate: 3d"
# The pre-2026-06-24 template contents, still shipped by older modules.
$yarnrcOld   = "nodeLinker: node-modules"
# LICENSE must match the template exactly — the copyright line included. The three
# variants below cover the ways a module can diverge.
$licenseTpl       = "MIT License`n`nCopyright (c) 2025 Template Author`n`nPermission is hereby granted, free of charge, to any person obtaining a copy`nof this software."
$licenseCopyright = "MIT License`n`nCopyright (c) 2026 Jane Dev`n`nPermission is hereby granted, free of charge, to any person obtaining a copy`nof this software."
$licenseBody      = "The MIT License`n`nCopyright (c) 2025 Template Author`n`nPermission is hereby granted, free of charge, to any person obtaining a copy`nof this software."
$licenseShort     = "MIT License`n`nCopyright (c) 2025 Template Author"

$root = Join-Path ([System.IO.Path]::GetTempPath()) "validatetpl-$([System.IO.Path]::GetRandomFileName())"
try {
    # ── Fixture template (v2-style JS) ───────────────────────────────────────
    $tpl = Join-Path $root 'companion-module-template-js'
    Set-File (Join-Path $tpl '.gitattributes')  "* text=auto eol=lf"
    Set-File (Join-Path $tpl '.gitignore')       $gitignore
    Set-File (Join-Path $tpl '.prettierignore')  "package.json`n/LICENSE.md"
    Set-File (Join-Path $tpl '.yarnrc.yml')      $yarnrcTpl
    Set-File (Join-Path $tpl 'LICENSE')          $licenseTpl
    Set-File (Join-Path $tpl 'package.json') (@'
{
  "name": "your-module-name",
  "version": "0.1.0",
  "main": "src/main.js",
  "scripts": { "format": "prettier -w .", "package": "companion-module-build" },
  "license": "MIT",
  "repository": { "type": "git", "url": "git+https://github.com/bitfocus/companion-module-your-module-name.git" },
  "engines": { "node": "^22.20", "yarn": "^4" },
  "dependencies": { "@companion-module/base": "~2.0.4" },
  "devDependencies": { "@companion-module/tools": "^3.0.1", "prettier": "^3.8.3" },
  "prettier": "@companion-module/tools/.prettierrc.json",
  "packageManager": "yarn@4.12.0"
}
'@)
    Set-File (Join-Path $tpl 'companion/manifest.json') (@'
{
  "type": "connection",
  "id": "your-module-name",
  "name": "your-module-name",
  "maintainers": [ { "name": "Your name", "email": "Your email" } ],
  "repository": "git+https://github.com/bitfocus/companion-module-your-module-name.git",
  "runtime": { "type": "node22", "api": "nodejs-ipc", "entrypoint": "../src/main.js" },
  "keywords": []
}
'@)

    # ── GOOD module (matches template) ───────────────────────────────────────
    $good = Join-Path $root 'companion-module-foo'
    Set-File (Join-Path $good '.gitattributes')  "* text=auto eol=lf"
    Set-File (Join-Path $good '.gitignore')      "$gitignore`n.idea/`n*.log"   # extra entries OK (subset check)
    Set-File (Join-Path $good '.prettierignore')  "package.json`n/LICENSE.md"
    Set-File (Join-Path $good '.yarnrc.yml')      $yarnrcCosmetic   # reordered/quoted differently — must still pass
    Set-File (Join-Path $good 'LICENSE')          $licenseTpl
    Set-File (Join-Path $good 'yarn.lock')        "# yarn lockfile"
    Set-File (Join-Path $good 'src/main.js')      "// entry"
    Set-File (Join-Path $good 'companion/HELP.md') "# Foo`n`nThis module controls a Foo device.`nConfigure host and port.`nActions: play, stop.`nFeedbacks: playing state.`nTroubleshooting: check the network."
    Set-File (Join-Path $good 'package.json') (@'
{
  "name": "foo",
  "version": "1.2.0",
  "main": "src/main.js",
  "scripts": { "format": "prettier -w .", "package": "companion-module-build" },
  "license": "MIT",
  "repository": { "type": "git", "url": "git+https://github.com/bitfocus/companion-module-foo.git" },
  "engines": { "node": "^22.20", "yarn": "^4" },
  "dependencies": { "@companion-module/base": "~2.0.4" },
  "devDependencies": { "@companion-module/tools": "^3.0.1", "prettier": "^3.8.3" },
  "prettier": "@companion-module/tools/.prettierrc.json",
  "packageManager": "yarn@4.12.0"
}
'@)
    Set-File (Join-Path $good 'companion/manifest.json') (@'
{
  "type": "connection",
  "id": "foo",
  "name": "foo",
  "maintainers": [ { "name": "Jane Dev", "email": "jane@example.com" } ],
  "repository": "git+https://github.com/bitfocus/companion-module-foo.git",
  "runtime": { "type": "node22", "api": "nodejs-ipc", "entrypoint": "../src/main.js" },
  "keywords": ["lighting", "osc"]
}
'@)

    Write-Host "GOOD module"
    $g = Invoke-Validator $good $tpl
    Ok ($g.counts.critical -eq 0) "no critical findings (got $($g.counts.critical): $(@($g.findings | ForEach-Object { $_.id }) -join ','))"
    $gYarn = @($g.findings | Where-Object { $_.id -eq 'CONFIG-DIFF' -and $_.file -eq '.yarnrc.yml' })
    Ok ($gYarn.Count -eq 0) "does not flag .yarnrc.yml for key order, blank lines, or quote style"

    # ── GOOD module with a non-template entry filename (src/index.js) ─────────
    # Mirrors real modules (e.g. dashmaster-2k) that name their entry src/index.js.
    # main + entrypoint reference the existing file and agree → no entry findings.
    $good2 = Join-Path $root 'companion-module-idx'
    Set-File (Join-Path $good2 '.gitattributes')   "* text=auto eol=lf"
    Set-File (Join-Path $good2 '.gitignore')       $gitignore
    Set-File (Join-Path $good2 '.prettierignore')  "package.json`n/LICENSE.md"
    Set-File (Join-Path $good2 '.yarnrc.yml')      $yarnrcTpl
    Set-File (Join-Path $good2 'LICENSE')          $licenseTpl
    Set-File (Join-Path $good2 'yarn.lock')        "# yarn lockfile"
    Set-File (Join-Path $good2 'src/index.js')     "// entry"
    Set-File (Join-Path $good2 'companion/HELP.md') "# Idx`n`nThis module controls an Idx device.`nConfigure host and port.`nActions: play, stop.`nFeedbacks: playing state.`nTroubleshooting: check the network."
    Set-File (Join-Path $good2 'package.json') (@'
{
  "name": "idx",
  "version": "1.2.0",
  "main": "src/index.js",
  "scripts": { "format": "prettier -w .", "package": "companion-module-build" },
  "license": "MIT",
  "repository": { "type": "git", "url": "git+https://github.com/bitfocus/companion-module-idx.git" },
  "engines": { "node": "^22.20", "yarn": "^4" },
  "dependencies": { "@companion-module/base": "~2.0.4" },
  "devDependencies": { "@companion-module/tools": "^3.0.1", "prettier": "^3.8.3" },
  "prettier": "@companion-module/tools/.prettierrc.json",
  "packageManager": "yarn@4.12.0"
}
'@)
    Set-File (Join-Path $good2 'companion/manifest.json') (@'
{
  "type": "connection",
  "id": "idx",
  "name": "idx",
  "maintainers": [ { "name": "Jane Dev", "email": "jane@example.com" } ],
  "repository": "git+https://github.com/bitfocus/companion-module-idx.git",
  "runtime": { "type": "node22", "api": "nodejs-ipc", "entrypoint": "../src/index.js" },
  "keywords": ["lighting", "osc"]
}
'@)

    Write-Host "GOOD module (src/index.js entry)"
    $g2 = Invoke-Validator $good2 $tpl
    $g2ids = @($g2.findings | ForEach-Object { $_.id })
    Ok ($g2.counts.critical -eq 0)               "no critical findings for src/index.js entry (got $($g2.counts.critical): $($g2ids -join ','))"
    Ok (-not ($g2ids -contains 'PKG-MAIN'))      "does not flag src/index.js main (exists)"
    Ok (-not ($g2ids -contains 'MAN-RUNTIME'))   "does not flag ../src/index.js entrypoint"
    Ok (-not ($g2ids -contains 'ENTRY-MISMATCH')) "main and entrypoint agree"
    Ok (-not ($g2ids -contains 'FILE-MISSING'))  "does not require src/main.js by name"

    # ── JS module that declares a `typescript` devDependency ─────────────────
    # `typescript` is a standard peer of typescript-eslint for linting plain-JS modules
    # with flat config, NOT a TS signal. The module must validate as JS (no tsconfig /
    # .husky / build-script criticals). Regression: yunxi-yolobox v1.0.3.
    $jsTsDep = Join-Path $root 'companion-module-jstsdep'
    Set-File (Join-Path $jsTsDep '.gitattributes')  "* text=auto eol=lf"
    Set-File (Join-Path $jsTsDep '.gitignore')      $gitignore
    Set-File (Join-Path $jsTsDep '.prettierignore') "package.json`n/LICENSE.md"
    Set-File (Join-Path $jsTsDep '.yarnrc.yml')     $yarnrcTpl
    Set-File (Join-Path $jsTsDep 'LICENSE')         $licenseTpl
    Set-File (Join-Path $jsTsDep 'yarn.lock')       "# yarn lockfile"
    Set-File (Join-Path $jsTsDep 'src/main.js')     "// entry"
    Set-File (Join-Path $jsTsDep 'companion/HELP.md') "# Jstsdep`n`nThis module controls a device.`nConfigure host and port.`nActions: play, stop.`nFeedbacks: playing state.`nTroubleshooting: check the network."
    Set-File (Join-Path $jsTsDep 'package.json') (@'
{
  "name": "jstsdep",
  "version": "1.2.0",
  "main": "src/main.js",
  "scripts": { "format": "prettier -w .", "package": "companion-module-build" },
  "license": "MIT",
  "repository": { "type": "git", "url": "git+https://github.com/bitfocus/companion-module-jstsdep.git" },
  "engines": { "node": "^22.20", "yarn": "^4" },
  "dependencies": { "@companion-module/base": "~2.0.4" },
  "devDependencies": { "@companion-module/tools": "^3.0.1", "prettier": "^3.8.3", "typescript": "^5.6.0", "typescript-eslint": "^8.44.1" },
  "prettier": "@companion-module/tools/.prettierrc.json",
  "packageManager": "yarn@4.12.0"
}
'@)
    Set-File (Join-Path $jsTsDep 'companion/manifest.json') (@'
{
  "type": "connection",
  "id": "jstsdep",
  "name": "jstsdep",
  "maintainers": [ { "name": "Jane Dev", "email": "jane@example.com" } ],
  "repository": "git+https://github.com/bitfocus/companion-module-jstsdep.git",
  "runtime": { "type": "node22", "api": "nodejs-ipc", "entrypoint": "../src/main.js" },
  "keywords": ["lighting", "osc"]
}
'@)

    Write-Host "JS module with a typescript devDependency"
    $jtd = Invoke-Validator $jsTsDep $tpl
    $jtdMissing = @($jtd.findings | Where-Object { $_.id -eq 'FILE-MISSING' -and $_.file -in @('tsconfig.json','tsconfig.build.json','.husky/pre-commit') })
    Ok ($jtd.language -eq 'JS')        "classifies as JS despite the typescript devDependency"
    Ok ($jtdMissing.Count -eq 0)       "does not demand TS-only files (tsconfig/.husky)"
    Ok ($jtd.counts.critical -eq 0)    "no critical findings (got $($jtd.counts.critical): $(@($jtd.findings | ForEach-Object { $_.id }) -join ','))"

    # ── TS template + modules: tsconfig jest-hint exception ──────────────────
    # The template's compilerOptions.types ships a commented-out jest hint:
    #   "types": ["node" /* , "jest" ] // uncomment this if using jest */]
    # Deleting that dead comment (leaving ["node"]) is an accepted divergence and
    # must NOT raise CONFIG-DIFF; a real change (node16) still must.
    $tsTpl = Join-Path $root 'companion-module-template-ts'
    Set-File (Join-Path $tsTpl '.gitattributes')  "* text=auto eol=lf"
    Set-File (Join-Path $tsTpl '.gitignore')       $gitignore
    Set-File (Join-Path $tsTpl '.prettierignore')  "package.json`n/LICENSE.md"
    Set-File (Join-Path $tsTpl '.yarnrc.yml')      $yarnrcTpl
    Set-File (Join-Path $tsTpl 'LICENSE')          $licenseTpl
    Set-File (Join-Path $tsTpl 'eslint.config.mjs') "export default []"
    Set-File (Join-Path $tsTpl 'tsconfig.build.json') "{ `"extends`": `"./tsconfig.json`" }"
    Set-File (Join-Path $tsTpl 'tsconfig.json') "{`n`t`"compilerOptions`": {`n`t`t`"types`": [`"node`" /* , `"jest`" ] // uncomment this if using jest */]`n`t}`n}"

    function New-TsModule($name, $typesLine) {
        $dir = Join-Path $root "companion-module-$name"
        Set-File (Join-Path $dir '.gitattributes')  "* text=auto eol=lf"
        Set-File (Join-Path $dir '.gitignore')      $gitignore
        Set-File (Join-Path $dir '.prettierignore') "package.json`n/LICENSE.md"
        Set-File (Join-Path $dir '.yarnrc.yml')     $yarnrcTpl
        Set-File (Join-Path $dir 'LICENSE')         $licenseTpl
        Set-File (Join-Path $dir 'eslint.config.mjs') "export default []"
        Set-File (Join-Path $dir 'tsconfig.build.json') "{ `"extends`": `"./tsconfig.json`" }"
        Set-File (Join-Path $dir 'tsconfig.json')   "{`n`t`"compilerOptions`": {`n`t`t$typesLine`n`t}`n}"
        Set-File (Join-Path $dir '.husky/pre-commit') "yarn lint-staged"
        Set-File (Join-Path $dir 'yarn.lock')       "# yarn lockfile"
        Set-File (Join-Path $dir 'src/main.ts')     "// entry"
        Set-File (Join-Path $dir 'companion/HELP.md') "# $name`n`nThis module controls a device.`nConfigure host and port.`nActions: play, stop.`nFeedbacks: playing state.`nTroubleshooting: check the network."
        Set-File (Join-Path $dir 'package.json') (@"
{
  "name": "$name",
  "version": "1.2.0",
  "main": "src/main.ts",
  "scripts": { "format": "prettier -w .", "package": "companion-module-build" },
  "license": "MIT",
  "repository": { "type": "git", "url": "git+https://github.com/bitfocus/companion-module-$name.git" },
  "engines": { "node": "^22.20", "yarn": "^4" },
  "dependencies": { "@companion-module/base": "~2.0.4" },
  "devDependencies": { "@companion-module/tools": "^3.0.1", "prettier": "^3.8.3" },
  "prettier": "@companion-module/tools/.prettierrc.json",
  "packageManager": "yarn@4.12.0"
}
"@)
        Set-File (Join-Path $dir 'companion/manifest.json') (@"
{
  "type": "connection",
  "id": "$name",
  "name": "$name",
  "maintainers": [ { "name": "Jane Dev", "email": "jane@example.com" } ],
  "repository": "git+https://github.com/bitfocus/companion-module-$name.git",
  "runtime": { "type": "node22", "api": "nodejs-ipc", "entrypoint": "../src/main.ts" },
  "keywords": ["lighting", "osc"]
}
"@)
        return $dir
    }

    $tsGood = New-TsModule 'tsgood' '"types": ["node"]'                # jest hint removed
    $tsBad  = New-TsModule 'tsbad'  '"types": ["node16"]'              # real divergence

    Write-Host "TS module (tsconfig jest hint removed)"
    $tg = Invoke-Validator $tsGood $tsTpl
    $tgConfigDiffs = @($tg.findings | Where-Object { $_.id -eq 'CONFIG-DIFF' -and $_.file -eq 'tsconfig.json' })
    Ok ($tgConfigDiffs.Count -eq 0) "does not flag tsconfig.json when only the commented jest hint was removed"

    Write-Host "TS module (real tsconfig divergence)"
    $tb = Invoke-Validator $tsBad $tsTpl
    $tbConfigDiffs = @($tb.findings | Where-Object { $_.id -eq 'CONFIG-DIFF' -and $_.file -eq 'tsconfig.json' })
    Ok ($tbConfigDiffs.Count -gt 0) "still flags a real tsconfig.json divergence (node16)"

    # ── .yarnrc.yml divergences ──────────────────────────────────────────────
    # Compared by parsed key against the *main* template (never the pinned -v1 one),
    # so cosmetics pass but a missing key, conflicting value, or extra key is Critical.
    # Builds an otherwise-clean JS module; callers vary one file at a time. Also reused by
    # the LICENSE cases below via -license.
    function New-YarnrcModule($name, $yarnrc, $baseRange = '~2.0.4', $license = $licenseTpl) {
        $dir = Join-Path $root "companion-module-$name"
        Set-File (Join-Path $dir '.gitattributes')  "* text=auto eol=lf"
        Set-File (Join-Path $dir '.gitignore')      $gitignore
        Set-File (Join-Path $dir '.prettierignore') "package.json`n/LICENSE.md"
        Set-File (Join-Path $dir '.yarnrc.yml')     $yarnrc
        Set-File (Join-Path $dir 'LICENSE')         $license
        Set-File (Join-Path $dir 'yarn.lock')       "# yarn lockfile"
        Set-File (Join-Path $dir 'src/main.js')     "// entry"
        Set-File (Join-Path $dir 'companion/HELP.md') "# $name`n`nThis module controls a device.`nConfigure host and port.`nActions: play, stop.`nFeedbacks: playing state.`nTroubleshooting: check the network."
        Set-File (Join-Path $dir 'package.json') (@"
{
  "name": "$name",
  "version": "1.2.0",
  "main": "src/main.js",
  "scripts": { "format": "prettier -w .", "package": "companion-module-build" },
  "license": "MIT",
  "repository": { "type": "git", "url": "git+https://github.com/bitfocus/companion-module-$name.git" },
  "engines": { "node": "^22.20", "yarn": "^4" },
  "dependencies": { "@companion-module/base": "$baseRange" },
  "devDependencies": { "@companion-module/tools": "^3.0.1", "prettier": "^3.8.3" },
  "prettier": "@companion-module/tools/.prettierrc.json",
  "packageManager": "yarn@4.12.0"
}
"@)
        Set-File (Join-Path $dir 'companion/manifest.json') (@"
{
  "type": "connection",
  "id": "$name",
  "name": "$name",
  "maintainers": [ { "name": "Jane Dev", "email": "jane@example.com" } ],
  "repository": "git+https://github.com/bitfocus/companion-module-$name.git",
  "runtime": { "type": "node22", "api": "nodejs-ipc", "entrypoint": "../src/main.js" },
  "keywords": ["lighting", "osc"]
}
"@)
        return $dir
    }
    function Get-YarnrcFindings($result) {
        return @($result.findings | Where-Object { $_.id -eq 'CONFIG-DIFF' -and $_.file -eq '.yarnrc.yml' })
    }

    Write-Host ".yarnrc.yml — pre-hardening (1-key) file"
    $yOld = Get-YarnrcFindings (Invoke-Validator (New-YarnrcModule 'yarnold' $yarnrcOld) $tpl)
    Ok ($yOld.Count -eq 1 -and $yOld[0].message -match 'Missing template keys:.*enableScripts.*npmMinimalAgeGate.*npmPreapprovedPackages') `
        "flags the old 1-key .yarnrc.yml, naming every missing hardening key"

    Write-Host ".yarnrc.yml — conflicting value"
    $yVal = Get-YarnrcFindings (Invoke-Validator (New-YarnrcModule 'yarnval' ($yarnrcTpl -replace 'enableScripts: false','enableScripts: true')) $tpl)
    Ok ($yVal.Count -eq 1 -and $yVal[0].message -match "Value mismatch:.*enableScripts = 'true' \(template 'false'\)") `
        "flags enableScripts: true as a value mismatch, and nothing else"

    Write-Host ".yarnrc.yml — extra key"
    $yExtra = Get-YarnrcFindings (Invoke-Validator (New-YarnrcModule 'yarnextra' "$yarnrcTpl`nyarnPath: .yarn/releases/yarn-4.10.3.cjs") $tpl)
    Ok ($yExtra.Count -eq 1 -and $yExtra[0].message -match 'Extra keys not in template: yarnPath') `
        "flags a key the template does not have (yarnPath)"

    # ── v1 modules are judged against the main template's .yarnrc.yml ────────
    # Bitfocus only updates .yarnrc.yml on main; the -v1 template is pinned to an older
    # commit that still carries the 1-key file. A v1 module shipping the current hardened
    # file must NOT be flagged (regression: panasonic-cameras v1.3.0).
    $tplV1 = Join-Path $root 'companion-module-template-js-v1'
    Copy-Item -Recurse -Force $tpl $tplV1
    Set-File (Join-Path $tplV1 '.yarnrc.yml') $yarnrcOld

    Write-Host "v1 module shipping the current (main) .yarnrc.yml"
    $v1New = Get-YarnrcFindings (Invoke-Validator (New-YarnrcModule 'yarnv1new' $yarnrcTpl '~1.14.0') $tplV1)
    Ok ($v1New.Count -eq 0) "does not flag a v1 module carrying the main template's hardened .yarnrc.yml"

    Write-Host "v1 module still on the pinned v1 template's .yarnrc.yml"
    $v1Old = Get-YarnrcFindings (Invoke-Validator (New-YarnrcModule 'yarnv1old' $yarnrcOld '~1.14.0') $tplV1)
    Ok ($v1Old.Count -eq 1 -and $v1Old[0].message -match 'Missing template keys') `
        "judges v1 modules against the main template's yarnrc, not the pinned -v1 copy"

    # ── LICENSE must match the template exactly ──────────────────────────────
    # The template's LICENSE is the licence itself, copyright line included — not a
    # scaffold to personalise. Any divergence is a High finding.
    function Get-LicenseFindings($result) {
        return @($result.findings | Where-Object { $_.id -eq 'LICENSE-DIFF' })
    }

    Write-Host "LICENSE — matches the template"
    $lOk = Get-LicenseFindings (Invoke-Validator (New-YarnrcModule 'licok' $yarnrcTpl) $tpl)
    Ok ($lOk.Count -eq 0) "does not flag a LICENSE identical to the template"

    Write-Host "LICENSE — copyright line differs only"
    $lCopy = Get-LicenseFindings (Invoke-Validator (New-YarnrcModule 'liccopy' $yarnrcTpl '~2.0.4' $licenseCopyright) $tpl)
    Ok ($lCopy.Count -eq 1 -and $lCopy[0].severity -eq 'High') `
        "flags a differing copyright line at High (the copyright line is no longer exempt)"
    Ok ($lCopy.Count -eq 1 -and $lCopy[0].message -match "line 3: found 'Copyright \(c\) 2026 Jane Dev'") `
        "names the differing copyright line"

    Write-Host "LICENSE — fewer lines than the template"
    $lShort = Get-LicenseFindings (Invoke-Validator (New-YarnrcModule 'licshort' $yarnrcTpl '~2.0.4' $licenseShort) $tpl)
    Ok ($lShort.Count -eq 1 -and $lShort[0].message -match '<missing>') `
        "flags a truncated LICENSE and reports the missing line"

    Write-Host "LICENSE — CRLF line endings, same text"
    $lCrlf = Get-LicenseFindings (Invoke-Validator (New-YarnrcModule 'liccrlf' $yarnrcTpl '~2.0.4' ($licenseTpl -replace "`n", "`r`n")) $tpl)
    Ok ($lCrlf.Count -eq 0) "does not flag a CRLF checkout of the correct LICENSE text"

    # ── BAD module ───────────────────────────────────────────────────────────
    $bad = Join-Path $root 'companion-module-bar'
    Set-File (Join-Path $bad '.gitattributes')  "* text=auto"            # CONFIG-DIFF
    Set-File (Join-Path $bad '.gitignore')      "node_modules/`npackage-lock.json`n/pkg`n/*.tgz`nDEBUG-*"  # drops /.yarn → CONFIG-DIFF (.gitignore)
    # .prettierignore intentionally missing                              # FILE-MISSING
    Set-File (Join-Path $bad '.yarnrc.yml')      $yarnrcTpl
    Set-File (Join-Path $bad 'LICENSE')          $licenseBody            # LICENSE-DIFF (body text)
    Set-File (Join-Path $bad 'yarn.lock')        "# yarn lockfile"
    Set-File (Join-Path $bad 'src/main.js')      "// entry"
    Set-File (Join-Path $bad 'main.js')          "// stray root source"  # SRC-AT-ROOT
    Set-File (Join-Path $bad 'package-lock.json') "{}"                   # NPM-LOCK
    Set-File (Join-Path $bad 'companion/HELP.md') "## Your module"       # HELP-STUB
    Set-File (Join-Path $bad 'node_modules/dep/index.js') "x"           # GITIGNORED-COMMITTED
    Set-File (Join-Path $bad 'package.json') (@'
{
  "name": "bar",
  "version": "1.2.0",
  "main": "src/missing.js",
  "scripts": { "format": "prettier -w ." },
  "license": "MIT",
  "repository": { "type": "git", "url": "git+https://github.com/someone/companion-module-bar.git" },
  "dependencies": { "@companion-module/base": "~2.0.4" },
  "devDependencies": { "@companion-module/tools": "^3.0.1" },
  "prettier": "@companion-module/tools/.prettierrc.json",
  "packageManager": "npm@9"
}
'@)
    Set-File (Join-Path $bad 'companion/manifest.json') (@'
{
  "id": "bar",
  "name": "bar-module",
  "maintainers": [ { "name": "Your name", "email": "Your email" } ],
  "repository": "git+https://github.com/someone/companion-module-bar.git",
  "runtime": { "type": "node22", "api": "nodejs-ipc", "entrypoint": "../src/alsogone.js" },
  "keywords": ["companion", "bar"]
}
'@)
    & git -C $bad init -q 2>$null
    & git -C $bad add -f node_modules/dep/index.js 2>$null

    Write-Host "BAD module"
    $b = Invoke-Validator $bad $tpl
    $ids = @($b.findings | ForEach-Object { $_.id })
    Ok ($ids -contains 'CONFIG-DIFF')          "flags .gitattributes config diff"
    Ok (@($b.findings | Where-Object { $_.id -eq 'CONFIG-DIFF' -and $_.file -eq '.gitignore' }).Count -gt 0) "flags .gitignore missing a template entry"
    Ok ($ids -contains 'FILE-MISSING')         "flags missing .prettierignore"
    Ok ($ids -contains 'NPM-LOCK')             "flags package-lock.json"
    Ok ($ids -contains 'SRC-AT-ROOT')          "flags source file at module root"
    $badLicense = @($b.findings | Where-Object { $_.id -eq 'LICENSE-DIFF' })
    Ok ($badLicense.Count -eq 1)                       "flags a LICENSE whose body text differs from the template"
    Ok ($badLicense[0].severity -eq 'High')            "reports LICENSE-DIFF at High, not Critical"
    Ok (-not ($ids -contains 'LICENSE-PLACEHOLDER'))   "no longer emits LICENSE-PLACEHOLDER (exact match subsumes it)"
    Ok ($ids -contains 'PKG-MAIN')             "flags main referencing a non-existent file"
    Ok ($ids -contains 'ENTRY-MISMATCH')       "flags main/entrypoint resolving to different files"
    Ok ($ids -contains 'PKG-REPO')             "flags wrong repository.url"
    Ok ($ids -contains 'PKG-FIELD')            "flags missing engines (template-derived)"
    Ok ($ids -contains 'PKG-YARN')             "flags non-yarn4 packageManager"
    Ok ($ids -contains 'PKG-SCRIPT')           "flags missing package script (template-derived)"
    Ok ($ids -contains 'PKG-DEVDEP')           "flags missing devDependency (template-derived)"
    # The fixture is deliberately id "bar" / name "bar-module": manifest `name` is the
    # human-facing name and may differ from the slug `id`, so this must NOT be flagged.
    Ok (-not ($ids -contains 'MAN-IDNAME'))    "does not flag manifest id != name (name is human-facing, not the slug)"
    Ok ($ids -contains 'MAN-PLACEHOLDER')      "flags placeholder maintainer"
    Ok ($ids -contains 'MAN-KEYWORD')          "flags banned keyword 'companion'"
    Ok ($ids -contains 'MAN-TYPE')             "flags missing manifest type (template has it)"
    Ok ($ids -contains 'MAN-RUNTIME')          "flags runtime.entrypoint referencing a non-existent file"
    Ok ($ids -contains 'HELP-STUB')            "flags HELP.md stub"
    Ok ($ids -contains 'GITIGNORED-COMMITTED') "flags committed node_modules"
    Ok ($b.counts.critical -gt 0)              "reports critical count > 0"
    Ok ($null -ne $b.counts.info)              "counts now carries an info bucket"

    # ── Freshness: the template clone must not be behind upstream ─────────────
    # Every fixture above passes a non-git -TemplateDir and expects silence; these build a
    # real (local) upstream + clone pair so the gate can be exercised without a network.
    $fresh = Join-Path $root 'freshness'
    $upstream = Join-Path $fresh 'upstream'
    Copy-Item -Recurse -Force $tpl $upstream
    New-GitTemplate $upstream | Out-Null
    $clone = New-TemplateClone $upstream (Join-Path $fresh 'clone')

    Write-Host "Template freshness — clone matches upstream"
    $f1 = (Invoke-ValidatorArgs $good $clone @()).Result
    Ok ($f1.templateFreshness.status -eq 'fresh')            "reports status 'fresh' when the clone matches origin/main"
    Ok ((Find-Findings $f1 'TEMPLATE-STALE' $null).Count -eq 0) "raises no TEMPLATE-STALE for an up-to-date clone"
    Ok ($f1.templateRevision.shortSha -eq (& git -C $clone rev-parse --short HEAD)) "records the exact template revision it judged against"
    Ok ($null -ne $f1.templateRevision.committedAt)          "records the template's commit date"

    Write-Host "Template freshness — upstream has moved on"
    Add-UpstreamCommit $upstream 'NEWFILE.md' "upstream moved"
    $f2r = Invoke-ValidatorArgs $good $clone @()
    $f2  = $f2r.Result
    $stale = Find-Findings $f2 'TEMPLATE-STALE' $null
    Ok ($f2.templateFreshness.status -eq 'stale')   "reports status 'stale' once upstream is ahead"
    Ok ($stale.Count -eq 1)                          "raises exactly one TEMPLATE-STALE"
    Ok ($stale.Count -eq 1 -and $stale[0].severity -eq 'Critical') "TEMPLATE-STALE is Critical (blocking)"
    Ok ($stale.Count -eq 1 -and $stale[0].message -match 'update-templates\.ps1') "the message names the refresh command"
    Ok ($stale.Count -eq 1 -and $stale[0].message -match [regex]::Escape((& git -C $clone rev-parse --short HEAD))) "the message carries the local short sha"
    Ok ($f2r.ExitCode -eq 3)                         "exits 3 on a stale template, distinct from 1 (module defects)"

    Write-Host "Template freshness — opt-outs"
    $f3 = (Invoke-ValidatorArgs $good $clone @('-SkipTemplateFreshness')).Result
    Ok ($f3.templateFreshness.status -eq 'skipped')             "-SkipTemplateFreshness reports 'skipped'"
    Ok ((Find-Findings $f3 'TEMPLATE-STALE' $null).Count -eq 0) "-SkipTemplateFreshness silences TEMPLATE-STALE"
    $prevSkip = $env:COMPANION_SKIP_TEMPLATE_FRESHNESS
    $env:COMPANION_SKIP_TEMPLATE_FRESHNESS = '1'
    $f4 = (Invoke-ValidatorArgs $good $clone @()).Result
    $env:COMPANION_SKIP_TEMPLATE_FRESHNESS = $prevSkip
    Ok ($f4.templateFreshness.status -eq 'skipped')             "COMPANION_SKIP_TEMPLATE_FRESHNESS=1 also opts out"

    Write-Host "Template freshness — unreachable upstream"
    $unreachable = New-TemplateClone $upstream (Join-Path $fresh 'unreachable')
    Git-Q $unreachable @('remote', 'set-url', 'origin', (Join-Path $fresh 'no-such-repo'))
    $f5 = (Invoke-ValidatorArgs $good $unreachable @()).Result
    Ok ($f5.templateFreshness.status -eq 'unverified')              "an unreachable origin reports 'unverified', not 'fresh'"
    Ok ((Find-Findings $f5 'TEMPLATE-UNVERIFIED' $null).Count -eq 1) "raises TEMPLATE-UNVERIFIED"
    Ok ((Find-Findings $f5 'TEMPLATE-STALE' $null).Count -eq 0)      "does not also claim the clone is stale"

    Write-Host "Template freshness — pinned (detached) clone is exempt"
    $pinned = New-TemplateClone $upstream (Join-Path $fresh 'pinned')
    Git-Q $pinned @('checkout', '-q', '--detach', 'HEAD~1')
    $f6 = (Invoke-ValidatorArgs $good $pinned @()).Result
    $f6pin = @($f6.templateFreshness.checks | Where-Object { $_.leaf -eq 'pinned' })
    Ok ($f6pin.Count -eq 1 -and $f6pin[0].status -eq 'pinned')  "a detached clone reports 'pinned' even when its parent moved"
    Ok ((Find-Findings $f6 'TEMPLATE-STALE' $null).Count -eq 0) "a pinned clone (the -v1 case) is never flagged stale"

    # The production v1 shape: the pinned "-v1" clone is created FROM the v2 clone, and the
    # v2 clone is the thing that can fall behind GitHub. Pinning the child must not hide a
    # stale parent — the parent supplies the .yarnrc.yml expectations for v1 modules.
    Write-Host "Template freshness — pinned clone with a stale parent"
    $parent = New-TemplateClone $upstream (Join-Path $fresh 'parent')
    Git-Q $parent @('checkout', '-q', '-B', 'main')
    $child  = New-TemplateClone $parent (Join-Path $fresh 'child')
    Git-Q $child @('checkout', '-q', '--detach', 'HEAD')
    Add-UpstreamCommit $upstream 'ANOTHER.md' "upstream moved again"
    $f6b = (Invoke-ValidatorArgs $good $child @()).Result
    $f6bStale = Find-Findings $f6b 'TEMPLATE-STALE' $null
    Ok ($f6bStale.Count -eq 1 -and $f6bStale[0].file -eq 'parent') "a stale parent is caught through the pinned child's local origin"
    Ok ($f6b.templateFreshness.status -eq 'stale')                 "…and the overall status is stale, so the review still aborts"

    # The validator runs twice per review (once nested in module-facts.ps1, once from the
    # orchestrator), so the remote lookup is cached to keep a transient network blip from
    # becoming a blocking TEMPLATE-UNVERIFIED. Only the REMOTE side is cached — the local sha
    # is always read fresh, which is what makes a just-refreshed clone read 'fresh' at once.
    Write-Host "Template freshness — remote lookup is cached"
    $cacheDir = Join-Path $root 'cachehome'
    New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
    $prevTmp = $env:TMPDIR
    $env:TMPDIR = $cacheDir
    $env:COMPANION_TEMPLATE_FRESHNESS_TTL = '600'
    $cacheClone = New-TemplateClone $upstream (Join-Path $fresh 'cached')
    $c1 = (Invoke-ValidatorArgs $good $cacheClone @()).Result
    $c2 = (Invoke-ValidatorArgs $good $cacheClone @()).Result
    $env:COMPANION_TEMPLATE_FRESHNESS_TTL = '0'
    $env:TMPDIR = $prevTmp
    Ok ($c1.templateFreshness.checks[0].cached -eq $false) "the first lookup goes to the remote"
    Ok ($c2.templateFreshness.checks[0].cached -eq $true)  "a second lookup within the TTL is served from cache"
    Ok ($c2.templateFreshness.status -eq $c1.templateFreshness.status) "the cached lookup reaches the same verdict"

    Write-Host "Template freshness — non-git fixture template"
    Ok ($g.templateFreshness.status -eq 'unmanaged')            "an explicitly-passed non-git template stays silent (regression guard)"
    Ok ((Find-Findings $g 'TEMPLATE-UNVERIFIED' $null).Count -eq 0) "…and raises no TEMPLATE-UNVERIFIED"

    # ── Derived compared-file set ─────────────────────────────────────────────
    # Which files get compared comes from the template's own tracked files, so a file added
    # upstream is compared automatically. These fixtures add files to the *template* and
    # assert the module is judged against them.
    Write-Host "Derived file set — a file the template tracks but the module lacks"
    $dtpl = Join-Path $root 'derived-tpl'
    Copy-Item -Recurse -Force $tpl $dtpl
    Set-File (Join-Path $dtpl '.github/workflows/node.yaml')  "name: node`njobs: {}"
    Set-File (Join-Path $dtpl '.github/workflows/checks.yaml') "name: checks`njobs: {}"
    Set-File (Join-Path $dtpl 'README.md')                     "# Template readme"
    Set-File (Join-Path $dtpl 'src/main.js')                   "// template entry"
    Set-File (Join-Path $dtpl 'logo.png')                      "PNGDATA-template"

    $d1 = Invoke-Validator $good $dtpl
    $miss = Find-Findings $d1 'FILE-MISSING' '.github/workflows/node.yaml'
    Ok ($miss.Count -eq 1)                                        "a template-tracked file missing from the module is reported"
    Ok ($miss.Count -eq 1 -and $miss[0].severity -eq 'Medium')     ".github/** lands at Medium, not blocking"
    Ok ((Find-Findings $d1 'CONFIG-DIFF' '.github/workflows/node.yaml').Count -eq 0) "a missing file is not ALSO reported as a content diff"

    Write-Host "Derived file set — module-owned files are never compared"
    Set-File (Join-Path $good 'README.md')  "# Foo readme, quite different"
    Set-File (Join-Path $good 'logo.png')   "PNGDATA-module-different"
    $d2 = Invoke-Validator $good $dtpl
    Ok ((Find-Findings $d2 'CONFIG-DIFF' 'README.md').Count -eq 0)   "README.md is module-owned and never diffed"
    Ok ((Find-Findings $d2 'CONFIG-DIFF' 'src/main.js').Count -eq 0) "src/** is module-owned and never diffed"
    Ok ((Find-Findings $d2 'CONFIG-DIFF' 'logo.png').Count -eq 0)    "binaries are skipped, not line-diffed"
    Ok ((Find-Findings $d2 'CONFIG-DIFF' 'LICENSE').Count -eq 0)     "LICENSE stays with its own LICENSE-DIFF rule"
    Ok ((Find-Findings $d2 'CONFIG-DIFF' 'package.json').Count -eq 0) "package.json stays with the PKG-* rules"

    Write-Host "Derived file set — a differing .github file is a content diff"
    Set-File (Join-Path $good '.github/workflows/node.yaml')  "name: node`njobs: { build: {} }"
    Set-File (Join-Path $good '.github/workflows/checks.yaml') "name: checks`njobs: {}"
    $d3 = Invoke-Validator $good $dtpl
    $diff = Find-Findings $d3 'CONFIG-DIFF' '.github/workflows/node.yaml'
    Ok ($diff.Count -eq 1)                                     "a diverging .github workflow is reported"
    Ok ($diff.Count -eq 1 -and $diff[0].severity -eq 'Medium') "…at Medium"
    Ok ((Find-Findings $d3 'FILE-MISSING' '.github/workflows/node.yaml').Count -eq 0) "…and not also as missing"
    Ok ((Find-Findings $d3 'CONFIG-DIFF' '.github/workflows/checks.yaml').Count -eq 0) "an identical .github workflow is not flagged"
    Ok ($d3.counts.critical -eq 0)                             ".github findings never raise the critical count"

    Write-Host "Derived file set — a template file with no rule"
    Set-File (Join-Path $dtpl '.editorconfig') "root = true`nindent_style = tab"
    Set-File (Join-Path $good '.editorconfig') "root = true`nindent_style = space"
    $d4 = Invoke-Validator $good $dtpl
    Ok ((Find-Findings $d4 'TEMPLATE-COVERAGE' '.editorconfig').Count -eq 1) "an unrecognized template file raises TEMPLATE-COVERAGE"
    Ok ((Find-Findings $d4 'TEMPLATE-COVERAGE' '.editorconfig')[0].severity -eq 'Info') "TEMPLATE-COVERAGE is Info — a validator gap, not a maintainer defect"
    Ok ((Find-Findings $d4 'CONFIG-DIFF' '.editorconfig').Count -eq 1)       "…and it is still compared, so drift can't go silent"
    Set-File (Join-Path $good '.editorconfig') "root = true`nindent_style = tab"
    $d5 = Invoke-Validator $good $dtpl
    Ok ((Find-Findings $d5 'TEMPLATE-COVERAGE' '.editorconfig').Count -eq 1) "TEMPLATE-COVERAGE fires on the missing rule even when contents match"
    Ok ((Find-Findings $d5 'CONFIG-DIFF' '.editorconfig').Count -eq 0)       "…with no CONFIG-DIFF when the file is identical"
    Ok ($d5.counts.critical -eq 0)                                           "an Info finding does not raise the critical count"

    Write-Host "Derived file set — yarn.lock is required but never diffed"
    Set-File (Join-Path $dtpl 'yarn.lock') "# template lockfile, totally different"
    $d6 = Invoke-Validator $good $dtpl
    Ok ((Find-Findings $d6 'CONFIG-DIFF' 'yarn.lock').Count -eq 0) "yarn.lock is per-module and never diffed (the js-v1 template tracks one)"
    $nolock = Join-Path $root 'companion-module-nolock'
    Copy-Item -Recurse -Force $good $nolock
    Remove-Item -Force (Join-Path $nolock 'yarn.lock')
    $d6b = Invoke-Validator $nolock $tpl
    $lockMiss = Find-Findings $d6b 'FILE-MISSING' 'yarn.lock'
    Ok ($lockMiss.Count -eq 1)                                   "…but a module with no yarn.lock is still flagged"
    Ok ($lockMiss.Count -eq 1 -and $lockMiss[0].severity -eq 'Critical') "…as Critical, even though no template tracks it"

    # ── TS-only requirements must not leak into JS ────────────────────────────
    # This used to be a hardcoded $requiredTs list applied to every TS module. Now it falls
    # out of the template's own file list, so the JS template (which tracks no .husky/ and
    # no tsconfig) can't demand them.
    Write-Host "Derived file set — JS module vs JS template"
    $d7 = Invoke-Validator $good $tpl
    Ok ((Find-Findings $d7 'FILE-MISSING' '.husky/pre-commit').Count -eq 0) "a JS module is not asked for .husky/pre-commit"
    Ok ((Find-Findings $d7 'FILE-MISSING' 'tsconfig.json').Count -eq 0)     "a JS module is not asked for tsconfig.json"

    # ── husky: one finding per problem, not two ───────────────────────────────
    Write-Host "husky — no double report"
    $ttpl = Join-Path $root 'ts-template'
    Copy-Item -Recurse -Force $tpl $ttpl
    Set-File (Join-Path $ttpl 'tsconfig.json')       "{ `"compilerOptions`": { `"strict`": true } }"
    Set-File (Join-Path $ttpl 'tsconfig.build.json') "{ `"extends`": `"./tsconfig.json`" }"
    Set-File (Join-Path $ttpl 'eslint.config.mjs')   "export default []"
    Set-File (Join-Path $ttpl '.husky/pre-commit')   "npx lint-staged"
    $tmod = Join-Path $root 'companion-module-tsmod'
    Copy-Item -Recurse -Force $good $tmod
    Remove-Item -Recurse -Force (Join-Path $tmod 'src')
    Remove-Item -Force (Join-Path $tmod '.editorconfig') -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force (Join-Path $tmod '.github') -ErrorAction SilentlyContinue
    Set-File (Join-Path $tmod 'src/main.ts')          "// entry"
    Set-File (Join-Path $tmod 'tsconfig.json')        "{ `"compilerOptions`": { `"strict`": true } }"
    Set-File (Join-Path $tmod 'tsconfig.build.json')  "{ `"extends`": `"./tsconfig.json`" }"
    Set-File (Join-Path $tmod 'eslint.config.mjs')    "export default []"
    Set-File (Join-Path $tmod '.husky/pre-commit')    "npm test"      # differs AND drops lint-staged
    $h = Invoke-Validator $tmod $ttpl
    Ok ((Find-Findings $h 'CONFIG-DIFF' '.husky/pre-commit').Count -eq 1) "a diverging husky hook is reported as CONFIG-DIFF"
    Ok ((Find-Findings $h 'HUSKY' '.husky/pre-commit').Count -eq 0)       "…and not ALSO as HUSKY (one problem, one finding)"
    Set-File (Join-Path $tmod '.husky/pre-commit')    "npx lint-staged"
    $h2 = Invoke-Validator $tmod $ttpl
    Ok ((Find-Findings $h2 'CONFIG-DIFF' '.husky/pre-commit').Count -eq 0) "a matching husky hook is clean"
    Ok ((Find-Findings $h2 'HUSKY' $null).Count -eq 0)                     "…with no HUSKY finding either"
}
finally {
    $env:COMPANION_TEMPLATE_FRESHNESS_TTL = $script:prevTtl
    if (Test-Path $root) { Remove-Item -Recurse -Force $root }
}

Write-Host ""
Write-Host "$($script:pass) passed, $($script:fail) failed" -ForegroundColor ($(if ($script:fail) { 'Red' } else { 'Green' }))
if ($script:fail) { exit 1 }
