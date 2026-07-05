---
description: "Validate a per-spec workset and local overrides"
scripts:
  sh: .specify/extensions/multirepo/scripts/bash/workset.sh doctor
---

## User Input

```text
$ARGUMENTS
```

Run `{SCRIPT} $ARGUMENTS --json`.

Report which workset members are available locally, which are missing, whether `workset.local.yml` is active, and where the generated `.code-workspace` file lives.
