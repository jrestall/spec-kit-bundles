---
description: "Create a spec-of-specs backlog with child Spec Kit specs"
---

# Spec Decompose

Decompose a large PRD or parent Spec Kit spec into a **spec of specs**: one
parent initiative directory with a `backlog.md` map and nested child Spec Kit
feature directories under `specs/`.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding.

## Target Shape

```text
specs/<parent-feature>/
├── prd.md                  # optional but preferred product requirements
├── spec.md                 # parent/initiative spec
├── backlog.md              # child spec map, coverage, dependencies, deferrals
└── specs/
    ├── 001-<child-slice>/
    │   └── spec.md
    └── 002-<child-slice>/
        └── spec.md
```

Each child directory is a normal Spec Kit feature directory. After creating the
backlog, select a child and run the usual lifecycle:

```text
/speckit-spec-select specs/<parent-feature>/specs/001-<child-slice>
/speckit-plan
/speckit-tasks
/speckit-analyze
/speckit-implement
```

`/speckit-analyze` and related commands work on the active child because they
resolve `FEATURE_DIR` from `.specify/feature.json` or
`SPECIFY_FEATURE_DIRECTORY`, then read `spec.md`, `plan.md`, and `tasks.md`
inside that directory.

## Resolve Parent Spec

Resolve the parent feature directory:

1. If the user supplied `--parent <path>`, use it. The path may be absolute or
   relative to the Spec Kit root.
2. Else if `.specify/feature.json` exists, read `feature_directory` and use
   that as the parent.
3. Else ask for the parent feature directory or PRD path.
4. If the multirepo extension is active and the user supplied `--specs-repo`,
   resolve the specs repo first, then resolve the parent beneath that root.

The parent directory must contain at least one of:

- `prd.md`
- `spec.md`
- `prd/prd.md` from older PRD-extension runs
- a user-supplied source document path

If the only PRD is `prd/prd.md`, prefer reading it but write any new PRD work
to parent-level `prd.md` going forward.

## Step 1: Extract Requirements

Read the selected source documents:

- Parent `prd.md` or legacy `prd/prd.md`
- Parent `spec.md`
- Parent `plan.md`, `research.md`, `data-model.md`, `contracts/`, if present
- UX/design docs named by the user or present as `ux.md`, `design.md`, or
  `prd-addendum.md`

Ask the user whether any discovered source should be excluded or whether more
inputs should be included. In headless mode, include all discovered sources and
record assumptions.

Extract:

- Functional requirements (`FR-1`, `FR-2`, ...), preserving existing IDs.
- Non-functional requirements (`NFR-1`, `NFR-2`, ...).
- User journeys or major workflows (`UJ-1`, `UJ-2`, ...).
- UX/design requirements (`UX-DR-1`, `UX-DR-2`, ...).
- Constraints, dependencies, rollout boundaries, integration contracts, and
  risk boundaries that affect backlog structure.

## Step 2: Design Child Specs

Create child specs around coherent, independently plannable slices:

- Each child spec must deliver a meaningful user or platform outcome.
- A child spec may depend only on earlier child specs or external systems named
  in the parent.
- Avoid technical-layer children like "database setup" unless that setup is a
  standalone platform capability with real downstream value.
- Consolidate slices when they churn the same core files without a feedback or
  risk boundary.
- Split slices when early feedback, compliance review, integration risk, team
  ownership, or context size makes separation useful.

For each proposed child spec, define:

- Directory slug: `NNN-short-name`
- Title
- User/business outcome
- Requirements covered
- Dependencies
- Out of scope
- Expected next command (`/speckit-plan` unless more clarification is required)

Present the proposed backlog and get explicit approval before writing
child spec files. If the user requests changes, revise and re-present.

## Step 3: Write Artifacts

1. Resolve `backlog-template` through the Spec Kit stack when
   possible. If unavailable, use this command's target shape.
2. Write or update `<parent>/backlog.md`.
3. Create `<parent>/specs/` if it does not exist.
4. For each approved child:
   - Create `<parent>/specs/<NNN-short-name>/`.
   - Write `<parent>/specs/<NNN-short-name>/spec.md`.
   - Resolve `child-spec-template` when possible; otherwise write a normal
     Spec Kit-style `spec.md` with functional requirements, success criteria,
     user scenarios, assumptions, and out-of-scope notes.
   - Include frontmatter linking the child to its parent:

     ```yaml
     ---
     parent_spec: ../..
     backlog: ../../backlog.md
     status: draft
     depends_on: []
     covered_requirements: []
     ---
     ```

5. Do **not** write child `plan.md` or `tasks.md`; those belong to the normal
   child lifecycle.
6. Optionally set `.specify/feature.json` to the first child spec if the user
   asks to start implementing a child immediately.

## Step 4: Validate Backlog

Before reporting completion, verify:

- Every parent FR is covered by at least one child or explicitly deferred.
- Every child has a clear outcome and bounded scope.
- Child dependencies do not point forward.
- Child specs contain enough detail for `/speckit-plan`.
- Parent `prd.md`, parent `spec.md`, and `backlog.md` agree on terminology.
- Nested paths are relative and portable.

If validation fails, fix `backlog.md` and affected child `spec.md` files
before reporting completion.

## Headless Result

When invoked by automation, do not ask questions. End with JSON:

```json
{
  "status": "complete|partial|blocked",
  "parent_feature_directory": "<path>",
  "backlog": "<parent>/backlog.md",
  "child_specs": ["<parent>/specs/001-child/spec.md"],
  "active_child": "<path or null>",
  "coverage_summary": {
    "fr_total": 0,
    "fr_covered": 0,
    "deferred": 0
  },
  "assumptions": [],
  "open_questions": [],
  "reason": "<required when blocked>"
}
```

Use `partial` when artifacts exist but unresolved open questions make child
planning risky.

## Done When

- Parent `backlog.md` exists.
- Child directories under `<parent>/specs/` each contain a `spec.md`.
- The user knows which child spec to select next and which normal Spec Kit
  command to run.
