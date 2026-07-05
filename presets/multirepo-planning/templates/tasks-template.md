## Multi-Repo Task Routing

Use these selectors in task descriptions:

- `[planning]`: changes to the planning repo only
- `[repo:<name>]`: implementation work for one workset member
- `[workset]`: validation or coordination across multiple workset members

Example:

```markdown
## Phase 1: Shared Planning

- [ ] T001 [planning] Confirm cross-repo contract in specs/001-feature/contracts/api.md

## Phase 2: web-app

- [ ] T010 [repo:web-app] [US1] Submit cart id from checkout UI in src/App.tsx

## Phase 3: api-server

- [ ] T020 [repo:api-server] [US1] Add order creation endpoint in src/server.ts

## Phase 4: Cross-Repo Validation

- [ ] T030 [workset] Run checkout validation across web-app and api-server
```
