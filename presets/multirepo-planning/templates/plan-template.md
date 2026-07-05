## Multi-Repo Implementation Scope

| Repo | Role | Relative Path From `workset.yml` | Remote | Spec Impact |
|------|------|----------------------------------|--------|-------------|
| planning | planning | `../..` | `[remote]` | Owns shared spec/plan/tasks |
| web-app | implementation | `../../../web-app` | `[remote]` | `[impact]` |
| api-server | implementation | `../../../api-server` | `[remote]` | `[impact]` |
| design-system | reference | `../../../design-system` | `[remote]` | Read-only implementation context |

## Shared Contracts

- Contract owner:
- Consumer repos:
- Compatibility policy:

## Workset Rules

- Commit `workset.yml` beside this plan.
- Keep paths relative to `workset.yml`.
- Assume implementation repos are siblings of the planning repo.
- Use `role: reference` for repos that should be opened for context but not edited.
- Allow personal path overrides in gitignored `workset.local.yml`.
