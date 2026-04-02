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

```bash
TOKEN=$(gh auth token)
```

This uses the token from the GitHub CLI's existing auth. It works out of the box on any machine where `gh auth login` has been run.

All API calls in this skill use this pattern:
```bash
curl -s -H "Authorization: Bearer $TOKEN" "https://developer.bitfocus.io/api/v1/..."
```

## API Endpoints

**Base URL:** `https://developer.bitfocus.io/api/v1`

OpenAPI spec: `https://developer.bitfocus.io/openapi.yaml`

### List Pending Reviews

```bash
TOKEN=$(gh auth token)
curl -s -H "Authorization: Bearer $TOKEN" \
  "https://developer.bitfocus.io/api/v1/modules-pending-review"
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
- Returns all modules currently in the manual review queue (as of 2026-04-02: ~31 pending)
- `moduleName` is lowercase kebab-case, no `companion-module-` prefix
- `moduleType` is always `companion-connection` for this workspace
- `gitTag` is the tag submitted for review — some have `v` prefix, some don't

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

## Workflows

### Workflow 1: Show Pending Queue

```bash
TOKEN=$(gh auth token)
WORKSPACE="/Users/lynbh/Development/companion-module-review"

# 1. Fetch pending list
PENDING=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "https://developer.bitfocus.io/api/v1/modules-pending-review")

# 2. Parse and display
echo "$PENDING" | python3 -c "
import sys, json, os
d = json.load(sys.stdin)
versions = d.get('versions', [])
workspace = '$WORKSPACE'
print(f'## Pending Reviews ({len(versions)} total)\n')
print('| Module | Tag | Cloned? | Age |')
print('|--------|-----|---------|-----|')
for v in versions:
    name = v['moduleName']
    tag = v['gitTag']
    cloned = os.path.isdir(f'{workspace}/companion-module-{name}')
    from datetime import datetime, timezone
    ts = datetime.fromtimestamp(v['createdAt']/1000, tz=timezone.utc)
    age = (datetime.now(tz=timezone.utc) - ts).days
    status = '✅ Yes' if cloned else '⬜ No'
    print(f'| {name} | {tag} | {status} | {age}d |')
"
```

### Workflow 2: Get Previous Approved Tag

```bash
TOKEN=$(gh auth token)
MODULE_NAME="softouch-easyworship"  # substitute target module

VERSIONS=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "https://developer.bitfocus.io/api/v1/public/modules/companion-connection/$MODULE_NAME/versions")

echo "$VERSIONS" | python3 -c "
import sys, json
d = json.load(sys.stdin)
versions = d.get('versions', [])
approved = [v for v in versions if v['status'] == 'APPROVED']
# Sort by createdAt descending
approved.sort(key=lambda v: v.get('createdAt', ''), reverse=True)
if approved:
    print(approved[0]['gitTag'])
else:
    print('NO_PREVIOUS_TAG')
"
```

If the result is `NO_PREVIOUS_TAG`, it means this is the module's first-ever release — all code is new and all findings are eligible to block.

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

```bash
MODULE_NAME="softouch-easyworship"  # substitute target module
WORKSPACE="/Users/lynbh/Development/companion-module-review"
REPO_URL="https://github.com/bitfocus/companion-module-$MODULE_NAME"
TARGET_DIR="$WORKSPACE/companion-module-$MODULE_NAME"

# Check if already cloned
if [ -d "$TARGET_DIR" ]; then
  echo "Already cloned at $TARGET_DIR"
else
  cd "$WORKSPACE" && git clone "$REPO_URL"
  echo "Cloned to $TARGET_DIR"
fi
```

### Workflow 5: Full Discovery-to-Review Pipeline

For a single module (triggered by "review {moduleName}" when it's not yet cloned):

```bash
TOKEN=$(gh auth token)
MODULE_NAME="allenheath-sq"
WORKSPACE="/Users/lynbh/Development/companion-module-review"

# 1. Get pending tag
PENDING_TAG=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "https://developer.bitfocus.io/api/v1/modules-pending-review" | \
  python3 -c "
import sys, json
d = json.load(sys.stdin)
for v in d.get('versions', []):
    if v['moduleName'] == '$MODULE_NAME':
        print(v['gitTag'])
        break
")

# 2. Get previous approved tag
PREV_TAG=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "https://developer.bitfocus.io/api/v1/public/modules/companion-connection/$MODULE_NAME/versions" | \
  python3 -c "
import sys, json
d = json.load(sys.stdin)
approved = sorted([v for v in d.get('versions',[]) if v['status']=='APPROVED'],
                  key=lambda v: v.get('createdAt',''), reverse=True)
print(approved[0]['gitTag'] if approved else 'NO_PREVIOUS_TAG')
")

# 3. Clone if needed
TARGET_DIR="$WORKSPACE/companion-module-$MODULE_NAME"
if [ ! -d "$TARGET_DIR" ]; then
  cd "$WORKSPACE" && git clone "https://github.com/bitfocus/companion-module-$MODULE_NAME"
fi

echo "Module: $MODULE_NAME"
echo "Review tag: $PENDING_TAG"
echo "Previous tag: $PREV_TAG"
echo "Directory: $TARGET_DIR"
```

After this, hand the module name + both tags to the Coordinator to start the standard review fan-out.

## Ralph's Queue Check

When Ralph checks work health, he should:
1. Run Workflow 1 to get the pending list with clone status
2. Report: how many pending, how many cloned (awaiting review), how many not yet cloned
3. Identify the oldest pending module not yet reviewed (by `createdAt`)

```bash
TOKEN=$(gh auth token)
WORKSPACE="/Users/lynbh/Development/companion-module-review"

curl -s -H "Authorization: Bearer $TOKEN" \
  "https://developer.bitfocus.io/api/v1/modules-pending-review" | python3 -c "
import sys, json, os
from datetime import datetime, timezone
d = json.load(sys.stdin)
versions = d.get('versions', [])
cloned = [v for v in versions if os.path.isdir(f'$WORKSPACE/companion-module-{v[\"moduleName\"]}')]
not_cloned = [v for v in versions if not os.path.isdir(f'$WORKSPACE/companion-module-{v[\"moduleName\"]}')]
oldest = sorted(not_cloned, key=lambda v: v['createdAt'])[0] if not_cloned else None
print(f'Pending: {len(versions)} total')
print(f'Cloned (awaiting review): {len(cloned)}')
print(f'Not yet cloned: {len(not_cloned)}')
if oldest:
    ts = datetime.fromtimestamp(oldest[\"createdAt\"]/1000, tz=timezone.utc)
    age = (datetime.now(tz=timezone.utc) - ts).days
    print(f'Next up: {oldest[\"moduleName\"]} {oldest[\"gitTag\"]} (waiting {age} days)')
"
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `gh: command not found` | Install GitHub CLI: `brew install gh` then `gh auth login` |
| API returns `{"error": "Unauthorized"}` | Run `gh auth login` and re-authenticate with GitHub |
| Module repo not found at derived URL | Verify with `gh repo view bitfocus/companion-module-{name}` |
| `NO_PREVIOUS_TAG` from previous-tag lookup | First-ever release — all findings are eligible to block (treat as new code) |
| Module already in workspace but old | `cd companion-module-{name} && git fetch --tags` |

## References

- OpenAPI spec: `https://developer.bitfocus.io/openapi.yaml`
- GitHub CLI docs: `gh help auth`
- BitFocus developer portal: `https://developer.bitfocus.io`
