📌 Imported from squad-export on 2026-04-01T20:41:10.786Z. Portable knowledge carried over; project learnings from previous project preserved below.

# Project Context

- **Owner:** Justin James
- **Project:** BitFocus Companion module for Custom AV Controller for Zoom Room Controller application communicating via OSC protocol
- **Stack:** TypeScript, Node.js, BitFocus Companion SDK
- **Created:** 2026-03-13

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### Workspace Restructuring — 2026-04-04

**Note:** Module repositories (companion-module-softouch-easyworship, companion-module-autodirector-mirusuite, companion-module-template-js, companion-module-template-ts) have been **moved out of the review repo** and now live in a sibling directory: `../companion-modules-reviewing/` relative to the review repo root. The review repo itself contains only the templates and review artifacts in `reviews/`. Build scripts and VSCode workspace configuration have been updated to reference the new sibling location. When cloning or setting up the development environment, use `COMPANION_MODULES_DIR=../companion-modules-reviewing/` or rely on the auto-derived sibling path.
