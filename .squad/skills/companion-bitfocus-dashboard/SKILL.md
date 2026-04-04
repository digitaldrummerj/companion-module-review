---
name: companion-bitfocus-dashboard
description: 'Discover pending Companion module reviews from the BitFocus developer portal API. Use when asked "what''s pending", "show the queue", "what needs reviewing", "check the BitFocus dashboard", "clone a module", or "work through the pending review queue". Provides authenticated access to the pending review list, previous approved tag lookup, GitHub repo URL derivation, and auto-clone workflow.'
---

# BitFocus Developer Portal — Module Discovery

Enables the team to autonomously discover which Companion modules need review, derive their GitHub repo URLs, find the correct diff tags, and clone them into the workspace.

## When to Use This Skill

- User asks "what's pending", "what needs reviewing", "show the queue", "check the dashboard"
- Coordinator needs to discover modules before starting reviews
- Ralph is checking work health and wants to compare what's pending vs. what's already cloned
- User says "clone {module}" or "set up {module} for review"
- User says "review all pending" (triggers Ralph loop)

## Authentication

The BitFocus developer portal accepts **GitHub Bearer tokens**. No extra credentials or cookies needed.

```powershell
$token = gh auth token
```

This uses the token from the GitHub CLI's existing auth. It works out of the box on any machine where `gh auth login` has been run.

All API calls use this pattern:
```powershell
$headers = @{ Authorization = "Bearer $token" }
$data = Invoke-RestMethod -Uri "https://developer.bitfocus.io/api/v1/..." -Headers $headers
```

## API Endpoints

**Base URL:** `https://developer.bitfocus.io/api/v1`

OpenAPI spec: `https://developer.bitfocus.io/openapi.yaml`

### List Pending Reviews

```powershell
$token   = gh auth token
$headers = @{ Authorization = "Bearer $token" }
$data    = Invoke-RestMethod -Uri "https://developer.bitfocus.io/api/v1/modules-pending-review" -Headers $headers
```

**Response shape:**
```json
{
  "versions": [
    {
      "moduleName": "softouch-easyworship",
      "moduleType": "companion-connection",
      "gitTag": "v2.1.0",
      "createdAt": 1773435902059
    }
  ]
}
```

**Notes:**
- `createdAt` is an **epoch millisecond timestamp per `{moduleName, gitTag}` pair** — the date that specific version was submitted for review, NOT the module's original creation date
- `moduleName` is lowercase kebab-case, no `companion-module-` prefix
- `moduleType` is always `companion-connection` for this workspace
- `gitTag` is the tag submitted for review — some have `v` prefix, some don't
- `/modules-pending-review` may include both `PENDING` and `WITHDRAWN` entries — always verify status via `/versions` before acting

### Get Module Versions (for finding previous approved tag)

```bash
TOKEN=$(gh auth token)
curl -s -H "Authorization: Bearer $TOKEN" \
  "https://developer.bitfocus.io/api/v1/public/modules/companion-connection/{moduleName}/versions"
```

**Response shape:**
```json
{
  "versions": [
    {
      "id": 1407,
      "gitTag": "v2.0.2",
      "isPrerelease": false,
      "status": "APPROVED",
      "published": true,
      "createdAt": "2025-05-29T..."
    },
    {
      "id": 1408,
      "gitTag": "v2.1.0",
      "isPrerelease": false,
      "status": "PENDING",
      "published": false,
      "createdAt": "2025-05-30T..."
    }
  ]
}
```

**Status values:**
- `APPROVED` — published and live in Companion
- `PENDING` — awaiting manual review (this is what we need to review)
- `WITHDRAWN` — withdrawn from auto-publish, may also be awaiting manual review
- `REJECTED` — review rejected

## Scripts

All workflows are implemented as PowerShell scripts in `scripts/`. Agents and Justin both run them the same way.

### Show the Pending Queue (read-only)

```powershell
pwsh scripts/bitfocus-queue.ps1
```

- Fetches `/modules-pending-review`, sorts by `createdAt` ascending (oldest first)
- Cross-references workspace for already-cloned modules
- Prints a ranked table: rank, module, tag, days waiting, clone status
- **Never clones anything** — purely informational

### Set Up a Module for Review

```powershell
# Auto-selects the oldest pending module:
pwsh scripts/bitfocus-setup-module.ps1

# Or specify a module explicitly:
pwsh scripts/bitfocus-setup-module.ps1 -ModuleName allenheath-sq
```

- Validates the target version has status `PENDING` (not `WITHDRAWN` or other)
- Fetches the pending `gitTag` and the previous `APPROVED` tag
- Clones `https://github.com/bitfocus/companion-module-{name}` if not already present
- Prints a coordinator summary: module name, review tag, previous tag, directory path

## Workflows (for agents without script access)

### Workflow 1: Show Pending Queue

```powershell
$token      = gh auth token
$headers    = @{ Authorization = "Bearer $token" }
$reviewRoot = "/Users/lynbh/Development/companion-module-review"  # adjust to your path, or derive from script
$modulesDir = if ($env:COMPANION_MODULES_DIR) { $env:COMPANION_MODULES_DIR } else { Join-Path (Split-Path -Parent $reviewRoot) "companion-modules-reviewing" }
$data       = Invoke-RestMethod -Uri "https://developer.bitfocus.io/api/v1/modules-pending-review" -Headers $headers
$now        = [DateTimeOffset]::UtcNow

$data.versions | Sort-Object createdAt | ForEach-Object {
    $days  = [math]::Floor(($now - [DateTimeOffset]::FromUnixTimeMilliseconds($_.createdAt)).TotalDays)
    $cloned = Test-Path (Join-Path $modulesDir "companion-module-$($_.moduleName)")
    [PSCustomObject]@{
        Module  = $_.moduleName
        Tag     = $_.gitTag
        Days    = $days
        Cloned  = $cloned
    }
} | Format-Table -AutoSize
```

### Workflow 2: Get Previous Approved Tag

```powershell
$token      = gh auth token
$headers    = @{ Authorization = "Bearer $token" }
$moduleName = "softouch-easyworship"  # substitute target module

$data = Invoke-RestMethod `
    -Uri "https://developer.bitfocus.io/api/v1/public/modules/companion-connection/$moduleName/versions" `
    -Headers $headers

$previousTag = $data.versions |
    Where-Object { $_.status -eq 'APPROVED' } |
    Sort-Object createdAt -Descending |
    Select-Object -First 1 -ExpandProperty gitTag

if ($previousTag) { $previousTag } else { "NO_PREVIOUS_TAG" }
```

If the result is `NO_PREVIOUS_TAG`, this is the module's first-ever release — all code is new and all findings are eligible to block.

### Workflow 3: Derive GitHub Repo URL

All companion modules are in the `bitfocus` GitHub org. The URL pattern is:

```
https://github.com/bitfocus/companion-module-{moduleName}
```

Examples:
- `softouch-easyworship` → `https://github.com/bitfocus/companion-module-softouch-easyworship`
- `allenheath-sq` → `https://github.com/bitfocus/companion-module-allenheath-sq`
- `behringer-wing` → `https://github.com/bitfocus/companion-module-behringer-wing`

You can also construct the module's developer portal page URL:
```
https://developer.bitfocus.io/modules/companion-connection/{moduleName}
```

### Workflow 4: Clone a Module

```powershell
# Modules live in the companion-modules-reviewing/ sibling directory.
# $modulesDir is derived from the review repo root; override with $env:COMPANION_MODULES_DIR.
$reviewRoot = "/Users/lynbh/Development/companion-module-review"  # or derive from script location
$modulesDir = if ($env:COMPANION_MODULES_DIR) { $env:COMPANION_MODULES_DIR } else { Join-Path (Split-Path -Parent $reviewRoot) "companion-modules-reviewing" }
$moduleName = "softouch-easyworship"  # substitute target module
$cloneDir   = Join-Path $modulesDir "companion-module-$moduleName"

if (Test-Path $cloneDir) {
    Write-Host "Already cloned at $cloneDir"
} else {
    Push-Location $modulesDir
    git clone "https://github.com/bitfocus/companion-module-$moduleName"
    Pop-Location
}
```

### Workflow 5: Verify PENDING Status Before Acting

Always check the module's actual status via `/versions` before cloning or reviewing. `/modules-pending-review` may include `WITHDRAWN` entries alongside `PENDING` ones.

```powershell
$token      = gh auth token
$headers    = @{ Authorization = "Bearer $token" }
$moduleName = "softouch-easyworship"
$pendingTag = "v2.1.0"

$data = Invoke-RestMethod `
    -Uri "https://developer.bitfocus.io/api/v1/public/modules/companion-connection/$moduleName/versions" `
    -Headers $headers

$normalizedPending = $pendingTag -replace '^v', ''

$entry = $data.versions | Where-Object {
    ($_.gitTag -replace '^v', '') -eq $normalizedPending
} | Select-Object -First 1

if ($entry.status -ne 'PENDING') {
    Write-Error "Status is '$($entry.status)' — skipping, only PENDING versions are reviewed"
}
```

## Ralph's Queue Check

When Ralph checks work health, run the queue script:

```powershell
pwsh scripts/bitfocus-queue.ps1
```

Ralph should report:
1. Total pending count
2. How many are already cloned (awaiting review)
3. The oldest pending module (rank 1 in the table) as the next-up recommendation

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `gh: command not found` | Install GitHub CLI: `brew install gh` then `gh auth login` |
| API returns `{"error": "Unauthorized"}` | Run `gh auth login` and re-authenticate with GitHub |
| Module repo not found at derived URL | Verify with `gh repo view bitfocus/companion-module-{name}` |
| `NO_PREVIOUS_TAG` from previous-tag lookup | First-ever release — all findings are eligible to block (treat as new code) |
| Module already in workspace but old | `cd companion-module-{name}; git fetch --tags` |
| `status` is `WITHDRAWN` not `PENDING` | Skip the module — only `PENDING` versions are reviewed |

## References

- OpenAPI spec: `https://developer.bitfocus.io/openapi.yaml`
- GitHub CLI docs: `gh help auth`
- BitFocus developer portal: `https://developer.bitfocus.io`
