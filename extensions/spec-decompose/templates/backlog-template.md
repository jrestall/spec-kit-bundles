---
status: draft
parent_feature_directory: {parent_feature_directory}
input_documents: []
children: []
---

# Backlog: {Parent Feature Name}

## Purpose

This backlog maps a large parent PRD/spec into child Spec Kit specs that can be
planned, tasked, analyzed, and implemented independently.

## Parent Sources

- `prd.md`
- `spec.md`

## Requirements Inventory

### Functional Requirements

{fr_list}

### Non-Functional Requirements

{nfr_list}

### User Journeys

{uj_list}

### UX and Design Requirements

{ux_dr_list}

## Child Spec Map

| Child | Outcome | Requirements Covered | Depends On | Status |
|-------|---------|----------------------|------------|--------|
| [`001-child`](specs/001-child/spec.md) | ... | FR-1 | None | draft |

## Coverage Map

| Requirement | Child Specs | Notes |
|-------------|-------------|-------|
| FR-1 | `001-child` | ... |

## Dependency Order

1. `001-child`

## Deferred or Out of Scope

- ...

## Validation Notes

- No forward dependencies.
- Every child can run through `/speckit-plan`, `/speckit-tasks`, and
  `/speckit-analyze` as an active feature directory.
