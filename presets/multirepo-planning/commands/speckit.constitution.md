---
description: "Planning-aware constitution workflow"
strategy: "wrap"
---

# Specs Repo Prelude

Before following the core command, resolve the active Spec Kit root:

1. If the user supplied `--specs-repo <id>` or names a specs repo, run `.specify/extensions/multirepo/scripts/bash/root-resolve.sh --specs-repo <id> --json`.
2. Otherwise run `.specify/extensions/multirepo/scripts/bash/root-resolve.sh --json`.
3. If the nearest root contains `.specify/specs-repo.json`, treat it as the specs repo and do not ask for `--specs-repo`.
4. If the nearest root is a code repo with `.specify/multirepo.yml`, treat referenced specs repos as read-only context; do not redirect writes unless the user explicitly selected a specs repo.

For `constitution`, edit the constitution for the resolved root. Specs repos may own product and architecture principles; code repos may own repo-local engineering principles.

{CORE_TEMPLATE}
