# PRD Validation Rubric

Use this as a judgment rubric, not a checkbox list. Calibrate rigor to the
stated stakes and the product shape.

## Output Format

```markdown
# PRD Validation Report - <PRD Name>

## Overall Verdict
2-3 sentences naming what holds up and what is at risk.

## Dimension Verdicts
- Decision-readiness - strong|adequate|thin|broken|n/a
- Substance over theater - strong|adequate|thin|broken|n/a
- Strategic coherence - strong|adequate|thin|broken|n/a
- Done-ness clarity - strong|adequate|thin|broken|n/a
- Scope honesty - strong|adequate|thin|broken|n/a
- Downstream usability - strong|adequate|thin|broken|n/a
- Shape fit - strong|adequate|thin|broken|n/a

## Findings by Severity

### Critical
- **Title** (section) - note. Fix: suggested fix.

### High

### Medium

### Low

## Mechanical Notes
- Glossary drift, ID continuity, broken cross-references, assumptions index
  round-trip, or formatting issues.
```

## Dimensions

### Decision-Readiness

Can a decision-maker act on the PRD? Are trade-offs, open questions, and
deferred decisions surfaced honestly?

### Substance Over Theater

Does every section earn its place? Flag boilerplate personas, vague NFRs,
generic vision language, and template furniture that does not change decisions.

### Strategic Coherence

Does the PRD have a thesis? Do features, MVP scope, and success metrics support
that thesis instead of reading like an unprioritized backlog?

### Done-Ness Clarity

Would engineering, UX, or QA know what done means? Requirements need testable
consequences, measurable bounds where appropriate, and clear acceptance signals.

### Scope Honesty

Are non-goals, assumptions, and deferred items explicit? High open-item density
is acceptable only when the PRD is intentionally early-stage.

### Downstream Usability

Can `/speckit-plan`, `/speckit-tasks`, and `/speckit-spec-decompose`
extract from it cleanly? Check stable IDs, glossary consistency, resolved
cross-references, and journey/requirement links.

### Shape Fit

Does the PRD match the work? Consumer and UX-heavy products usually need
journeys; internal tools may need capability clarity; regulated work needs
constraint traceability; hobby work should stay lightweight.
