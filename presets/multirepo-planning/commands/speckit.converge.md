---
description: "Planning-aware converge workflow"
strategy: "wrap"
---

# Specs Repo Prelude

Resolve the active planning feature before following the core command:

1. Run `.specify/extensions/multirepo/scripts/bash/spec-resolve.sh --json` with only extracted `--specs-repo <id>` and `--spec <feature-dir>` values when the user supplied them.
2. Otherwise run `.specify/extensions/multirepo/scripts/bash/spec-resolve.sh --json`.
3. Export/use the returned `SPECIFY_INIT_DIR` and `SPECIFY_FEATURE_DIRECTORY` values for planning artifact reads/writes.
4. Compare code only in selected workset members; append remaining work to the planning `tasks.md` with `[repo:<name>]`, `[workset]`, or `[planning]` selectors.

{CORE_TEMPLATE}
