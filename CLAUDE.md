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
2. **Trial build** — a working run-through of building *The Corporate Ladder* game, which serves as the instructor's reference implementation (starter, checkpoint, and complete solution).

The pilot targets Vodacom technical employees to iron out delivery problems first. The long-term goal is a course open to everyone — including non-technical staff and executives. The game is built in **Turbo Pascal 7** targeting **DOS text mode**, played in-browser via a DOS emulator. See [ADR-0001](docs/decisions/0001-turbo-pascal-language-choice.md) for why Pascal was chosen.

---

## The five skill clusters this course teaches

Every piece of course material should reinforce one or more of these. Keep them in mind when writing documentation, designing exercises, or structuring modules.

### 1. Specification-Driven Development (SDD)
Decompose a vague idea into small, observable requirements with explicit acceptance criteria *before* touching the AI. The requirement is the unit of work. The full loop:

```
Idea → Requirement → Acceptance Criterion → Design Decision → Code → Test → Commit → Playable
```

### 2. AI usage and prompting discipline
Treat the AI as a *controlled implementation assistant*, not an autonomous developer. A well-formed prompt names the requirement ID, names the files to modify, names what not to do, and demands a diff before a commit. Vague prompts produce unreviewed messes.

Good prompt pattern:
```
Implement R-007.

The player should collect dollar signs when entering their cell.
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
- Static world (`TTile` enum) vs dynamic entities (`TPlayer`, `TEnemy` records)
- Rendering seam (`TTheme` record): visual representation changes do not ripple into game rules
- Specify update order *before* implementation (input → move → gravity → collect → enemy → collision → exit → render)
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
2. Verify the requirement exists in `docs/requirements.md`.
3. Verify the relevant design contract exists in `docs/technical-design.md`.
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
- Modernise the target platform (Turbo Pascal 7 / DOS text mode)
- Replace Pascal with another language
- Introduce a game engine or framework
- Commit without review
- Publish a broken build

---

## Game specification

### Core symbols

| Symbol | Tile/Entity | Meaning |
|--------|-------------|---------|
| `@` | Entity | Player / employee |
| `=` | Tile | Platform |
| `H` | Tile | Ladder |
| `$` | Entity | Collectible money |
| `M` | Entity | Middle management (enemy) |
| `E` | Tile | Exit |
| `#` | Tile | Wall / boundary |
| `.` | Tile | Empty space |

### Win / lose conditions

- **Win:** all `$` collected AND player reaches `E`
- **Lose:** player touches `M`

### Requirements

| ID | Requirement | Status |
|----|-------------|--------|
| R-001 | The game shall render a fixed ASCII level in DOS text mode. | |
| R-002 | The player shall be represented by `@`. | |
| R-003 | The player shall move left and right by one cell when the target cell is passable. | |
| R-004 | The player shall climb ladders represented by `H`. | |
| R-005 | Platforms represented by `=` shall support the player. | |
| R-006 | The player shall fall one cell per update when unsupported. | |
| R-007 | Dollar signs represented by `$` shall be collected when the player enters their cell. | |
| R-008 | The score shall increase when a dollar sign is collected. | |
| R-009 | The exit represented by `E` shall complete the level only after all dollar signs have been collected. | |
| R-010 | Middle management represented by `M` shall cause the player to lose when touched. *(optional)* | |

### Core data model (Turbo Pascal 7)

```pascal
type
  TTile = (ttEmpty, ttWall, ttPlatform, ttLadder, ttExit);

  TPlayer = record
    X, Y:  Integer;
    Score: Integer;
    Lives: Integer;
  end;

  TEnemy = record
    X, Y: Integer;
    DX:   Integer;
  end;

  TTheme = record
    EmptyChar:    Char;
    WallChar:     Char;
    PlatformChar: Char;
    LadderChar:   Char;
    ExitChar:     Char;
    PlayerChar:   Char;
    EnemyChar:    Char;
    MoneyChar:    Char;
  end;
```

### Update order (must be respected in all implementations)

```
1. Read input
2. Apply player movement
3. Apply gravity
4. Collect dollar signs
5. Update enemy
6. Check player/enemy collision
7. Check exit condition
8. Render screen
```

---

## Repository structure

```
retro-game-stream/
  README.md
  CLAUDE.md                     ← this file
  docs/
    brainstorm/                 ← raw design notes and source material
    course/                     ← instructor-facing course materials (to be created)
  corporate-ladder/             ← the game project (trial build)
    README.md
    CHANGELOG.md
    docs/
      product-vision.md
      requirements.md
      technical-design.md
      traceability-matrix.md
      ai-collaboration-log.md
      project-state.md
      extension-backlog.md
    src/
      CORPLADR.PAS              ← main program entry point
      WORLD.PAS                 ← map/tile data and world queries
      PLAYER.PAS                ← player state, movement, climbing
      SCREEN.PAS                ← rendering only (uses TTheme)
      GAME.PAS                  ← game loop, gravity, collection, exit check
      ENEMY.PAS                 ← enemy state and patrol logic
    tests/
      manual-acceptance-tests.md
      TESTWORLD.PAS
      TESTMOVE.PAS
      TESTCOLL.PAS
    build/
      build-log.txt
      test-log.txt
      manifest.json
    public/
      index.html
      play.html
      build.html
      traceability.html
```

---

## File responsibility boundaries

Respect these boundaries. An AI agent must not reach across them without explicit instruction.

| File | Owns | Must not touch |
|------|------|----------------|
| `WORLD.PAS` | Map data, tile queries, collectible removal | Rendering, player state, input |
| `PLAYER.PAS` | Player position, movement, climbing | Rendering, world data, enemy logic |
| `SCREEN.PAS` | All rendering, `TTheme` | Game rules, movement, state |
| `GAME.PAS` | Game loop, gravity, exit check | Rendering details, Pascal I/O primitives |
| `ENEMY.PAS` | Enemy position, patrol direction | Rendering, player state |

---

## Extensibility seams (do not close these)

| Future change | Seam to preserve |
|---------------|-----------------|
| Better ASCII symbols | `TTheme` record in `SCREEN.PAS` |
| Colours | `SCREEN.PAS` only |
| Multiple levels | Map arrays or level files in `WORLD.PAS` |
| New enemies | `ENEMY.PAS` |
| Sprites / graphics | Replace renderer, keep game state intact |
| Sound | Add `SOUND.PAS` |
| High score | Add file I/O later |

Do not add abstractions for these now. Just don't seal the doors.

---

## What is deliberately excluded from the one-day version

These are deferred, not rejected:

- Jumping physics
- Multiple levels
- CGA graphics / sprites
- Sound
- QEMU validation
- Gateway Git remote
- Merge requests / pull requests
- Complex collaboration workflows
- Save-game framework
- Plugin system or entity-component framework

---

## Course module summary

| Module | Time | Goal |
|--------|------|------|
| 0: Vibe-code baseline | 09:00–10:30 | Show the failure mode; establish why SDD matters |
| 1: Requirements | 09:30–10:15 | Define R-001 to R-009 with acceptance criteria |
| 2: Technical design | 10:15–11:00 | Tiles vs entities, rendering seam, update order |
| 3: First slice | 11:00–12:15 | Render level, draw player, basic movement |
| 4: Ladders and gravity | 13:00–14:00 | R-004, R-005, R-006 |
| 5: Collectibles and exit | 14:00–15:00 | R-007, R-008, R-009 |
| 6: Middle management | 15:00–15:45 | R-010 (optional) |
| 7: Git milestone | 15:45–16:30 | `git log`, tag M1, publish green build |
| 8: Extensibility | 16:30–17:00 | Extension backlog, YAGNI discussion |

---

## Instructor versions

Three builds of the game must exist by course day:

| Version | Purpose |
|---------|---------|
| Starter | Given to learners (skeletons only) |
| Checkpoint | Used if class falls behind schedule |
| Complete | Used for final demonstration |
