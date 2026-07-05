# PRD Extension

The `prd` extension adds a Spec Kit-native PRD workflow using Spec Kit artifacts
and paths.

## Install Locally

```bash
specify extension add --dev ./extensions/prd
```

## Commands

- `/speckit-prd` or `/speckit.prd` - create, update, or validate a PRD.

## Artifacts

When a feature is active, the command writes to:

```text
specs/<feature>/
├── prd.md
├── prd-addendum.md
├── prd-decision-log.md
└── prd-validation-report.md
```

Without an active feature, the command creates or asks for a parent feature
directory under `specs/<short-name>/`.

## Workflow Shape

- Create: discovery, draft, rubric review, open-item triage, finalization.
- Update: reconcile an existing PRD with a change signal and record decisions.
- Validate: critique without editing and write `validation-report.md`.

The PRD is written for product and planning decisions. Implementation details
belong in `prd-addendum.md`, `plan.md`, or child specs created by
`/speckit-spec-decompose`.
