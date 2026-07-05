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
