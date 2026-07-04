# The Corporate Ladder: Avoid Middle Management

> Climb the corporate ladder, collect dollar signs, avoid middle management, and reach the exit.

This document captures the game-specific design for the current target game. The course structure is intentionally separate — see [ADR-0002](../../decisions/0002-game-course-separation.md).

---

## Premise

A single-screen ASCII DOS platform game. The player is an employee climbing the corporate ladder, collecting money, avoiding middle management, and escaping to the exit.

---

## Core symbols

| Symbol | Tile/Entity | Meaning                   |
|--------|-------------|---------------------------|
| `@`    | Entity      | Player / employee         |
| `=`    | Tile        | Platform                  |
| `H`    | Tile        | Ladder                    |
| `$`    | Entity      | Collectible money         |
| `M`    | Entity      | Middle management (enemy) |
| `E`    | Tile        | Exit                      |
| `#`    | Tile        | Wall / boundary           |
| `.`    | Tile        | Empty space               |

---

## Win / lose conditions

- **Win:** all `$` collected AND player reaches `E`
- **Lose:** player touches `M`

---

## Example level

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

---

## Requirements

| ID    | Requirement                                                                              | Optional |
|-------|------------------------------------------------------------------------------------------|----------|
| R-001 | The game shall render a fixed ASCII level in DOS text mode.                              |          |
| R-002 | The player shall be represented by `@`.                                                  |          |
| R-003 | The player shall move left and right by one cell when the target cell is passable.       |          |
| R-004 | The player shall climb ladders represented by `H`.                                       |          |
| R-005 | Platforms represented by `=` shall support the player.                                   |          |
| R-006 | The player shall fall one cell per update when unsupported.                              |          |
| R-007 | Dollar signs represented by `$` shall be collected when the player enters their cell.    |          |
| R-008 | The score shall increase when a dollar sign is collected.                                |          |
| R-009 | The exit `E` shall complete the level only after all dollar signs have been collected.   |          |
| R-010 | Middle management `M` shall cause the player to lose when touched.                       | Yes      |

---

## Core data model (Turbo Pascal 7)

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

The `TTheme` record is the key extensibility seam: visual representation changes do not ripple into game rules.

---

## Update order

Must be respected in all implementations:

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

Specifying this before implementation is deliberate — even simple games have rule-order semantics. If update order is unspecified, an AI agent may produce inconsistent behaviour.

---

## Movement rules

**Horizontal:** cell-based, one cell per update, target cell must be passable.

**Vertical (ladder):** up/down only when on or adjacent to a ladder tile.

**Gravity:** player falls one cell per update when unsupported and not on a ladder.

**Jumping:** excluded from the one-day version. Ladders provide all vertical movement. Jumping is a post-course enhancement.

---

## File structure (trial build)

```
games/corporate-ladder/
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
    CORPLADR.PAS      ← main program entry point
    WORLD.PAS         ← map/tile data and world queries
    PLAYER.PAS        ← player state, movement, climbing
    SCREEN.PAS        ← rendering only (uses TTheme)
    GAME.PAS          ← game loop, gravity, collection, exit check
    ENEMY.PAS         ← enemy state and patrol logic
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

| File         | Owns                                      | Must not touch                        |
|--------------|-------------------------------------------|---------------------------------------|
| `WORLD.PAS`  | Map data, tile queries, collectible removal | Rendering, player state, input      |
| `PLAYER.PAS` | Player position, movement, climbing       | Rendering, world data, enemy logic    |
| `SCREEN.PAS` | All rendering, `TTheme`                   | Game rules, movement, state           |
| `GAME.PAS`   | Game loop, gravity, exit check            | Rendering details, Pascal I/O         |
| `ENEMY.PAS`  | Enemy position, patrol direction          | Rendering, player state               |

---

## Extensibility seams

Do not add abstractions for these now. Just don't seal the doors.

| Future change        | Seam to preserve                        |
|----------------------|-----------------------------------------|
| Better ASCII symbols | `TTheme` record in `SCREEN.PAS`         |
| Colours              | `SCREEN.PAS` only                       |
| Multiple levels      | Map arrays or level files in `WORLD.PAS`|
| New enemies          | `ENEMY.PAS`                             |
| Sprites / graphics   | Replace renderer, keep game state intact|
| Sound                | Add `SOUND.PAS`                         |
| High score           | Add file I/O later                      |

---

## Deliberately excluded from the one-day version

Deferred, not rejected:

- Jumping physics
- Multiple levels
- CGA graphics / sprites
- Sound
- Save-game framework
- Plugin system or entity-component framework

---

## Post-course enhancement ladder

### Phase A — Better ASCII
Replace symbols with box-drawing characters, add colour attributes, title/win/lose screens.

### Phase B — More gameplay
Multiple levels, timer, lives, score bonus, varied enemy behaviours, fall penalty.

### Phase C — Better engineering
Load levels from text files, separate theme configuration, high-score file, recorded input replay.

### Phase D — Graphics path
CGA graphics mode, tile sprites, simple animation, PC speaker sound.

---

## Source

Initial design developed via AI-assisted research session. See [docs/brainstorm/initial_idea.md](../initial_idea.md) for the full session transcript.
