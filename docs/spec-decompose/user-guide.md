# Spec Decompose Extension

The `spec-decompose` extension turns a large PRD or parent spec into a
**spec of specs**: a parent feature directory with a backlog map and nested
child Spec Kit specs.

## Install Locally

```bash
specify extension add --dev ./extensions/spec-decompose
```

## Commands

- `/speckit-spec-decompose` or `/speckit.spec-decompose`
- Compatibility aliases: `/speckit-create-epics-and-specs` and
  `/speckit.create-epics-and-specs`

## Shape

```text
specs/<parent-feature>/
├── prd.md
├── spec.md
├── backlog.md
└── specs/
    ├── 001-<child-slice>/
    │   └── spec.md
    └── 002-<child-slice>/
        └── spec.md
```

Each child directory is a normal Spec Kit feature directory. Select a child,
then use the standard lifecycle:

```text
/speckit-spec-select specs/<parent-feature>/specs/001-<child-slice>
/speckit-plan
/speckit-tasks
/speckit-analyze
/speckit-implement
```

## Inputs

The command reads parent-level artifacts:

- `prd.md`
- `spec.md`
- `plan.md`
- `research.md`
- `data-model.md`
- `contracts/`
- UX/design docs named by the user

Legacy PRD extension output at `prd/prd.md` can be read, but new PRDs should
live at parent-level `prd.md`.

## Outputs

- `backlog.md` with child spec map, dependency order, coverage, and deferrals.
- `specs/<child>/spec.md` files ready for `/speckit-plan`.

The command does not create child `plan.md` or `tasks.md`; those belong to the
normal child spec lifecycle.
