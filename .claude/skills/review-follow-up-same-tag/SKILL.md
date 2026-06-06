---
name: review-follow-up-same-tag
description: Handle Companion module follow-up reviews where the maintainer resubmits the same release tag. Use when asked to compare against a prior review and verify fixed vs. unchanged findings without doing a full fresh review.
---

# Review Pattern: Same-Tag Follow-Up

## When to Use

- The pending module version/tag is the same as the prior reviewed version
- The user asks for a follow-up / delta-only review
- You need to verify which prior findings were fixed, which were not, and whether any new issues were introduced

## Process

1. Read the prior review file first and extract its finding IDs and verdict.
2. Confirm whether the current checkout still matches the same release tag.
3. Diff the tag against the current branch to see whether any post-tag changes are outside the release.
4. Re-check only the prior findings plus any changed code in the release delta.
5. Re-validate prior template/config findings against the authoritative template before carrying them forward; a same-tag follow-up can close a prior finding if the original diagnosis was too strict or factually wrong.
6. If there is no module-code delta, carry forward the still-valid prior findings and explicitly say no new release-delta issues were introduced.

## Output Pattern

- Title the review as a re-review / follow-up for the same tag
- State clearly when no release-code delta exists
- Separate:
  - findings fixed
  - blocking findings still open
  - other carried-forward findings
  - new issues introduced in the follow-up delta
- Update `reviews/TRACKER.md` with a new row even if the version string is unchanged
