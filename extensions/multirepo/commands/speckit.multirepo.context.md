---
description: "Print planning context for the resolved specs repo/spec"
scripts:
  sh: .specify/extensions/multirepo/scripts/bash/context.sh
---

## User Input

```text
$ARGUMENTS
```

Run `{SCRIPT} $ARGUMENTS --json`.

Read the returned `spec`, `plan`, `tasks`, and `workset` paths before
implementing. The resolved spec may be a parent spec or a nested child spec
under `specs/<parent>/specs/<child>`. If the command reports a missing specs
repo or spec, stop and show the fix instead of guessing paths.
