---
description: "Domain-aware specify workflow"
strategy: "wrap"
---

# Domain Specs Prelude

Before following the core command, choose and persist a spec domain. This preset
stores specs under `specs/<domain>/<feature>` and uses domain-scoped numbering.

## Domain Configuration

Read the allowed domain set from:

```text
.specify/presets/domain-specs/domain-specs.yml
```

If that file is missing or cannot be parsed, stop with:

```text
ERROR: Domain specs preset config not found. Reinstall the domain-specs preset or restore .specify/presets/domain-specs/domain-specs.yml.
```

The config must contain:

- `numbering_scope: "domain"`
- `allowed_domains`, a non-empty list of domain objects with `id`, `name`, and `description`

Treat the `id` values as the only valid domain identifiers. Domain IDs must be
lowercase path-safe slugs: letters, digits, and hyphens only. Do not invent or
normalize to a domain that is not listed in the config.

## Domain Resolution

Resolve the domain before creating any files:

1. If the user explicitly supplied a domain using wording like `domain: <id>`,
   `--domain <id>`, `in <id>`, or `for the <name> domain`, match it to exactly
   one configured domain by `id` or unambiguous `name`.
2. Otherwise, infer the domain from the user's feature prompt only when the
   prompt clearly maps to exactly one configured domain using the domain
   descriptions.
3. If no configured domain is clear, or more than one configured domain is
   plausible, ask the user to choose from the configured domain list before
   continuing. Present only configured domains. Do not offer a default.
4. If the user asks for a domain that is not configured, stop and explain that
   the domain must be added to `domain-specs.yml` before it can be used.

Do not proceed to the core workflow until a single configured domain has been
chosen.

## Domain-Scoped Feature Directory

After generating the core short name, create the feature directory under the
chosen domain:

1. If the user explicitly supplied `SPECIFY_FEATURE_DIRECTORY`, validate it
   before using it:
   - It must match `specs/<configured-domain-id>/<feature-directory-name>`.
   - The domain path segment must be one of the configured domain IDs.
   - If a domain was also resolved from the prompt, it must match the domain
     path segment in `SPECIFY_FEATURE_DIRECTORY`.
   - If it does not pass these checks, stop and explain that feature
     directories are limited to configured domains.
2. If `SPECIFY_FEATURE_DIRECTORY` was not supplied, set `DOMAIN_DIR` to
   `specs/<domain-id>`.
3. Determine the next feature number by scanning only immediate child
   directories under `DOMAIN_DIR`.
   - For sequential numbering, match directories beginning with `NNN-` where
     `NNN` is three or more digits.
   - Ignore directories that begin with timestamp prefixes
     `YYYYMMDD-HHMMSS-`.
   - The next number is one greater than the highest matched number in that
     domain, or `001` when none exist.
4. Construct the feature directory name as `<NNN>-<short-name>`.
5. Set `SPECIFY_FEATURE_DIRECTORY` to
   `specs/<domain-id>/<NNN>-<short-name>`.
6. Create only that directory and `spec.md`.
7. Persist the selected path to `.specify/feature.json` exactly as:

```json
{
  "feature_directory": "specs/<domain-id>/<NNN>-<short-name>"
}
```

Downstream commands must use the persisted `feature_directory`; they must not
try to re-infer the domain from the git branch or the prompt.

## Core Command Adjustment

When following the core command below, replace its default auto-generation under
`specs/<directory-name>` with the domain-scoped behavior above. Preserve all
other core behavior, including spec template resolution, checklist creation,
quality validation, and extension hooks.

{CORE_TEMPLATE}
