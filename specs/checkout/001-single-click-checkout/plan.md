## Multi-Repo Implementation Scope

| Repo | Role | Relative Path From `workset.yml` | Remote | Spec Impact |
|------|------|----------------------------------|--------|-------------|
| planning | planning | `../../..` | `[remote]` | Owns shared spec/plan/tasks |
| web-app | implementation | `../../../tests/stubs/web-app` | `[remote]` | `[impact]` |
| api-server | implementation | `../../../tests/stubs/api-server` | `[remote]` | `[impact]` |

## Shared Contracts

- Contract owner:
- Consumer repos:
- Compatibility policy:

## Workset Rules

- Commit `workset.yml` beside this plan.
- Keep paths relative to `workset.yml`.
- Test fixture implementation repos live under `tests/stubs/`.
- Use `role: reference` for repos that should be opened for context but not edited.
- Allow personal path overrides in gitignored `workset.local.yml`.
