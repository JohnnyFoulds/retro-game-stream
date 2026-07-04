# CLAUDE.md — Specification-Driven AI Development Course

This file is the operating guide for AI assistance on this project. Read it before making any changes.

---

## Project standards

| Standard                      | Document                                        |
|-------------------------------|-------------------------------------------------|
| Architecture Decision Records | [docs/standards/adr.md](docs/standards/adr.md) |

All significant design decisions are recorded as ADRs in [docs/decisions/](docs/decisions/). Before questioning or changing a foundational decision, read the relevant ADR first.

---

## What this repository is

This repo has two purposes:

1. **Course design** — developing the instructor materials, structure, and documentation for a one-day corporate training course on Specification-Driven AI Development (SDD).
2. **Trial builds** — working run-throughs of building candidate games, which serve as the instructor's reference implementations (starter, checkpoint, and complete solution).

The pilot targets Vodacom technical employees. The long-term goal is a course open to everyone — including non-technical staff and executives.

The current target game is *The Corporate Ladder: Avoid Middle Management*. Game-specific design lives in [docs/brainstorm/corporate-ladder/](docs/brainstorm/corporate-ladder/). The course structure and pedagogy are intentionally separated from the specific game — see [ADR-0002](docs/decisions/0002-game-course-separation.md).

---

## The five skill clusters this course teaches

Every piece of course material should reinforce one or more of these.

### 1. Specification-Driven Development (SDD)
Decompose a vague idea into small, observable requirements with explicit acceptance criteria *before* touching the AI. The requirement is the unit of work. The full loop:

```
Idea → Requirement → Acceptance Criterion → Design Decision → Code → Test → Commit → Playable
```

### 2. AI usage and prompting discipline
Treat the AI as a *controlled implementation assistant*, not an autonomous developer. A well-formed prompt names the requirement ID, names the files to modify, names what not to do, and demands a diff before a commit.

Good prompt pattern:
```
Implement R-007.

Modify only WORLD.PAS, GAME.PAS, tests/manual-acceptance-tests.md,
and docs/traceability-matrix.md.

Do not add new enemy behaviour.
Do not change rendering.
Run the build and show the diff summary before proposing a commit.
```

### 3. Git as the engineering record
A commit is an engineering claim, not a save. Every commit must carry: requirement ID, what changed, test result, build result. The evidence chain is:

```
playable game → build manifest → commit → diff → requirement
```

Good commit format:
```
R-007 implement dollar collection

- Remove dollar sign when player enters its cell
- Increment score
- Add acceptance test T-007
- Update traceability matrix

Build: passed
Tests: passed
```

### 4. Software design thinking
- Static world (tile enum) vs dynamic entities (player, enemy records)
- Rendering seam: visual representation changes must not ripple into game rules
- Specify update order *before* implementation
- YAGNI vs small intentional seams: don't over-engineer, but don't seal the doors you'll need later

### 5. AI-assisted research and documentation
Use AI productively in the *discovery* phase (requirements, design decisions, extension backlog) as well as the *implementation* phase. These are different modes. The learner is the author throughout both.

---

## The central principle

```
Specification ≻ AI output
```

The specification is always authoritative. The AI proposes; the human accepts or rejects.

---

## Agent operating protocol

For any implementation task in this repository, follow this protocol:

1. Identify the requirement ID.
2. Verify the requirement exists in the game's `docs/requirements.md`.
3. Verify the relevant design contract exists in the game's `docs/technical-design.md`.
4. Modify the **smallest necessary file set** — name them explicitly before starting.
5. Make no changes outside the stated scope. Do not add features not in the current requirement.
6. After code changes: run the build/test process (or describe what should be run).
7. Show changed files and a diff summary.
8. Update `docs/traceability-matrix.md`.
9. Propose a commit message in the format above.
10. Do not commit without explicit human approval.

### Never do the following

- Rewrite the whole project
- Invent new mechanics not in the requirements
- Silently change or extend requirements
- Commit without review
- Publish a broken build
- Add game-specific details to this file or README — those belong in the game's brainstorm folder

---

## Repository structure

```
retro-game-stream/
  README.md
  CLAUDE.md                        ← this file
  docs/
    brainstorm/                    ← design notes per game candidate
      corporate-ladder/            ← current target game
    decisions/                     ← Architecture Decision Records
    standards/                     ← project standards
    course/                        ← instructor-facing course materials
  games/                           ← one subdirectory per game trial build
```

---

## Course module structure (game-agnostic)

| Module | Goal |
|--------|------|
| 0: Vibe-code baseline | Show the failure mode; establish why SDD matters |
| 1: Requirements | Define requirements with acceptance criteria |
| 2: Technical design | Core data model, rendering seam, update order |
| 3: First slice | Render world, draw player, basic movement |
| 4: Vertical movement | Climbing and gravity |
| 5: Collectibles and exit | Collection, score, win condition |
| 6: Enemy *(optional)* | Collision and loss condition |
| 7: Git milestone | `git log`, tag milestone, publish green build |
| 8: Extensibility | Extension backlog, YAGNI discussion |

---

## Instructor versions

Three builds of the game must exist by course day:

| Version    | Purpose                             |
|------------|-------------------------------------|
| Starter    | Given to learners (skeletons only)  |
| Checkpoint | Used if class falls behind schedule |
| Complete   | Used for final demonstration        |
