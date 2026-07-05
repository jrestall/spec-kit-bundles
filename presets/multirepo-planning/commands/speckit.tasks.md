---
description: "Planning-aware tasks workflow"
strategy: "wrap"
---

# Specs Repo Prelude

Resolve the active planning feature before following the core command:

1. Run `.specify/extensions/multirepo/scripts/bash/spec-resolve.sh --json` with only extracted `--specs-repo <id>` and `--spec <feature-dir>` values when the user supplied them.
2. Otherwise run `.specify/extensions/multirepo/scripts/bash/spec-resolve.sh --json`.
3. Export/use the returned `SPECIFY_INIT_DIR` and `SPECIFY_FEATURE_DIRECTORY` values for all core script calls.
4. If `workset.yml` exists, group implementation tasks by workset member repo.
5. Every implementation task must include `[repo:<name>]`; cross-repo validation tasks use `[workset]`; planning-only tasks use `[planning]`.

{CORE_TEMPLATE}
