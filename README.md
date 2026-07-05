# Spec Kit Bundles

Personal monorepo for Spec Kit extensions, presets, bundles, and workflows.

## Layout

- `extensions/`: reusable Spec Kit extensions.
- `presets/`: reusable Spec Kit presets.
- `bundles/`: bundle manifests that compose extensions and presets.
- `workflows/`: workflow definitions and registries.
- `docs/`: package guides and design notes.
- `specs/`: local Spec Kit planning specs for this collection.
- `tests/stubs/`: stub repos and demo fixtures used to exercise multi-repo flows.

The cloned upstream `spec-kit` repository is intentionally excluded from this
repo. Stub repos are committed as fixtures under `tests/stubs/`, without nested
Git metadata.

## Packages

### Multi-Repo Planning

Provides a `multirepo` extension and `multirepo-planning` preset for shared
specs repos and per-spec worksets.

Install locally during development:

```bash
specify extension add --dev ./extensions/multirepo
specify preset add --dev ./presets/multirepo-planning --priority 5
```

Bundle manifest:

```text
bundles/multirepo-planning/bundle.yml
```

Guide:

```text
docs/multirepo-planning/user-guide.md
```

### Domain Specs

Provides a compatibility `domain-specs` preset that records optional domain
metadata without owning the spec path shape. Nested parent/child spec structure
is handled by `/speckit-spec-decompose`.

Install locally during development:

```bash
specify preset add --dev ./presets/domain-specs --priority 10
```

Preset manifest:

```text
presets/domain-specs/preset.yml
```

### PRD

Provides a `prd` extension with `/speckit-prd` for creating, updating, and
validating product requirements documents in Spec Kit workspaces.

Install locally during development:

```bash
specify extension add --dev ./extensions/prd
```

Guide:

```text
docs/prd/user-guide.md
```

### Spec Decompose

Provides a `spec-decompose` extension with `/speckit-spec-decompose` for
turning large PRDs or parent specs into `backlog.md` plus nested child Spec Kit
specs under `specs/<parent>/specs/<child>/`.

Install locally during development:

```bash
specify extension add --dev ./extensions/spec-decompose
```

Bundle manifest:

```text
bundles/planning-method/bundle.yml
```

Guide:

```text
docs/spec-decompose/user-guide.md
```
