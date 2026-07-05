---
description: "Resolve or select a spec in a specs repo"
scripts:
  sh: .specify/extensions/multirepo/scripts/bash/spec-resolve.sh
---

## User Input

```text
$ARGUMENTS
```

Run `{SCRIPT} $ARGUMENTS --json`.

Use this before specs-repo scoped work when the active feature is ambiguous.
Nested child specs are valid active specs; pass their full path, for example:

```text
/speckit-spec-select specs/001-parent/specs/001-child
```

Keep the returned `SPECIFY_INIT_DIR` and `SPECIFY_FEATURE_DIRECTORY` values on
follow-up commands.
