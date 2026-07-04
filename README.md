# Specification-Driven AI Development
## Building *The Corporate Ladder: Avoid Middle Management*

> **Specify. Build. Test. Commit. Play.**

A one-day, instructor-led corporate training course for Vodacom technical employees. Learners use an AI coding agent to build a small DOS-style ASCII platform game in **Turbo Pascal 7**. The game is the laboratory — the real subject is disciplined AI-assisted software engineering.

---

## The game

*The Corporate Ladder* is a single-screen ASCII DOS platform game.

> Climb the corporate ladder, collect dollar signs, avoid middle management, and reach the exit.

```
########################################
#.............$.......................E#
#.....======.............======........#
#.........H..................H.........#
#.........H..........$.......H.........#
#..@..=====.....========.....=====.....#
#.........H..................H.........#
#.........H.......M..........H.........#
#.....======.............======........#
#..................$...................#
########################################
```

| Symbol | Meaning |
|--------|---------|
| `@` | Player / employee |
| `=` | Platform |
| `H` | Ladder |
| `$` | Collectible money |
| `M` | Middle management (enemy) |
| `E` | Exit |
| `#` | Wall / boundary |
| `.` | Empty space |

**Win:** collect all `$` then reach `E`. **Lose:** touch `M`.

---

## What this course teaches

The game is not the point. The game is the vehicle for five skill clusters:

### 1. Specification-Driven Development (SDD)
Turn a vague idea into small, observable requirements with explicit acceptance criteria before writing a line of code. The requirement is the unit of work. The full loop:

```
Idea → Requirement → Acceptance Criterion → Design → Code → Test → Commit → Playable
```

### 2. AI usage and prompting discipline
Use the AI as a *controlled implementation assistant*, not an autonomous developer. Constrain every prompt: name the requirement ID, name the files to modify, name what not to do. Demand a diff before a commit. The course opens with a vibe-code baseline to demonstrate — not lecture about — what uncontrolled AI coding looks like.

### 3. Git as the engineering record
Commits are engineering claims, not saves:

```
R-007 implement dollar collection

- Remove dollar sign when player enters its cell
- Increment score
- Add acceptance test T-007
- Update traceability matrix

Build: passed
Tests: passed
```

The evidence chain runs: playable game → build manifest → commit → diff → requirement.

### 4. Software design thinking
Static world vs dynamic entities. Rendering seams that allow visual changes without touching game rules. Specifying update order *before* implementation. YAGNI vs small intentional seams — not every future concern needs engineering now, but the right doors must stay open.

### 5. AI-assisted research and documentation
Using AI productively in the discovery and design phase (requirements, technical design, extension backlog) — distinct from using it in the implementation phase. The learner stays the author throughout both phases.

---

## The central claim

```
Specification ≻ AI output
```

Fast generation is not the same as fast, reliable delivery:

```
T_delivery = T_specification + T_generation + T_debugging + T_integration + T_maintenance
```

Vibe coding minimises `T_generation` but inflates the downstream terms. SDD invests a small amount upfront to reduce a much larger cost later.

---

## Course structure (one day, ~7 hours)

| Time | Module | Deliverable |
|------|--------|-------------|
| 09:00 | **Module 0:** Vibe-code baseline — try the obvious thing first, inspect the result | Baseline snapshot, inspection checklist |
| 09:30 | **Module 1:** Requirements — define R-001 to R-009 | `docs/requirements.md`, `docs/traceability-matrix.md` |
| 10:15 | **Module 2:** Technical design — tiles vs entities, rendering seam, update order | `docs/technical-design.md`, source skeletons |
| 11:00 | **Module 3:** First slice — render level, draw player, basic movement | Compiling, browser-playable build |
| 13:00 | **Module 4:** Ladders and gravity | Green build, commit `R-004/R-006` |
| 14:00 | **Module 5:** Collectibles and exit | Green build, commit `R-007/R-009` |
| 15:00 | **Module 6:** Middle management enemy *(optional, pace-dependent)* | Commit `R-010` |
| 15:45 | **Module 7:** Git milestone and browser-playable build | `build/manifest.json`, tag `M1` |
| 16:30 | **Module 8:** Extensibility and post-course roadmap | `docs/extension-backlog.md` |

---

## Requirements (one-day game)

| ID | Requirement |
|----|-------------|
| R-001 | The game shall render a fixed ASCII level in DOS text mode. |
| R-002 | The player shall be represented by `@`. |
| R-003 | The player shall move left and right by one cell when the target cell is passable. |
| R-004 | The player shall climb ladders represented by `H`. |
| R-005 | Platforms represented by `=` shall support the player. |
| R-006 | The player shall fall one cell per update when unsupported. |
| R-007 | Dollar signs represented by `$` shall be collected when the player enters their cell. |
| R-008 | The score shall increase when a dollar sign is collected. |
| R-009 | The exit represented by `E` shall complete the level only after all dollar signs have been collected. |
| R-010 | Middle management represented by `M` shall cause the player to lose when touched. *(optional)* |

---

## Repository structure

This repo contains the **course design** and a **trial run** of building the game — serving as the instructor's reference, checkpoint, and complete solution.

```
retro-game-stream/
  docs/
    brainstorm/         — raw design notes and initial idea
    course/             — instructor-facing course materials
  corporate-ladder/     — the game project (trial build)
    docs/               — product-vision, requirements, technical-design, traceability-matrix
    src/                — CORPLADR.PAS, WORLD.PAS, PLAYER.PAS, SCREEN.PAS, GAME.PAS, ENEMY.PAS
    tests/              — manual-acceptance-tests.md, TESTWORLD.PAS, TESTMOVE.PAS, TESTCOLL.PAS
    build/              — build-log.txt, test-log.txt, manifest.json
    public/             — index.html, play.html, build.html, traceability.html
```

---

## Target audience

| Audience | Fit |
|----------|-----|
| Software engineers | Excellent — pilot target |
| Data scientists / AI engineers | Excellent — pilot target |
| Automation engineers | Good — pilot target |
| Solution architects | Good — pilot target |
| Technical product owners | Good — pilot target |
| Non-technical business users / Executives | Target after pilot is stable |

No prior Turbo Pascal experience required. Pascal was designed by Niklaus Wirth as a teaching language — its syntax is explicit enough that even non-technical participants can read a diff and verify whether the AI did what the specification asked. This is deliberate: the long-term vision is that **anyone** — including executives — can use the SDD loop to build small personal tools and automation, and in doing so gain genuine insight into what software engineers navigate every day.

The pilot focuses on technical employees to iron out delivery problems first. Once stable, the course is open to everyone.
