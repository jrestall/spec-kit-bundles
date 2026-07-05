# Multi-Repo Planning: Plan in One Repo, Implement Across Many

> **Prototype bundle.** This guide describes the local
> `multirepo-planning` bundle in this workspace. Command names,
> file formats, and install mechanics may change if this becomes an upstream
> Spec Kit extension, preset, or first-class feature.

## The Problem This Solves

Spec Kit normally keeps specs, plans, and tasks in one project. That is a
good fit when one feature maps to one repo.

It gets awkward when the plan is bigger than one checkout:

- One feature touches the web app, API server, and maybe a shared package.
- Product or architecture planning happens before implementation repos are
  chosen.
- A team owns requirements centrally, but many implementation teams need the
  same context.
- You have hundreds or thousands of repos, and asking every developer to
  rebuild the same multi-folder workspace by hand does not scale.

This bundle adds a **specs repo** model to Spec Kit. A specs repo is
a normal git repo that owns shared specs, plans, tasks, and per-spec
worksets. Implementation repos stay separate.

## The Shape

```text
            planning  (a Spec Kit specs repo)
            ├── .specify/
            │   └── specs-repo.json        identity: "I am team-planning"
            └── specs/
                └── 001-checkout/
                    ├── spec.md       shared requirements
                    ├── plan.md       shared design and repo scope
                    ├── tasks.md      one routed task list
                    ├── workset.yml   committed default repo set
                    └── workset.local.yml  personal overrides, gitignored
                      ▲
                      │ paths are relative to workset.yml
        ┌─────────────┼─────────────┐
        │             │             │
    web-app       api-server     mobile-app
   (code repo)   (code repo)    (code repo)
```

Two rules keep the model simple:

1. **A specs repo is just a git repo.** The bundle does not clone,
   fetch, push, or sync for you. You use normal git workflows.
2. **Worksets declare local context.** A committed `workset.yml` gives the
   team a default set of repos for a spec. Each developer can add a
   gitignored `workset.local.yml` beside it when their checkout paths differ.

## Install the Bundle

From this workspace, install the extension and preset directly:

```bash
specify extension add --dev ./extensions/multirepo
specify preset add --dev ./presets/multirepo-planning --priority 5
```

The bundle file records the intended composition, but direct primitive
install is the reliable local-development path until this is published or
bundled upstream.

## Five Minutes to Your First Specs Repo

Start with a Spec Kit project that will become the planning repo:

```bash
mkdir -p ~/src/planning
cd ~/src/planning
specify init
```

Then mark it as a specs repo:

```text
/speckit.specs-repo-setup --id team-planning --remote git@github.com:org/planning.git
```

That command writes:

```json
{
  "version": 1,
  "id": "team-planning",
  "kind": "specs-repo",
  "remote": "git@github.com:org/planning.git"
}
```

to `.specify/specs-repo.json`, registers this checkout in the local machine
registry, and adds ignore rules for:

```gitignore
specs/**/workset.local.yml
```

From inside the planning repo, you do not need to pass a specs repo flag. The
bundle resolves the nearest `.specify/` root, sees `.specify/specs-repo.json`,
and treats that repo as the active specs repo.

## Story: One Team, One Planning Repo

A team keeps product requirements, technical plans, and routed task lists in
`team-planning`.

**Day one, by whoever creates the repo:**

```bash
cd ~/src/planning
specify init
```

```text
/speckit.specs-repo-setup --id team-planning --remote git@github.com:org/planning.git
```

Commit and push the planning repo like any other repo:

```bash
git add .specify/specs-repo.json .gitignore specs
git commit -m "Initialize specs repo"
git remote add origin git@github.com:org/planning.git
git push -u origin main
```

**Every teammate, once per machine:**

```bash
git clone git@github.com:org/planning.git ~/src/planning
cd ~/src/planning
```

```text
/speckit.specs-repo-register --id team-planning --path ~/src/planning
```

After that, teammates can work from inside the planning repo without
passing `--specs-repo`.

## Planning a Cross-Repo Feature

Create or select a feature the usual Spec Kit way, but do it in the planning
repo:

```text
/speckit.specify Build checkout across the web app and API server
```

The preset wraps core Spec Kit commands so they first resolve the active
planning root. If you are already inside the planning repo, the wrapper uses
`.specify/specs-repo.json`. If you are somewhere else, pass the specs repo
explicitly:

```text
/speckit.plan --specs-repo team-planning
```

`--spec` is optional once Spec Kit has selected a feature. The selected
feature is stored in `.specify/feature.json`, which points at the active
feature directory. For a decomposed initiative, that active directory can be a
nested child such as `specs/001-parent/specs/001-child`. Pass
`--spec <feature-dir>` when you want to override the selection.

Before running `/speckit.plan` for a multi-repo feature, commit a
`workset.yml` beside the spec:

```yaml
version: 1
name: "checkout-default"
description: "Default implementation workset for checkout"
members:
  - name: planning
    role: planning
    specsRepo: team-planning
    path: ../..
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
  - name: design-system
    role: reference
    repo: design-system
    remote: git@github.com:org/design-system.git
    path: ../../../design-system
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

`task_routing` tells agents how to map a shared `tasks.md` back to workset
members. In the example above, a task belongs to `web-app` if it appears
under a `## web-app` heading or carries a `[repo:web-app]` selector. The
shell scripts do not currently execute this routing; it is committed
machine-readable guidance for AI workflows and future automation.

`role: reference` members are opened with the workset so agents can inspect
shared contracts, design-system code, examples, or generated clients. They
are not implementation targets: do not route tasks to them and do not edit
them during `/speckit.implement`.

The paths are relative to `workset.yml`. For a spec at
`planning/specs/001-checkout/workset.yml`, `../../../web-app` resolves to a
sibling of the planning repo.

The default workset lives beside the spec and is committed, so a team with
many repos can share the expected implementation context.

If `/speckit.plan` cannot find `workset.yml` for the active feature, it stops
before creating or updating `plan.md`. Create the workset first, then open it
with `/speckit.workset-open` so planning has the planning repo and the
implementation repos in context.

## Personal Path Overrides

If your machine does not use the team-default sibling layout, add
`workset.local.yml` beside the committed workset:

```yaml
members:
  web-app:
    path: ../../../../my-checkouts/web-app
  api-server:
    path: /Users/you/src/services/api-server
```

`workset.local.yml` is intentionally ignored. It only overrides fields for
your checkout.

Check the result:

```text
/speckit.workset-doctor
```

The doctor reports the committed workset path, whether local overrides are
active, the generated workspace file, and which members are available.

## Opening the Workset

Open the planning repo and implementation repos together:

```text
/speckit.workset-open --tool code
```

Supported tools:

- `--tool code`: open the generated `.code-workspace` in VS Code.
- `--tool cursor`: open the generated `.code-workspace` in Cursor.
- `--tool claude`: launch Claude Code with `--add-dir` for each available
  member.
- `--tool codex`: launch Codex with `--sandbox workspace-write --add-dir ...`.
- `--tool workspace`: print the generated `.code-workspace` path without
  launching anything.

If no tool is provided, the opener tries VS Code, then Cursor, then prints
the workspace path.

The generated workspace file is written beside the spec:

```text
specs/001-checkout/workset.code-workspace
```

## Implementation Flow

The planning repo owns the shared lifecycle:

```text
/speckit.specify
/speckit.clarify
/speckit.workset-open
/speckit.plan
/speckit.tasks
/speckit.analyze
/speckit.implement
/speckit.converge
```

The preset wraps those core commands with specs-repo resolution. In
practice, implementation works like this:

1. Resolve the active planning spec.
2. Read `spec.md`, `plan.md`, `tasks.md`, and `workset.yml` from the
   planning repo.
3. Select tasks by `--repo <name>`, by the current repo name, or by
   `--all-repos` when the agent has access to every member.
4. Read `role: reference` members for context only.
5. Edit only the selected `role: implementation` repo roots.
6. Mark tasks complete in the planning repo only after the matching code
   change exists and checks were run or documented.

Use task selectors to make this unambiguous:

```markdown
## Phase 1: Shared Planning

- [ ] T001 [planning] Confirm checkout contract in specs/001-checkout/contracts/api.md

## Phase 2: web-app

- [ ] T010 [repo:web-app] [US1] Submit cart id from checkout UI in src/App.tsx

## Phase 3: api-server

- [ ] T020 [repo:api-server] [US1] Add order creation endpoint in src/server.ts

## Phase 4: Cross-Repo Validation

- [ ] T030 [workset] Run checkout validation across web-app and api-server
```

When you run implementation for one repo, the agent should only take that
repo's tasks:

```text
/speckit.implement --repo api-server
```

For coordinated work across every available member:

```text
/speckit.implement --all-repos
```

Add `--spec <feature-dir>` to either command when you want to override the
feature selected in `.specify/feature.json`.

## Context Commands for Agents

Use context when you want to see exactly what the wrapper will resolve:

```text
/speckit.context
```

The command returns the specs repo, feature directory, and paths for:

- `spec.md`
- `plan.md`
- `tasks.md`
- `workset.yml`
- `workset.local.yml`

Use specs repo listing and health checks when a teammate's machine differs:

```text
/speckit.specs-repo-list
/speckit.specs-repo-doctor --specs-repo team-planning
```

## What Happens If the Specs Repo Is Missing?

If a command is run outside a planning repo and no `--specs-repo` is provided,
the resolver looks for the nearest `.specify/` root. If it cannot find one,
it stops and reports the fix:

```text
Run specify init, cd into a specs repo, or pass --specs-repo <id>.
```

If `--specs-repo team-planning` is provided but that specs repo is not registered on
the machine, it stops instead of guessing:

```text
Specs repo 'team-planning' is not registered.
```

The intended fix is:

```bash
git clone git@github.com:org/planning.git ~/src/planning
```

```text
/speckit.specs-repo-register --id team-planning --path ~/src/planning
```

The bundle does not auto-clone specs repos or implementation repos. That is
deliberate: repository access, branch choice, and local checkout location
stay under developer control.

## Command Reference

Specs repo commands:

```text
/speckit.specs-repo-setup --id <id> [--remote <url>] [--path <repo>]
/speckit.specs-repo-register --id <id> --path <repo>
/speckit.specs-repo-list
/speckit.specs-repo-doctor [--specs-repo <id>]
/speckit.spec-select [--specs-repo <id>] [--spec <feature-dir>]
/speckit.context [--specs-repo <id>] [--spec <feature-dir>]
/speckit.workset-doctor [--specs-repo <id>] [--spec <feature-dir>]
/speckit.workset-open [--specs-repo <id>] [--spec <feature-dir>] [--tool <tool>]
```

These are short aliases. The canonical extension command names keep the
`multirepo` namespace, for example:

```text
/speckit.multirepo.workset-open
```

Core Spec Kit workflows are wrapped by the preset:

```text
/speckit.constitution
/speckit.specify
/speckit.clarify
/speckit.checklist
/speckit.plan
/speckit.tasks
/speckit.analyze
/speckit.implement
/speckit.converge
/speckit.taskstoissues
```

## Practical Conventions

- Put shared requirements, design, and task routing in the planning repo.
- Put implementation code in the implementation repos.
- Commit `workset.yml` beside each multi-repo spec.
- Do not commit `workset.local.yml`.
- Keep default workset paths relative and sibling-oriented.
- Use `role: reference` for read-only context repos.
- Use `[repo:<name>]`, `[planning]`, and `[workset]` task selectors.
- Run `workset-doctor` before implementation when a feature spans repos.
- Treat missing workset members as a setup problem, not permission to invent
  paths or clone automatically.
