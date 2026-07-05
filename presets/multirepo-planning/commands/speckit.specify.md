---
description: "Planning-aware specify workflow"
strategy: "wrap"
---

# Specs Repo Prelude

Before following the core command, resolve the active root:

1. If the user supplied `--specs-repo <id>` or clearly names a registered specs repo, run `.specify/extensions/multirepo/scripts/bash/root-resolve.sh --specs-repo <id> --json`.
2. Otherwise run `.specify/extensions/multirepo/scripts/bash/root-resolve.sh --json`.
3. If the current directory is already inside a project with `.specify/specs-repo.json`, use that specs repo; no `--specs-repo` is required.
4. If a specs repo was selected, set `SPECIFY_INIT_DIR` to the returned root path before invoking core scripts.
5. Generate the feature under the selected specs repo's `specs/` directory.
6. If the feature spans repos, create `workset.yml` beside `spec.md` using sibling-relative paths and add `workset.local.yml` to the planning repo's ignore rules if it is not already ignored.

{CORE_TEMPLATE}
