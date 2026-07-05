---
description: "Planning-aware implement workflow"
strategy: "wrap"
---

# Specs Repo Prelude

Resolve the active planning feature before following the core command:

1. Run `.specify/extensions/multirepo/scripts/bash/spec-resolve.sh --json` with only extracted `--specs-repo <id>` and `--spec <feature-dir>` values when the user supplied them.
2. Otherwise run `.specify/extensions/multirepo/scripts/bash/spec-resolve.sh --json`.
3. Export/use the returned `SPECIFY_INIT_DIR` and `SPECIFY_FEATURE_DIRECTORY` values for any core script calls that read the planning artifacts.
4. Run `.specify/extensions/multirepo/scripts/bash/workset.sh doctor --json` with the same extracted `--specs-repo <id>` and `--spec <feature-dir>` values when `workset.yml` exists.
5. Select implementation tasks by explicit `--repo <name>`, by current repo name, or by `--all-repos` only when the agent session has access to those workset members.
6. Treat workset members with `role: reference` as read-only context. Read them when useful, but never select their tasks or edit files in those roots.
7. Edit only the selected `role: implementation` roots. Do not infer or clone extra repos.
8. Mark tasks complete in the planning `tasks.md` only after the matching repo change is present and checks were run or documented.
9. If a requested workset member is unavailable, stop and show the missing path plus the `workset.local.yml` override option.

{CORE_TEMPLATE}
