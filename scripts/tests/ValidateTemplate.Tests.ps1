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
$licenseTpl  = "MIT License`n`nCopyright (c) 2025 Template Author`n`nPermission is hereby granted, free of charge, to any person obtaining a copy`nof this software."
$licenseGood = "MIT License`n`nCopyright (c) 2026 Jane Dev`n`nPermission is hereby granted, free of charge, to any person obtaining a copy`nof this software."
$licenseBad  = "MIT License`n`nCopyright (c) 2026 Your name`n`nPermission is hereby granted, free of charge, to any person obtaining a copy`nof this software."

$root = Join-Path ([System.IO.Path]::GetTempPath()) "validatetpl-$([System.IO.Path]::GetRandomFileName())"
try {
    # ── Fixture template (v2-style JS) ───────────────────────────────────────
    $tpl = Join-Path $root 'companion-module-template-js'
    Set-File (Join-Path $tpl '.gitattributes')  "* text=auto eol=lf"
    Set-File (Join-Path $tpl '.gitignore')       $gitignore
    Set-File (Join-Path $tpl '.prettierignore')  "package.json`n/LICENSE.md"
    Set-File (Join-Path $tpl '.yarnrc.yml')      "nodeLinker: node-modules"
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
    Set-File (Join-Path $good '.yarnrc.yml')      "nodeLinker: node-modules"
    Set-File (Join-Path $good 'LICENSE')          $licenseGood
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

    # ── GOOD module with a non-template entry filename (src/index.js) ─────────
    # Mirrors real modules (e.g. dashmaster-2k) that name their entry src/index.js.
    # main + entrypoint reference the existing file and agree → no entry findings.
    $good2 = Join-Path $root 'companion-module-idx'
    Set-File (Join-Path $good2 '.gitattributes')   "* text=auto eol=lf"
    Set-File (Join-Path $good2 '.gitignore')       $gitignore
    Set-File (Join-Path $good2 '.prettierignore')  "package.json`n/LICENSE.md"
    Set-File (Join-Path $good2 '.yarnrc.yml')      "nodeLinker: node-modules"
    Set-File (Join-Path $good2 'LICENSE')          $licenseGood
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

    # ── TS template + modules: tsconfig jest-hint exception ──────────────────
    # The template's compilerOptions.types ships a commented-out jest hint:
    #   "types": ["node" /* , "jest" ] // uncomment this if using jest */]
    # Deleting that dead comment (leaving ["node"]) is an accepted divergence and
    # must NOT raise CONFIG-DIFF; a real change (node16) still must.
    $tsTpl = Join-Path $root 'companion-module-template-ts'
    Set-File (Join-Path $tsTpl '.gitattributes')  "* text=auto eol=lf"
    Set-File (Join-Path $tsTpl '.gitignore')       $gitignore
    Set-File (Join-Path $tsTpl '.prettierignore')  "package.json`n/LICENSE.md"
    Set-File (Join-Path $tsTpl '.yarnrc.yml')      "nodeLinker: node-modules"
    Set-File (Join-Path $tsTpl 'LICENSE')          $licenseTpl
    Set-File (Join-Path $tsTpl 'eslint.config.mjs') "export default []"
    Set-File (Join-Path $tsTpl 'tsconfig.build.json') "{ `"extends`": `"./tsconfig.json`" }"
    Set-File (Join-Path $tsTpl 'tsconfig.json') "{`n`t`"compilerOptions`": {`n`t`t`"types`": [`"node`" /* , `"jest`" ] // uncomment this if using jest */]`n`t}`n}"

    function New-TsModule($name, $typesLine) {
        $dir = Join-Path $root "companion-module-$name"
        Set-File (Join-Path $dir '.gitattributes')  "* text=auto eol=lf"
        Set-File (Join-Path $dir '.gitignore')      $gitignore
        Set-File (Join-Path $dir '.prettierignore') "package.json`n/LICENSE.md"
        Set-File (Join-Path $dir '.yarnrc.yml')     "nodeLinker: node-modules"
        Set-File (Join-Path $dir 'LICENSE')         $licenseGood
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

    # ── BAD module ───────────────────────────────────────────────────────────
    $bad = Join-Path $root 'companion-module-bar'
    Set-File (Join-Path $bad '.gitattributes')  "* text=auto"            # CONFIG-DIFF
    Set-File (Join-Path $bad '.gitignore')      "node_modules/`npackage-lock.json`n/pkg`n/*.tgz`nDEBUG-*"  # drops /.yarn → CONFIG-DIFF (.gitignore)
    # .prettierignore intentionally missing                              # FILE-MISSING
    Set-File (Join-Path $bad '.yarnrc.yml')      "nodeLinker: node-modules"
    Set-File (Join-Path $bad 'LICENSE')          $licenseBad             # LICENSE-PLACEHOLDER
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
    Ok ($ids -contains 'LICENSE-PLACEHOLDER')  "flags placeholder LICENSE copyright"
    Ok ($ids -contains 'PKG-MAIN')             "flags main referencing a non-existent file"
    Ok ($ids -contains 'ENTRY-MISMATCH')       "flags main/entrypoint resolving to different files"
    Ok ($ids -contains 'PKG-REPO')             "flags wrong repository.url"
    Ok ($ids -contains 'PKG-FIELD')            "flags missing engines (template-derived)"
    Ok ($ids -contains 'PKG-YARN')             "flags non-yarn4 packageManager"
    Ok ($ids -contains 'PKG-SCRIPT')           "flags missing package script (template-derived)"
    Ok ($ids -contains 'PKG-DEVDEP')           "flags missing devDependency (template-derived)"
    Ok ($ids -contains 'MAN-IDNAME')           "flags manifest id != name"
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
