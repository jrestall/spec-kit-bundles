---
description: "Create, update, or validate a product requirements document"
---

# Spec Kit PRD

Use this command when the user wants a product requirements document before or
alongside the normal Spec Kit `spec.md` workflow.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding.

## Spec Kit Context

Resolve the active Spec Kit project before writing files:

1. If `.specify/feature.json` exists, read `feature_directory` and treat that
   directory as the active feature workspace.
2. If the user explicitly supplied `--feature-dir <path>` or a path to an
   existing feature directory, use that path.
3. Otherwise, ask whether to attach the PRD to an existing feature directory or
   create a new parent feature directory under `specs/<short-name>`.
4. If the project uses the multirepo extension and the user supplied
   `--specs-repo <id>`, resolve the specs repo first using
   `.specify/extensions/multirepo/scripts/bash/root-resolve.sh --specs-repo <id> --json`.
5. The PRD workspace is the feature directory itself. A parent feature may later
   contain nested child specs under `<feature-dir>/specs/`.

Write these files in the PRD workspace:

- `prd.md` - the primary requirements document.
- `prd-addendum.md` - material that is useful downstream but too detailed or too
  implementation-specific for the PRD.
- `prd-decision-log.md` - append-only run memory for decisions, assumptions,
  changes, and deferrals.
- `prd-validation-report.md` - created only by validation or reviewer passes.

Append one line to `decision-log.md` for every durable decision:

```markdown
- YYYY-MM-DD [decision|assumption|change|deferral|event]: concise note and reason.
```

## Intent

Detect one of three intents:

- **Create** - no PRD exists or the user asks to start one.
- **Update** - a PRD exists and the user provides a change signal.
- **Validate** - the user asks for critique, readiness review, or validation.

If ambiguous, ask one short clarifying question. In non-interactive/headless
contexts, infer from available artifacts; if still ambiguous, stop with a
blocked JSON result.

## Create Flow

1. Create the feature directory if needed and seed `prd-decision-log.md`.
2. Resolve the active `prd-template` through the Spec Kit stack when possible
   (`specify preset resolve prd-template`). If unavailable, use the template
   structure described in `templates/prd-template.md` from this extension.
3. Start `prd.md` with YAML frontmatter:

   ```yaml
   ---
   title: <product or feature name>
   status: draft
   created: YYYY-MM-DD
   updated: YYYY-MM-DD
   feature_directory: <feature-dir or null>
   ---
   ```

4. Run discovery in this order:
   - Brain dump: ask for context and any source docs to read.
   - Stakes calibration: hobby/solo, internal, launch, enterprise/regulatory.
   - Working mode:
     - **Fast path**: batch gaps into one or two consolidated questions, then
       draft with `[ASSUMPTION: ...]` tags.
     - **Coaching path**: walk PM sections together. Offer entry points:
       Vision + Features, Journey-led, or let-me-suggest.
   - Concern scan: identify concerns that matter for this product, such as
     compliance, integrations, privacy, SLAs, cost, public APIs, rollout,
     monetization, or operational support.
5. Draft capabilities and requirements without implementation details. Move
   implementation mechanisms, rejected technical alternatives, deep UX notes,
   sizing data, and architecture hints to `addendum.md`.
6. Keep requirements globally numbered as `FR-1`, `FR-2`, and so on. Keep
   non-functional requirements distinct and testable.
7. Every inferred decision that matters must be tagged inline as
   `[ASSUMPTION: ...]` and mirrored in the Assumptions Index.
8. Before marking the PRD final, run the Finalize flow.

## Update Flow

1. Locate `prd.md`, `prd-addendum.md`, and `prd-decision-log.md`.
2. If `prd-decision-log.md` is missing, create a thin recovered log from visible PRD
   decisions before applying the update.
3. Extract the change signal from the user's message and source documents.
4. Surface conflicts with earlier decisions before editing. Do not silently
   overwrite scope, non-goals, or success metrics.
5. Apply the smallest coherent update across `prd.md`, `prd-addendum.md`, and the
   decision log.
6. Run a targeted validation pass on changed sections and report any remaining
   blockers.

## Validate Flow

Validate without changing `prd.md`.

1. Read the full PRD and `prd-addendum.md` if present.
2. Resolve `prd-validation-rubric` through the Spec Kit stack when possible
   (`specify preset resolve prd-validation-rubric`). If unavailable, use this
   extension's rubric.
3. Review using these dimensions:
   - Decision-readiness
   - Substance over theater
   - Strategic coherence
   - Done-ness clarity
   - Scope honesty
   - Downstream usability
   - Shape fit
4. Write `validation-report.md` with:
   - Overall verdict
   - Dimension verdicts: `strong`, `adequate`, `thin`, `broken`, or `n/a`
   - Findings grouped by severity: `critical`, `high`, `medium`, `low`
   - Mechanical notes for IDs, glossary drift, broken cross-references, and
     assumptions index round-trip
   - Recommended next action: update PRD, proceed to `/speckit-plan`, or proceed
     to `/speckit-spec-decompose`

Do not open a browser automatically. Report the markdown path.

## Finalize Flow

Run this sequence before changing `status: final`:

1. **Decision-log audit**: every decision is captured in the PRD, addendum, or
   a named deferral.
2. **Input reconciliation**: compare user-supplied source docs against the PRD
   and surface missed qualitative details, scope promises, or terminology.
3. **Reviewer pass**: run the same rubric used by Validate. For low-stakes work,
   summarize quietly; for launch/enterprise/regulatory work, show findings and
   resolve critical/high items before continuing.
4. **Open item triage**: resolve phase blockers. Defer non-blockers only with
   owner or revisit condition in `prd-decision-log.md`.
5. **Polish**: tighten structure first, then prose. Preserve IDs and
   cross-references.
6. **Close**: set `status: final`, update `updated`, append an event to
   `decision-log.md`, and report artifact paths.

## Headless Result

When invoked by automation, do not ask questions. End with JSON:

```json
{
  "status": "complete|partial|blocked",
  "intent": "create|update|validate",
  "prd": "<path when produced>",
  "addendum": "<path when produced>",
  "decision_log": "<path when produced>",
  "validation_report": "<path when produced>",
  "assumptions": [],
  "open_questions": [],
  "reason": "<required when blocked>"
}
```

Use `partial` when artifacts exist but unresolved open questions or critical
assumptions make downstream work risky.

## Done When

- The requested PRD intent is complete.
- All artifacts are written inside the resolved Spec Kit workspace.
- The user receives artifact paths and the recommended next Spec Kit command.
