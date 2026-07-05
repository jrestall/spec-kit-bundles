---
description: "Mark this Spec Kit project as a specs repo and register it locally"
scripts:
  sh: .specify/extensions/multirepo/scripts/bash/specs-repo-setup.sh
---

## User Input

```text
$ARGUMENTS
```

Run `{SCRIPT} $ARGUMENTS --json` from the intended planning repo or pass `--path <repo>`.

This command creates `.specify/specs-repo.json` and registers the specs repo in the local machine registry. If the user gives only a specs repo id, use it as `--id`.
