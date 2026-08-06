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
}
finally {
    if (Test-Path $root) { Remove-Item -Recurse -Force $root }
}

Write-Host ""
Write-Host "$($script:pass) passed, $($script:fail) failed" -ForegroundColor ($(if ($script:fail) { 'Red' } else { 'Green' }))
if ($script:fail) { exit 1 }
