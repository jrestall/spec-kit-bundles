---
description: "Planning-aware plan workflow"
strategy: "wrap"
---

# Specs Repo Prelude

Resolve the active planning feature before following the core command:

1. Run `.specify/extensions/multirepo/scripts/bash/spec-resolve.sh --json` with only extracted `--specs-repo <id>` and `--spec <feature-dir>` values when the user supplied them.
2. Otherwise run `.specify/extensions/multirepo/scripts/bash/spec-resolve.sh --json`.
3. Export/use the returned `SPECIFY_INIT_DIR` and `SPECIFY_FEATURE_DIRECTORY` values for all core script calls.
4. Before running `.specify/scripts/bash/setup-plan.sh`, require the active feature's `workset.yml` to exist at the path returned by `spec-resolve.sh`.
5. If `workset.yml` is missing, stop immediately and warn the user. Do not run setup, create `plan.md`, or continue planning. Tell the user to create `workset.yml` beside the active feature's `spec.md`, using `.specify/extensions/multirepo/templates/workset-template.yml` as the starting template if helpful, then run `/speckit.workset-open [--specs-repo <id>] [--spec <feature-dir>]` so the planning step has the planning repo and implementation repos in context.
6. Once `workset.yml` exists, read it and include its implementation members in the plan's Multi-Repo Implementation Scope.

{CORE_TEMPLATE}
