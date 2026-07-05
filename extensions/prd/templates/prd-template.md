# PRD: {Product Name}

---
title: {Product Name}
status: draft
created: {YYYY-MM-DD}
updated: {YYYY-MM-DD}
feature_directory: {feature_directory}
backlog: {backlog_path}
---

## 0. Document Purpose

State who this PRD is for, what decisions it supports, and whether it feeds one
feature spec directly or a nested spec backlog.

## 1. Vision

Describe what this product or feature is, who it serves, and why it matters.

## 2. Target Users

### Jobs To Be Done

- ...

### Non-Users or Excluded Audiences

- ...

### Key User Journeys

- **UJ-1. <Named protagonist does the thing>**
  - **Persona and context:** ...
  - **Entry state:** ...
  - **Path:** ...
  - **Value moment:** ...
  - **Resolution:** ...

## 3. Glossary

- **Term** - Definition and relationship to other terms.

## 4. Features and Requirements

### 4.1 <Feature Name>

**Description:** Behavioral narrative. Use glossary terms consistently and
reference journeys by ID where useful.

#### FR-1: <Short Capability Name>

<Actor> can <capability> <under conditions>. Realizes UJ-1.

**Consequences:**

- Testable outcome.

**Out of Scope:**

- Optional bound.

## 5. Cross-Cutting Non-Functional Requirements

- **NFR-1:** Requirement with measurable or observable bounds.

## 6. Non-Goals

- Explicitly excluded scope.

## 7. MVP Scope

### In Scope

- ...

### Out of Scope for MVP

- ...

## 8. Success Metrics

- **SM-1:** Metric, target, and related FR IDs.
- **SM-C1:** Counter-metric that should not be optimized at the expense of the
  product goal.

## 9. Open Questions

- **Q1:** ...

## 10. Assumptions Index

- Inline assumption from section X - short description.

## 11. Backlog Guidance

Add this section only when the PRD is too large for one implementation spec.

- Suggested child specs and outcomes.
- Dependency or rollout order.
- Requirements that must stay together.
- Requirements that can be deferred.

## Adapt-In Sections

Add only the sections this product actually needs:

- Constraints and guardrails: safety, privacy, cost, compliance.
- Stakeholders and approvals.
- Integration and dependencies.
- Rollout and change management.
- Data governance.
- Accessibility and inclusive design.
- Public API contracts, versioning, and deprecation.
- Operational requirements: SLAs, support, RTO/RPO.
- Hardware, deployment, or environmental constraints.
