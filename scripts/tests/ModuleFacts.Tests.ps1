#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Self-contained tests for scripts/module-facts.ps1 (no Pester).
.DESCRIPTION
    Builds minimal module fixtures and asserts the fact sheet's language / API version /
    selected api-compliance skill / protocol detection. Uses -SkipTemplateCheck so the test
    doesn't depend on template repos.

    Run:  pwsh scripts/tests/ModuleFacts.Tests.ps1
#>

$ErrorActionPreference = 'Stop'
$facts = Join-Path $PSScriptRoot '..' 'module-facts.ps1'

$script:pass = 0; $script:fail = 0
function Ok($cond, $msg) {
    if ($cond) { $script:pass++; Write-Host "  PASS  $msg" -ForegroundColor Green }
    else       { $script:fail++; Write-Host "  FAIL  $msg" -ForegroundColor Red }
}
function Set-File($Path, $Content) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
    Set-Content -LiteralPath $Path -Value $Content -Encoding utf8 -NoNewline
}
function Facts($dir) {
    $out = & pwsh -NoProfile -File $facts -ModuleDir $dir -SkipTemplateCheck -Json 2>$null
    return ($out | ConvertFrom-Json)
}

$root = Join-Path ([System.IO.Path]::GetTempPath()) "modulefacts-$([System.IO.Path]::GetRandomFileName())"
try {
    # v1 TS module that speaks OSC
    $ts = Join-Path $root 'companion-module-v1ts'
    Set-File (Join-Path $ts 'tsconfig.json') '{}'
    Set-File (Join-Path $ts 'package.json') '{"name":"v1ts","version":"1.0.0","type":"module","dependencies":{"@companion-module/base":"~1.14.1","osc":"^2.4.0"}}'
    Set-File (Join-Path $ts 'src/main.ts') 'import osc from "osc"'
    Set-File (Join-Path $ts 'companion/manifest.json') '{"id":"v1ts","runtime":{"entrypoint":"../dist/main.js"}}'

    $f = Facts $ts
    Ok ($f.language -eq 'TS')                           "TS detected (tsconfig + type module)"
    Ok ($f.apiVersion -eq 'v1')                         "v1 detected from base ~1.14.1"
    Ok ($f.apiSkill -eq 'companion-v1-api-compliance')  "selects v1 api-compliance skill"
    Ok (@($f.protocols) -contains 'OSC')                "detects OSC protocol"
    Ok ($f.srcFileCount -eq 1)                          "counts src files"

    # v2 JS module, HTTP
    $js = Join-Path $root 'companion-module-v2js'
    Set-File (Join-Path $js 'package.json') '{"name":"v2js","version":"2.0.0","dependencies":{"@companion-module/base":"~2.0.4","axios":"^1"}}'
    Set-File (Join-Path $js 'src/main.js') 'const axios = require("axios")'

    $f2 = Facts $js
    Ok ($f2.language -eq 'JS')                           "JS detected (no tsconfig, no type module)"
    Ok ($f2.apiVersion -eq 'v2')                         "v2 detected from base ~2.0.4"
    Ok ($f2.apiSkill -eq 'companion-v2-api-compliance')  "selects v2 api-compliance skill"
    Ok (@($f2.protocols) -contains 'HTTP')               "detects HTTP protocol"
}
finally {
    if (Test-Path $root) { Remove-Item -Recurse -Force $root }
}

Write-Host ""
Write-Host "$($script:pass) passed, $($script:fail) failed" -ForegroundColor ($(if ($script:fail) { 'Red' } else { 'Green' }))
if ($script:fail) { exit 1 }
