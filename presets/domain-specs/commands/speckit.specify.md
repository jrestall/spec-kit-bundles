---
description: "Taxonomy-aware specify workflow"
strategy: "wrap"
---

# Spec Taxonomy Prelude

Before following the core command, optionally classify the spec with a domain.
This preset does **not** own the directory shape. Parent specs live wherever
the core command or the user-selected `SPECIFY_FEATURE_DIRECTORY` places them,
and child specs created by `/speckit-spec-decompose` live under:

```text
specs/<parent-feature>/specs/<child-feature>/
```

## Domain Configuration

If present, read the optional domain taxonomy from:

```text
.specify/presets/domain-specs/domain-specs.yml
```

The config may contain:

- `allowed_domains`, a list of domain objects with `id`, `name`, and
  `description`
- `default_domain`, optional

If the file is missing or empty, skip taxonomy handling and continue with the
core command. If present, treat configured `id` values as path-safe metadata
slugs: lowercase letters, digits, and hyphens only.

## Domain Resolution

Resolve the domain as metadata only:

1. If the user explicitly supplied a domain using wording like `domain: <id>`,
   `--domain <id>`, `in <id>`, or `for the <name> domain`, match it to exactly
   one configured domain by `id` or unambiguous `name`.
2. Otherwise, infer a domain from the user's feature prompt only when the
   prompt clearly maps to exactly one configured domain using the domain
   descriptions.
3. If no configured domain is clear, continue without a domain. Do not block
   spec creation just to collect taxonomy.
4. If the user asks for a domain that is not configured, record it as
   `[NEEDS CLARIFICATION: domain '<id>' is not configured]` in the spec rather
   than rejecting the path.

## Path Handling

Preserve the core command's feature-directory behavior:

- If the user explicitly supplied `SPECIFY_FEATURE_DIRECTORY`, use it as-is
  after basic safety checks. Nested paths such as
  `specs/<parent-feature>/specs/<child-feature>` are valid.
- If no explicit path is supplied, let the core command create the feature under
  its normal `specs/<feature>` location.
- Persist the selected path to `.specify/feature.json` exactly as the core
  command does.
- Downstream commands must use the persisted `feature_directory`; they must not
  infer domain or hierarchy from branch names.

## Core Command Adjustment

When writing `spec.md`, add the resolved domain only as metadata if one was
resolved. Prefer a small "Spec Metadata" section near the top:

```markdown
## Spec Metadata

- Domain: <domain-id>
- Parent spec: <path or none>
```

For nested child specs, include the parent path when the selected
`SPECIFY_FEATURE_DIRECTORY` contains `/specs/` beneath another feature.
Preserve all other core behavior, including template resolution, checklist
creation, quality validation, and extension hooks.

{CORE_TEMPLATE}
