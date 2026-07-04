# Architecture Decision Records (ADRs)

All significant design decisions for this project are recorded as Architecture Decision Records in `docs/decisions/`.

---

## What is an ADR?

An ADR captures a single design decision: what was decided, why, what alternatives were considered, and what consequences follow. It is written at the time the decision is made and kept permanently in the repository.

ADRs are the project's memory for *non-obvious decisions* — things that cannot be re-derived by reading the code, the requirements, or the git log. If a future contributor might reasonably ask "why did we do it this way?", the answer belongs in an ADR.

---

## When to write one

Write an ADR when a decision:

- Has non-obvious motivation (the reason is not visible in the code itself)
- Rules out plausible alternatives (to prevent relitigating the same question)
- Has significant consequences for the rest of the project
- Is likely to be questioned or misunderstood later

You do **not** need an ADR for:
- Decisions that are self-evident from the code or requirements
- Minor implementation details with no architectural consequence
- Temporary decisions that will be revisited immediately

---

## Numbering and naming

Files are numbered sequentially and named descriptively:

```
docs/decisions/
  0001-turbo-pascal-language-choice.md
  0002-ascii-rendering-seam.md
  0003-no-jumping-in-v1.md
```

Numbers are assigned in order of creation. Do not renumber.

---

## Template

```markdown
# NNNN — Short descriptive title

**Status:** Accepted | Superseded by [NNNN](../decisions/NNNN-title.md)
**Date:** YYYY-MM-DD

## Context
Why did this decision need to be made? What problem, constraint, or question prompted it?

## Decision
What was decided? State it clearly and directly.

## Motivation
Why this option? What made it better than the alternatives?
Name the alternatives considered and why they were not chosen.

## Consequences
What does this decision enable?
What does it rule out or make harder?
What should future contributors watch for?
```

---

## Immutability rule

ADRs are **never edited to change their conclusion**. They are a historical record.

If a decision is reversed or superseded:
1. Write a new ADR explaining the new decision and why the old one no longer holds.
2. Update the old ADR's **Status** line to: `Superseded by [NNNN](../decisions/NNNN-title.md)`

This preserves the full decision history, which is especially important in a course context where understanding *why* a decision was made is as valuable as knowing *what* was decided.

---

## References

- M. Nygard, "Documenting Architecture Decisions," *Cognitect Blog*, 2011.
- J. Tyree and A. Akerman, "Architecture Decisions: Demystifying Architecture," *IEEE Software*, vol. 22, no. 2, pp. 19–27, 2005.
