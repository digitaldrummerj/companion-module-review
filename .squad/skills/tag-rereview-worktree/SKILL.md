# Skill: tag-rereview-worktree

**Description:** Validate a newly submitted tag without disturbing the maintainer's existing checkout by using a detached git worktree for the target tag.

## When to use
- A rereview asks for exact validation of a release tag
- The module repo is not currently checked out at that tag
- You need to run `yarn install` and `yarn package` against the submitted tag itself

## Pattern
1. From the module repo, create a detached worktree for the target tag.
2. In that worktree, run `yarn install` first.
3. Then run `yarn package` and inspect the tagged files directly from the worktree.
4. Remove the worktree after validation.

## Example
```bash
git worktree add --detach ../companion-module-name-review-v1.2.3 v1.2.3
cd ../companion-module-name-review-v1.2.3
yarn install
yarn package
```

## Why it helps
This keeps the maintainer's main checkout unchanged while still producing exact build evidence for the submitted release tag. It's especially useful when comparing `vPrevious` to `vNew` and only the tagged release should be validated.
