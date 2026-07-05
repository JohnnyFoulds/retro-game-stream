# Specification-Driven Development — Learner Guide

## The big idea

When you ask an AI to write code, you become an **editor**, not an author. Your job is to decide whether what the AI produced is correct. You can only do that if you already know what "correct" looks like.

That written-down description of correct is the **specification**.

```
Specification ≻ AI output
```

The spec comes first. Always.

---

## Why this matters

Without a spec, you accept AI output because it *looks reasonable* — not because you can prove it is right. This works until it doesn't, and when it fails it fails silently.

With a spec, you accept AI output because it satisfies the preconditions, postconditions, and acceptance criteria you wrote *before* the AI touched the keyboard.

---

## The development loop

Every feature in this course follows one loop:

```
1. Write the requirement
2. Write the acceptance criterion
3. Write the design contract
4. Prompt the AI to implement
5. Test against the acceptance criterion
6. Commit with evidence
```

You do not move to step 4 until steps 1–3 are written down and reviewed.

---

## The five spec components

Every requirement has five parts. All five must exist before you implement.

### R — What must the system do?

One sentence. Use **MUST** for things that are required, **SHOULD** for strong recommendations, **MAY** for optional behaviour.

> **R-007:** The game MUST remove a dollar sign from the world and increment the score by 1 when the player occupies a dollar-sign cell.

### I — What are the types and procedures involved?

List the data types and procedure signatures that will be added or changed.

> **I-007:** `score: Integer` (global in GAME.PAS)
> Procedure: `CollectDollar(var W: TWorld; var score: Integer; x, y: Integer)`

### P — What must be true before this runs?

What does the caller have to guarantee?

> **P-007:** The world has been initialised. `(x, y)` is within bounds. The tile at `(x, y)` is `tileDollar`.

### Q — What must be true after this runs?

What changed? What must not have changed?

> **Q-007:** The tile at `(x, y)` is now `tileEmpty`. Score is `score + 1`. All other tiles are unchanged.

### N — What are the constraints and limits?

Performance, scope, platform compatibility.

> **N-007:** No visual change until the next render cycle. Must compile under Turbo Pascal 7.

---

## The acceptance criterion

Write one test per requirement, identified as **T-NNN**. It describes a concrete, observable sequence:

> **T-007: Dollar collection**
>
> 1. Start a world with a dollar sign at position (5, 3). Score = 0.
> 2. Move the player to (5, 3).
> 3. **Expect:** The dollar sign disappears from the screen. Score displays as 1.

The acceptance criterion is how you know the implementation is done. If you cannot describe a test, you do not yet understand the requirement.

---

## Prompting the AI

Once the spec is written, give the AI a bounded prompt:

```
Implement R-007.

Modify only WORLD.PAS, GAME.PAS, tests/manual-acceptance-tests.md,
and docs/traceability-matrix.md.

Do not change RENDER.PAS.
Do not add sound effects or animations.
Run the build and show the diff before proposing a commit.
```

Four things every implementation prompt must have:
1. The requirement ID
2. The exact files to modify
3. What NOT to do
4. "Show the diff before proposing a commit"

---

## Reviewing the AI's output

After the AI produces code, check these five things before accepting it:

1. Does it satisfy the postcondition (Q)?
2. Does it check the precondition (P) before acting?
3. Did it only touch the files you named?
4. Does T-NNN pass when you run it manually?
5. Is the traceability matrix updated?

If any of these is no — send it back. Do not commit code that does not satisfy its own specification.

---

## The commit

A commit is an engineering claim, not a save. It says: "this code satisfies requirement R-NNN, I have tested it, it builds."

```
feat(R-007): implement dollar collection

- Remove dollar sign when player enters its cell
- Increment score by 1
- Add acceptance test T-007
- Update traceability matrix

Build: passed
Tests: passed
```

No build evidence → no commit. No test evidence → no commit.

---

## What you own

The AI writes code. You own everything else:

- The requirement
- The acceptance criterion
- The design contract (I, P, Q, N)
- The review of the diff
- The commit message
- The decision to accept or reject

The AI is a fast, capable tool. You are the engineer.

---

## Quick reference

| Step | What you write | Where it lives |
| --- | --- | --- |
| Requirement | R-NNN in RFC 2119 language | `docs/requirements.md` |
| Acceptance criterion | T-NNN with numbered steps | `tests/manual-acceptance-tests.md` |
| Interface | I-NNN: types and signatures | `docs/technical-design.md` |
| Preconditions | P-NNN: caller obligations | `docs/technical-design.md` |
| Postconditions | Q-NNN: what changed / didn't | `docs/technical-design.md` |
| Non-functional | N-NNN: limits and scope | `docs/technical-design.md` |
| Traceability | Row in matrix | `docs/traceability-matrix.md` |
