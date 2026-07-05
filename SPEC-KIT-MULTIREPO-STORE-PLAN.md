# Spec Kit Multi-Repo Planning Store Plan

## Goal

Replicate OpenSpec's standalone planning store and multi-repo context model in Spec Kit using Spec Kit's existing extension, preset, and bundle primitives.

The target experience:

- A planning repo owns cross-repo `spec.md`, `plan.md`, `tasks.md`, and supporting design artifacts.
- App/service repos can reference a planning repo without copying planning artifacts.
- Implementation still runs in selected code repos or a selected multi-root workset.
- Each spec can include a committed default workset so teams do not have to rebuild folder sets manually.

## Spec Kit Baseline

Spec Kit is directory-scoped. The project root is the nearest directory containing `.specify/`.

The core workflow stores features under:

```text
specs/<feature>/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── tasks.md
```

Core scripts already provide two useful axes:

- `SPECIFY_INIT_DIR`: selects the Spec Kit project root.
- `SPECIFY_FEATURE_DIRECTORY`: selects the active feature directory inside that project.

That gives us the natural Spec Kit equivalent of OpenSpec's root and change selection:

- selected planning root -> resolves to `SPECIFY_INIT_DIR=<planning-repo>`
- spec id -> resolves to `SPECIFY_FEATURE_DIRECTORY=specs/<feature>`

## Root Selection Model

Users should not have to pass `--store` when they are already inside the planning repo. The committed `.specify/store.json` is enough to identify the nearest Spec Kit project as a planning store.

Root resolution should mirror OpenSpec's store-selection model:

1. Explicit `--store <id>` selects a registered planning store from the machine-local registry.
2. Otherwise, the nearest ancestor containing `.specify/` wins.
   - If that project contains `.specify/store.json`, it is a planning store root.
   - If it is a normal code repo, commands act on that repo's local Spec Kit project unless the command explicitly asks for an upstream planning store.
3. If no local `.specify/` root exists but the user names a store/spec, resolve through the registry and ask for `--store <id>` when ambiguous.
4. If a code repo declares references in `.specify/multirepo.yml`, those references are read-only context and never redirect where commands write.

Practical guidance for agent prompts:

```text
Store selection: If the user names a planning store, or the work lives in a registered planning store while the current directory is outside that store, run the store list/resolve helper and target that store. If the current directory is already inside a Spec Kit project with .specify/store.json, use the nearest planning root and do not require --store. Without an explicit or self-identifying planning store, commands act on the nearest local .specify/ root.
```

So:

```bash
# Inside planning/: no store flag needed
/speckit.plan
/speckit.tasks

# From api-server/ while targeting shared planning:
/speckit.implement --store team-planning --spec 001-cross-repo-checkout --repo api-server
```

## Packaging Shape

Ship this from the bundle monorepo:

```text
spec-kit-bundles/
├── bundles/
│   └── multirepo-planning/
│       └── bundle.yml
├── extensions/
│   └── multirepo/
│       ├── extension.yml
│       ├── commands/
│       ├── scripts/bash/
│       └── templates/
└── presets/
    └── multirepo-planning/
        ├── preset.yml
        ├── commands/
        ├── templates/
        └── scripts/
```

Use the extension for new capabilities and helper scripts. Use the preset to override core workflow prompts/templates so `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`, and `/speckit.implement` understand stores, references, and per-spec worksets.

## Files And State

### Machine-Local Registry

Store registry should be machine-local, not committed:

```text
~/.specify/stores/registry.json
```

Shape:

```json
{
  "version": 1,
  "stores": {
    "team-planning": {
      "path": "/abs/path/to/planning",
      "remote": "git@github.com:org/planning.git"
    }
  }
}
```

This is equivalent to OpenSpec's store registry.

### Planning Store Repo

A planning repo is just a Spec Kit project with a store metadata file:

```text
planning/
├── .specify/
│   ├── memory/constitution.md
│   └── store.json
└── specs/
    └── 001-cross-repo-checkout/
        ├── spec.md
        ├── plan.md
        ├── tasks.md
        ├── workset.yml
        └── ...
```

`.specify/store.json`:

```json
{
  "version": 1,
  "id": "team-planning",
  "kind": "planning-store",
  "remote": "git@github.com:org/planning.git"
}
```

### Code Repo Reference

Code repos reference planning stores in committed config:

```text
api-server/
└── .specify/
    └── multirepo.yml
```

Example:

```yaml
version: 1
references:
  - id: team-planning
    remote: git@github.com:org/planning.git
```

This does not redirect normal Spec Kit commands. It only tells agents where upstream planning context can be found.

### Per-Spec Default Workset

Unlike OpenSpec's personal-only worksets, this proposal commits a default workset beside the spec:

```text
planning/specs/001-cross-repo-checkout/workset.yml
```

Example:

```yaml
version: 1
name: checkout-default
description: Default repos for checkout implementation
members:
  - name: planning
    role: planning
    store: team-planning
    path: .
  - name: web-app
    role: implementation
    repo: web-app
    remote: git@github.com:org/web-app.git
    path: ../../../web-app
  - name: api-server
    role: implementation
    repo: api-server
    remote: git@github.com:org/api-server.git
    path: ../../../api-server
task_routing:
  web-app:
    selectors:
      - "## web-app"
      - "[repo:web-app]"
  api-server:
    selectors:
      - "## api-server"
      - "[repo:api-server]"
```

Workset paths are relative to the `workset.yml` file. In the default layout, referenced repos are siblings of the planning repo:

```text
workspace/
├── planning/
│   └── specs/001-cross-repo-checkout/workset.yml
├── web-app/
└── api-server/
```

So `../../../web-app` from `planning/specs/001-cross-repo-checkout/workset.yml` resolves to the sibling `web-app/` checkout.

Allow a gitignored adjacent local override:

```text
planning/specs/001-cross-repo-checkout/
├── workset.yml
└── workset.local.yml   # gitignored
```

`workset.local.yml` can override member paths without changing the shared default:

```yaml
version: 1
members:
  web-app:
    path: /Users/alex/src/web-app
  api-server:
    path: /Volumes/fast/api-server
```

For this release, do not include a repo catalog or group expansion. A spec's committed workset lists the actual implementation repos for that spec only.

## Commands

### Extension Commands

Provide these commands through `planning-store`:

```text
/speckit.planning.store.setup
/speckit.planning.store.register
/speckit.planning.store.list
/speckit.planning.store.doctor
/speckit.planning.spec.select
/speckit.planning.context
/speckit.planning.workset.open
/speckit.planning.workset.doctor
```

Script-level helpers should expose JSON for agents:

```bash
.specify/extensions/planning-store/scripts/bash/store-list.sh --json
.specify/extensions/planning-store/scripts/bash/store-resolve.sh team-planning --json
.specify/extensions/planning-store/scripts/bash/root-resolve.sh --json
.specify/extensions/planning-store/scripts/bash/spec-resolve.sh --spec 001-cross-repo-checkout --json
.specify/extensions/planning-store/scripts/bash/spec-resolve.sh --store team-planning --spec 001-cross-repo-checkout --json
.specify/extensions/planning-store/scripts/bash/context.sh --spec 001-cross-repo-checkout --json
.specify/extensions/planning-store/scripts/bash/workset.sh open --spec 001-cross-repo-checkout --tool codex --json
```

Minimum JSON for `spec-resolve`:

```json
{
  "store": {"id": "team-planning", "path": "/abs/planning"},
  "feature": {
    "id": "001-cross-repo-checkout",
    "directory": "/abs/planning/specs/001-cross-repo-checkout",
    "spec": "/abs/planning/specs/001-cross-repo-checkout/spec.md",
    "plan": "/abs/planning/specs/001-cross-repo-checkout/plan.md",
    "tasks": "/abs/planning/specs/001-cross-repo-checkout/tasks.md",
    "workset": "/abs/planning/specs/001-cross-repo-checkout/workset.yml"
  },
  "env": {
    "SPECIFY_INIT_DIR": "/abs/planning",
    "SPECIFY_FEATURE_DIRECTORY": "specs/001-cross-repo-checkout"
  }
}
```

### Preset Overrides

Override every core agent workflow command that reads or writes feature artifacts. Partial override is risky: a non-overridden command can fall back to the nearest code repo's local `specs/` directory, miss the selected planning store, or update the wrong `tasks.md`.

Required core command overrides:

- `speckit.constitution`
- `speckit.specify`
- `speckit.clarify`
- `speckit.checklist`
- `speckit.plan`
- `speckit.tasks`
- `speckit.analyze`
- `speckit.implement`
- `speckit.converge`
- `speckit.taskstoissues`

Do not override `specify` CLI administration commands through this preset (`specify init`, `specify extension`, `specify preset`, `specify bundle`, `specify integration`, `specify workflow`, `specify self`). Those remain normal Spec Kit project-management surfaces. The planning-store extension may add its own admin commands for registry and workset management.

Each override should preserve core behavior, but add the same planning-store prelude:

1. Resolve the active root:
   - explicit `--store <id>` if supplied
   - nearest `.specify/store.json` planning root if already inside one
   - nearest normal `.specify/` root otherwise
2. If the active command is planning-store scoped, export/use `SPECIFY_INIT_DIR` and `SPECIFY_FEATURE_DIRECTORY` for the selected planning repo/spec.
3. If the command is running from a code repo with references, load reference metadata as read-only context, but do not redirect writes.
4. Apply command-specific behavior:
   - `constitution`: edit the selected root's constitution; planning stores may own product/architecture principles while code repos own local engineering principles.
   - `specify`, `clarify`, `checklist`, `plan`, `tasks`, `analyze`, `converge`, `taskstoissues`: operate on the resolved planning feature directory.
   - `implement`: load per-spec `workset.yml`, select tasks by repo/workset, and edit only requested implementation roots.
5. If the current agent cannot access all requested implementation members, stop with exact clone/open instructions.

## Artifact Template Changes

### `spec-template.md`

Add metadata near the top:

```markdown
**Planning Store**: `[store-id]`
**Implementation Workset**: `workset.yml`
**Affected Repos**: `[repo-a, repo-b]`
```

Keep the feature requirements user-focused and tech-neutral.

### `plan-template.md`

Add a multi-repo section:

```markdown
## Multi-Repo Implementation Scope

| Repo | Role | Local Path | Remote | Spec Impact |
|------|------|------------|--------|-------------|
| web-app | implementation | ../web-app | git@... | UI checkout |
| api-server | implementation | ../api-server | git@... | order API |

## Shared Contracts

- Contract owner:
- Consumer repos:
- Compatibility policy:
```

### `tasks-template.md`

Group tasks by repo and story:

```markdown
## Phase 1: Shared Planning

- [ ] T001 [planning] Confirm cross-repo contract in specs/.../contracts/order-api.md

## Phase 2: web-app

- [ ] T010 [repo:web-app] [US1] Submit cart id from checkout UI in src/App.tsx

## Phase 3: api-server

- [ ] T020 [repo:api-server] [US1] Add order creation endpoint in src/server.ts

## Phase 4: Cross-Repo Validation

- [ ] T030 [workset] Run checkout integration validation across web-app and api-server
```

This makes implementation selection deterministic:

- running inside `web-app` defaults to `[repo:web-app]` tasks
- running inside `api-server` defaults to `[repo:api-server]` tasks
- running from a full workset can perform all `[repo:*]` tasks it has access to

## Implementation Flow

### Planning Once

```bash
specify init planning --integration codex --preset multirepo-planning
/speckit.planning.store.setup team-planning
cd planning
/speckit.specify "Add checkout across web and API"
/speckit.plan "React web app, TypeScript API"
/speckit.tasks
```

The generated feature lives only in the planning repo:

```text
planning/specs/001-cross-repo-checkout/
```

### Implementation Per Repo

From `web-app`:

```text
/speckit.implement --store team-planning --spec 001-cross-repo-checkout --repo web-app
```

The command:

1. Resolves `team-planning`.
2. Loads the planning spec's `spec.md`, `plan.md`, `tasks.md`, and `workset.yml`.
3. Selects only `[repo:web-app]` tasks.
4. Edits only the current repo.
5. Marks only completed web-app tasks in the planning repo's `tasks.md`.

From `api-server`:

```text
/speckit.implement --store team-planning --spec 001-cross-repo-checkout --repo api-server
```

Same flow, but task selector is `[repo:api-server]`.

### Implementation From Workset

```text
/speckit.planning.workset.open --store team-planning --spec 001-cross-repo-checkout --tool codex
```

Then:

```text
/speckit.implement --store team-planning --spec 001-cross-repo-checkout --all-repos
```

The command may edit every implementation member available in the launched workset.

## Missing Store Or Missing Repo Behavior

If the planning store id is missing from the local registry:

- commands that explicitly target `--store <id>` fail
- the error includes clone/register instructions
- if `remote` is present, print an exact `git clone` plus register command

If the user is already inside a planning repo with `.specify/store.json`, the registry is not required for that local command. The store metadata should still be checked for validity, but local planning commands can proceed from the nearest root.

If a code repo references an unregistered planning store:

- local code-repo Spec Kit commands still run
- planning-store context is reported as unavailable
- implementation of a shared planning spec requires registering or opening that planning store first

If a workset member repo is missing locally:

- implementation does not silently skip it
- workset doctor reports unavailable member
- implementation can proceed only for explicitly selected available repos

## Task Marking Rules

The planning `tasks.md` is the shared checklist. Agents may mark a task done only when:

- the task's repo selector matches the current edit root or opened workset
- the relevant tests/checks for that repo were run or explicitly documented as not runnable
- the actual code change is present in the matching repo

Recommended task ID format:

```text
T010 [repo:web-app] ...
T020 [repo:api-server] ...
T030 [workset] ...
T040 [planning] ...
```

## Scale Guidance For 1,000 Repos

Do not try to make every code repo discoverable from the planning store automatically.

Use two levels for the first release:

1. Store registry: where planning repos live on this machine.
2. Per-spec `workset.yml`: names the small implementation subset for this feature, using sibling-relative paths by default.

This keeps the agent prompt small, avoids stale mega-workspaces, and gives every team a committed default starting point. A repo catalog can be revisited after the simple sibling-repo convention has been used in anger.

## MVP Build Order

1. Extension with registry and context scripts.
2. Store setup/register/list/doctor commands.
3. Preset that overrides all core agent workflow prompts with the shared planning-store prelude.
4. Per-spec `workset.yml` template and validator.
5. `workset.local.yml` overlay support and `.gitignore` guidance.
6. Workset open command for VS Code/Cursor first.
7. Shell-script wrapper implementation only; defer Python-backed `specify planning ...` subcommands.
8. CLI agent launch support for Codex/Claude after editor workflow works.

## Differences From OpenSpec

| Concern | OpenSpec | Proposed Spec Kit Extension |
|---|---|---|
| Planning root | registered standalone OpenSpec store | registered Spec Kit planning project |
| Change layout | `openspec/changes/<change>` | `specs/<feature>` |
| Active root selection | `--store <id>` or nearest `openspec/` root | `--store <id>` from outside, or nearest `.specify/store.json` inside planning repo |
| Active work selection | change id | spec feature directory |
| References | read-only store index | `.specify/multirepo.yml` read-only planning reference |
| Worksets | personal local views | committed default `workset.yml` beside each spec, plus optional local overrides |
| Implementation routing | explicit repo/workset | explicit repo/workset, with `[repo:<id>]` task selectors |

## Open Questions

- Should task completion be committed to the planning repo immediately, or should each implementation PR update planning tasks in a paired planning PR?
