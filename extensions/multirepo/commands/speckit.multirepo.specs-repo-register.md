---
description: "Register an existing specs repo checkout on this machine"
scripts:
  sh: .specify/extensions/multirepo/scripts/bash/specs-repo-register.sh
---

## User Input

```text
$ARGUMENTS
```

Run `{SCRIPT} $ARGUMENTS --json`.

Use this for an existing checkout that already has or should receive `.specify/specs-repo.json`. Prefer explicit arguments:

```bash
{SCRIPT} --path <planning-repo> --id <specs-repo-id> --json
```
