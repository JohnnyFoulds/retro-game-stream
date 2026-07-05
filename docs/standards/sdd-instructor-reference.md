# Specification-Driven Development — Instructor Reference

## Purpose

This document is the **instructor-facing** theoretical foundation for the SDD methodology taught in this course. It grounds the five-component specification model in formal software engineering theory, explains the academic motivation behind each practice, and provides guidance for teaching each concept. For the learner-facing version, see [sdd-learner-guide.md](sdd-learner-guide.md).

---

## 1. The central principle

```
Specification ≻ AI output
```

The specification is the primary artefact. Code is derived from it. When specification and code conflict, the specification governs and the code is corrected.

This reverses the default instinct of most developers using AI assistants, who treat the generated code as the output and the specification (if it exists at all) as a loose prompt. The course exists to install the correct ordering.

---

## 2. Theoretical grounding

### 2.1 Essential vs accidental complexity

Brooks (1986) distinguishes *essential complexity* (the inherent difficulty of the problem domain) from *accidental complexity* (the difficulty introduced by our tools, processes, and representations). AI code generators dramatically reduce accidental complexity — boilerplate, syntax recall, library lookups — but they do not reduce essential complexity.

Essential complexity cannot be delegated to an AI. A developer who has not specified what the program should do cannot evaluate whether the AI's output is correct. This is the core failure mode the course addresses.

**Teaching implication:** The vibe-code baseline (Module 0) demonstrates this directly. The AI produces plausible-looking code that compiles and runs, but because no requirements exist, there is no basis for accepting or rejecting any of its behaviour.

### 2.2 Cost of defects

Boehm (1981) established empirically that the cost of fixing a defect grows roughly geometrically with the phase in which it is discovered. A requirement error found during specification costs 1× to fix; the same error found during testing costs 10–100×; found in production, 100–1000×.

The SDD loop front-loads discovery: by writing acceptance criteria before implementation, defects are found at the cheapest possible moment. This is especially important when an AI is generating the code — the AI has no way to know it has misunderstood the requirement unless the requirement is written down.

**Teaching implication:** The traceability matrix is not bureaucracy. It is the mechanism by which requirement errors are caught before, not after, implementation.

### 2.3 Formal correctness: Hoare logic

A Hoare triple `{P} C {Q}` asserts: if precondition `P` holds before command `C` executes, then postcondition `Q` holds after. This is the formal basis for Design by Contract (Meyer, 1992).

In SDD, each requirement element is an informal Hoare triple:

| SDD component | Hoare equivalent |
| --- | --- |
| Preconditions (P) | The precondition `{P}` |
| Postconditions / invariants (Q) | The postcondition `{Q}` |
| Acceptance criterion | The test oracle that observes `{Q}` |

This framing makes explicit that an acceptance criterion is a *projection* of the postcondition onto an observable behaviour — not a separate artefact invented after the fact.

**Teaching implication:** When learners struggle to write acceptance criteria, ask them to state the postcondition. The acceptance criterion follows directly.

### 2.4 Information hiding

Parnas (1972) proposed that a module's design secret — the thing most likely to change — should be hidden behind a stable interface. The *rendering seam* in the course game is a direct application: the visual representation of each tile is hidden inside `RENDER.PAS`; all other units work with tile *values* (`TTile` enum), not characters.

**Teaching implication:** The rendering seam is introduced in Module 2 specifically so that Module 3 learners encounter it as an already-made decision, and can be shown *why* it was the right one when they attempt to add a colour variant of a tile in Module 8.

---

## 3. The five mandatory specification components

Every implemented requirement must be traceable to all five components. Omitting any one creates a gap in the evidence chain.

| Code | Component | Question it answers |
| --- | --- | --- |
| R | Functional requirement | What must the system do? |
| I | Interface / schema | What are the data types and structures involved? |
| P | Preconditions | What must be true for this to work? |
| Q | Postconditions / invariants | What must be true after execution? What must never change? |
| N | Non-functional constraints | Latency, memory, compatibility, or scope limits |

### R — Functional requirement

Written in RFC 2119 normative language (MUST, SHALL, SHOULD, MAY). One sentence per requirement where possible.

```
R-007: The game SHALL remove a dollar sign from the world and increment
       the score by 1 when the player occupies a dollar-sign cell.
```

### I — Interface / schema

For Pascal: the type definitions, procedure signatures, and unit-level `var` declarations that are introduced or modified. Written before the implementation.

```
I-007: score: Integer (in GAME.PAS or PLAYER.PAS global state)
       Procedure: CollectDollar(var W: TWorld; var score: Integer; x, y: Integer)
```

### P — Preconditions

What must the caller guarantee? What state must hold when the procedure is invoked?

```
P-007: W has been initialised via InitWorld.
       (x, y) is within world bounds.
       W.Tiles[y][x] = tileDollar.
```

### Q — Postconditions / invariants

What must hold after execution? What must remain unchanged?

```
Q-007: W.Tiles[y][x] = tileEmpty.
       score = score_before + 1.
       All other tiles in W unchanged.
       Player position unchanged.
```

### N — Non-functional constraints

Scope limits, platform constraints, and performance requirements.

```
N-007: No visual change until the next render cycle.
       Compatible with Turbo Pascal 7 / DOS.
       Collection must be detectable in the same game-loop iteration as movement.
```

---

## 4. Normative language

All requirement and specification text uses RFC 2119 keywords:

| Keyword | Meaning |
| --- | --- |
| MUST / SHALL | Absolute requirement; the implementation is non-conforming if this is not satisfied |
| MUST NOT / SHALL NOT | Absolute prohibition |
| SHOULD | Strong recommendation; deviation requires justification |
| SHOULD NOT | Strong discouragement |
| MAY | Optional; the implementation is conforming either way |

**Teaching implication:** This precision prevents the requirement-acceptance-criterion mismatch that is the most common source of AI output being accepted incorrectly. "The player can collect dollars" is not a requirement — it is a wish. "The game SHALL remove a dollar sign when the player occupies its cell" is a requirement.

---

## 5. The SDD development loop

```
Idea
  └─► Requirement (R-NNN)
        └─► Acceptance Criterion (T-NNN)
              └─► Design Decision (I, P, Q, N)
                    └─► Implementation
                          └─► Test (manual acceptance test)
                                └─► Commit (with evidence)
                                      └─► Traceability Matrix update
                                            └─► Playable game
```

**Implementation must not begin before the acceptance criterion is written.** This is the core discipline. The AI is not asked to "implement dollar collection" — it is asked to "implement R-007, which has acceptance criterion T-007 and interface I-007."

---

## 6. AI-assisted development rules

### 6.1 The well-formed prompt

A good AI prompt for implementation:

```
Implement R-007.

Modify only WORLD.PAS, GAME.PAS, tests/manual-acceptance-tests.md,
and docs/traceability-matrix.md.

Do not add new visual effects.
Do not change RENDER.PAS.
Run the build and show the diff summary before proposing a commit.
```

The prompt must:
- Name the requirement ID
- Name the exact files to modify
- Name what NOT to do (scope guard)
- Demand a diff before a commit

### 6.2 Post-generation validation checklist

After the AI generates code, the engineer validates conformance against the specification:

1. Does the code satisfy postcondition Q?
2. Does the code check precondition P before acting?
3. Does the code stay within the stated file scope?
4. Do all acceptance criteria in T-NNN pass?
5. Is the traceability matrix updated?

### 6.3 The Explore → Extract → Specify → Generate workflow

For discovery work (new requirements, design decisions):

1. **Explore** — use AI to survey the problem space: "What are the typical approaches for implementing a physics-based ladder game in a tile-based world?"
2. **Extract** — identify the candidates from the AI's response; do not accept them uncritically
3. **Specify** — write the requirement, interface, and acceptance criterion using the five-component model
4. **Generate** — now ask the AI to implement

Steps 1–3 are in the engineer's hands. Step 4 is delegated to the AI, but within a precisely bounded scope.

---

## 7. Relationship to TDD

SDD and TDD are complementary, not competing:

- TDD says: write a failing test before writing code
- SDD says: write the specification before writing the test

SDD provides the *source* for the test. A test written before a specification exists is testing an unstated assumption — it may pass or fail for the wrong reasons.

In this course, acceptance tests are manual (not automated), because the game runs in a DOS environment and automated UI testing is not practical. The discipline of writing the acceptance criterion *before* implementation is unchanged.

---

## 8. Spec completeness checklist

Before any AI implementation prompt is issued for a requirement:

- [ ] Requirement has a unique ID (R-NNN)
- [ ] Requirement uses RFC 2119 normative language
- [ ] Interface / schema (I) is specified
- [ ] Preconditions (P) are listed
- [ ] Postconditions (Q) are listed, including invariants that must not change
- [ ] Non-functional constraints (N) are stated
- [ ] Acceptance criterion (T-NNN) is written and references R-NNN

---

## 9. Artefact locations

| Artefact | Location |
| --- | --- |
| Requirements | `games/<game>/docs/requirements.md` |
| Technical design (I, P, Q, N) | `games/<game>/docs/technical-design.md` |
| Traceability matrix | `games/<game>/docs/traceability-matrix.md` |
| Acceptance tests | `games/<game>/tests/manual-acceptance-tests.md` |
| ADRs | `docs/decisions/` |

---

## References

- F. P. Brooks Jr., "No Silver Bullet: Essence and Accident in Software Engineering," *Proc. IFIP Congress*, 1986.
- B. W. Boehm, *Software Engineering Economics*. Prentice Hall, 1981.
- C. A. R. Hoare, "An Axiomatic Basis for Computer Programming," *Commun. ACM*, vol. 12, no. 10, pp. 576–580, 1969.
- B. Meyer, *Object-Oriented Software Construction*, 2nd ed. Prentice Hall, 1997.
- D. L. Parnas, "On the Criteria to be Used in Decomposing Systems into Modules," *Commun. ACM*, vol. 15, no. 12, pp. 1053–1058, 1972.
- S. Bradner, "Key Words for Use in RFCs to Indicate Requirement Levels," IETF RFC 2119, 1997.
- M. Fagan, "Design and Code Inspections to Reduce Errors in Program Development," *IBM Systems J.*, vol. 15, no. 3, pp. 182–211, 1976.
