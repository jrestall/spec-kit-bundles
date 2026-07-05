---
description: "Open the per-spec workset in an editor or agent harness"
scripts:
  sh: .specify/extensions/multirepo/scripts/bash/workset.sh open
---

## User Input

```text
$ARGUMENTS
```

Run `{SCRIPT} $ARGUMENTS`.

Supported tools:

- `--tool code`: write/open the generated `.code-workspace` in VS Code
- `--tool cursor`: write/open the generated `.code-workspace` in Cursor
- `--tool claude`: launch Claude Code with `--add-dir` for each available member
- `--tool codex`: launch Codex with `--sandbox workspace-write --add-dir ...`
- `--tool workspace`: print the generated workspace file path without launching a tool

If no tool is provided, the script prefers VS Code, then Cursor, then prints the workspace file path.
