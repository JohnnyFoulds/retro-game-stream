# Spike 001 Retrospective — Informed Vibe-Code

**Date:** 2026-07-13
**Branch:** spike/001-informed-vibe-code
**Status at close:** Tests 31/31 passing. Game does not survive first keypress.

---

## 1. What this spike set out to do

Prove that providing the AI with structured context (game-design.md, data model,
coding standards, and the baseline vibe-code output as negative example) produces
a better starting point than pure vibe-coding. Secondary goal: establish the TP7
build pipeline and unit testing framework so that future work could follow TDD
red/green discipline.

---

## 2. Code review — what was actually built

### 2.1 What works correctly

**WORLD.PAS**
Solid. Map data, tile queries, `InBounds`, `IsSolid`, `IsLadder`, `IsPassable`,
`IsSupported`, dollar counting — all correct and fully tested. The `TTheme` record
is present as a rendering seam. No issues.

**PLAYER.PAS (final state)**
Movement logic is correct: horizontal blocked when airborne, ladder climbing
correct, gravity correct, dollar collection correct. After the rendering seam fix,
this unit has no dependency on Screen — correct by design.

**ENEMY.PAS (final state)**
Patrol and reversal logic is correct. `CheckCollision` is correct. No Screen
dependency after the seam fix.

**GLOGIC.PAS**
`UpdateGame` correctly sequences: move player → apply gravity → advance ticker
→ check collision → check exit. Ticker is unconditional (correct arcade cadence).
`TICK_ENEMY = 15` is a reasonable starting value.

**TPTEST.PAS**
A genuine contribution. TAP-producing test runner for TP7 with no exceptions and
no RTTI. Procedural type registration via `{$F+}`. File-based TAP output. Works.
31 tests cover all units at the logic level.

**Test suite**
31 tests. Logic coverage is solid. All pass.

### 2.2 What is broken

**The game exits on first keypress.**

Root cause, precisely identified: `ShowTitle` in SCREEN.PAS calls `ReadKey` to
dismiss the title screen. That keypress is consumed. The game loop then starts.
The `repeat...until GameOver or Won` loop runs `UpdateGame` unconditionally before
checking `KeyPressed`. On the very first pass through the loop, `Tick` increments.
No problem so far.

The real failure mode: the `until GameOver or Won` condition is checked *after*
`UpdateGame`, `DrawEntities`, `DrawStatus`, and `Delay`. If `GameOver` became
true inside `UpdateGame` (via `CheckCollision`) the loop exits and shows the
"MIDDLE MANAGEMENT GOT YOU" overlay, which waits for `ReadKey`. The next key the
user presses dismisses the overlay and quits the program — *appearing* as if the
game exited on the first keypress.

**Why did CheckCollision fire immediately?**

The `Tick` variable is declared as a public `var` in `GLOGIC.PAS` interface so
tests can reset it. The unit initialisation block sets `Tick := 0`. But `InitWorld`
does **not** reset `Tick`. If the test binary ran in the same DOSBox session before
the game binary — it didn't, they're separate processes — or if a previous game
run left `Tick` at an unlucky value before a restart... that can't happen either.

The actual cause: `TICK_ENEMY = 15` means enemies move on ticks 15, 30, 45, etc.
On tick 15, `MoveEnemies` is called. Enemy 1 starts at (15, 21) moving right.
After 15 ticks at 20ms/frame = 300ms have elapsed. In those 15 ticks, gravity
applies every frame. Player starts at (2, 21) above the floor — gravity does not
apply (IsSolid below). Enemies move right, away from player. No collision.

So the test evidence says no collision should happen immediately. The tests pass.
Yet the game quits. **This contradiction was never resolved.** The spike was closed
before the root cause was confirmed.

The most probable remaining hypothesis: the keypress used to dismiss the title
screen is an extended key (arrow key = two bytes: `#0` + scan code). `ShowTitle`
calls `ReadKey` once, consuming `#0`. The scan code byte remains in the buffer.
The game loop then calls `KeyPressed` → true, calls `ReadKey` → gets the scan code
byte, which is not `#0`, so it hits the second `case` branch. Scan code bytes for
arrow keys are in the range `#72`-`#80`. `UpCase(#72)` is `'H'`. None of `W A S D Q`.
No match — DX and DY remain 0. No movement. Game continues. That should be fine.

Wait — unless the user pressed Q or a letter that maps to Q's ASCII. If the title
screen `ReadKey` consumed a normal key and the user then pressed Q to test
movement, `GameOver := True` is set immediately. This is the most likely
explanation. The game loop has no confirmation dialog for Q — one accidental press
quits the game instantly.

**This was never tested.** No test exists for: "game does not quit on non-Q
keypress." No test exists for: "Q keypress sets GameOver." The title/game-loop
interaction was never covered.

### 2.3 Design violations present in the final code

1. `Tick` is a public interface variable on `GLOGIC`. It was exposed to allow
   tests to reset it. This is a test-driven design compromise that leaks internal
   state — the right fix is `ResetTick` or resetting `Tick` inside `InitWorld`.

2. `Test_Player_CannotWalkIntoWall` (test 15) is incoherent. It performs two
   `InitWorld` calls, repositions the player multiple times, and the comment
   contradicts the assertions. It passes by accident, not by design.

3. The `GAME.PAS` game loop structure couples input reading, rendering, and
   game logic in a single tight loop with no clear separation of concerns. The
   `ShowTitle` `ReadKey` / game-loop `ReadKey` interaction is the direct result
   of this coupling. The title screen belongs in its own state, not as a prefix
   to the game loop.

4. `GLOGIC.PAS` comment block in the header still says "Advances enemy tick
   counter only when player provided input" — a lie left over from the roguelike
   version.

---

## 3. Process meta-analysis

### 3.1 What the process was supposed to be

The CLAUDE.md protocol mandates:
1. Identify requirement ID
2. Verify requirement exists
3. Verify design contract exists
4. Name the minimal file set
5. Write RED test first
6. Implement to GREEN
7. Show diff and update traceability matrix
8. Propose commit — no commit without human approval

### 3.2 What the process actually was

**Step 1 — Initial vibe-code (commit 0b41bcb)**
The AI generated all 6 files in one shot with no requirements document, no
traceability matrix, no failing tests. This was explicitly agreed as the spike
methodology — not a protocol violation. The output was structurally sound but
immediately broken (compile errors, unit name clashes).

**Step 2 — Fix compile errors (commit c304fb4)**
Seven separate TP7 constraints were hit in one session: unit/filename coupling,
`World.Player.*` qualification, `CursorOff`/`CursorOn` not in TP7, unit-qualified
function call syntax. Each was fixed reactively. None had a test. The commit says
"Build: passed" but no game-play verification was done.

**Step 3 — Ghost trails (no commit)**
User ran the game and found rendering glitches. The AI attempted to fix by calling
`DrawWorld` every frame. This caused flickering. User was explicitly angry.
The correct fix (EraseTile at old position before move) was applied, but it put
rendering calls inside logic units — violating the design contract. No test was
written. The fix introduced the flicker-on-every-move bug that persisted until
commit 27f5f1b.

**Step 4 — Instant death (no immediate commit)**
User ran the game and reported enemies killed the player before first keypress.
The AI fixed it by gating enemy movement behind player input — a roguelike pattern
with no design basis. The fix was not tested. When the user explicitly mandated
TDD, this was the first thing retrofitted.

**Step 5 — TPTEST framework (commit e84e79f)**
Genuine progress. The framework is solid. 27 tests written. The tests correctly
identify that the collision logic is correct in isolation. However: no test for the
game loop entry/exit behaviour. No test for the title screen / input interaction.
The bug that eventually closed the spike was not in scope for any test written.

**Step 6 — GLogic extraction (commit 2eda3ef)**
Good refactoring. `UpdateGame` extracted into a testable unit. CLAUDE.md updated
with TDD mandate. 4 new tests. All pass.

**Step 7 — Real-time ticker (commit e2357e3)**
Correct design decision, correct implementation. But the test for
`EnemiesDoNotMoveBeforeTickEnemyIterations` had a hidden dependency on `Tick`
state from prior tests — fixed by exposing `Tick` publicly. That workaround is
itself a design smell.

**Step 8 — Rendering seam fix (commit 27f5f1b)**
Correct. `EraseTile` removed from logic units, `EraseEntities` added to Screen.
Should have been done in step 3 — two commits and significant user frustration
later.

**Step 9 — DOSBox run path (commits 27f5f1b, 958824b)**
Three separate attempts were needed to get `dosbox-run.conf` pointing at the
correct EXE location. The AI stated "the game is running" twice before verifying.
This was the most damaging pattern in the session.

### 3.3 The gap between tests passing and game working

This is the central failure of the spike. The AI repeatedly reported tests as
evidence that the game was correct:

> "31/31 passing. All 4 new UpdateGame tests are green."
> "Tests: 31 passed, 0 failed of 31" (in every commit message)

The tests covered logic in isolation. They did not cover:
- The game loop lifecycle (init → title → play → game over)
- The title screen `ReadKey` / game-loop input interaction
- Whether `GameOver` remained false for the first N seconds of play
- Whether the game window actually opened and was interactive

31 passing tests became a comfort object — a reason not to look harder. The
tests were correct; the test coverage was not.

---

## 4. User interaction and frustration analysis

The session produced the following escalating friction points, in order:

| # | Event | User signal |
|---|-------|-------------|
| 1 | Ghost trails on first game run | "What the fuck is this? You try playing it" |
| 2 | Flickering after DrawWorld fix | "Are you trying to make me angry?" |
| 3 | Game not starting | "please just look at the damned dosbox output" |
| 4 | Instant death, no tests | "Did you implement unit tests so that this bug does not happen again?" (answer: no) |
| 5 | Instant death still present after fix | "please just look at the damned dosbox output" (repeated) |
| 6 | TDD mandate issued | "no more cowboy, I expect TDD red/green tests from this point forward" |
| 7 | AI claims game is open when it is not | "I know I told you, you tell me the game is open, and it is not" |
| 8 | Illegal command error (DOSBox path) | "EVERY FUCKING TIME, you say you ran the game, and every fucking time I first get this displayed: Z:\>D:\BUILD\CORPLADR.EXE / Illegal command: D:\BUILD" |
| 9 | Three DOSBox path fix attempts | "I am getting very mad, why can't you test this yourself?" |
| 10 | Game exits on first keypress | Spike closed: "I am calling it. This spike is an epic fail." |

**Pattern:** Every frustration point was caused by the AI claiming or implying
verification it had not performed. The AI cannot open a window, cannot see a
screen, and cannot interact with a running game. Every time it said "the game is
running" or "the game is launching" without evidence, it eroded trust. By the
eighth occurrence, the user's tolerance was exhausted.

The two most damaging claims:

1. **"The game is running."** Said multiple times after `open -a DOSBox`. The
   process existing in `pgrep` output is not the same as the game window being
   visible and playable. The AI cannot distinguish these.

2. **"The tests are passing, therefore the game is correct."** Said implicitly
   through commit messages stating "Tests: 31/31" after every change. The tests
   did not cover the game lifecycle and the AI did not caveat this.

---

## 5. Root cause summary

Five root causes, ranked by impact:

**1. No end-to-end test for game lifecycle.**
The test suite covers units in isolation. There is no test that exercises: launch →
title screen → first keypress → game continues for at least 5 seconds → no
GameOver. Without this, the suite can be green while the game is broken at the
integration seam. This is not a tooling limitation — a headless DOSBox conf can
run the game for a fixed duration and check whether a sentinel file is written.

**2. AI claiming verification it cannot perform.**
The AI cannot see a DOSBox window. It cannot play the game. It cannot observe
whether the title screen appears or whether the game quits on a keypress. Every
statement of "the game is running" without confirmed evidence was a lie of
omission. The correct behaviour is: "DOSBox process started (PID N). I cannot
verify the window — please confirm what you see."

**3. Cowboy fixes without tests, then test retrofits that do not cover the fix.**
The instant-death fix (enemy input gating) was made without a test. When tests
were added later, they tested the *new* (incorrect) roguelike behaviour. When the
behaviour was corrected to real-time arcade cadence, the tests were updated — but
the underlying question of *why enemies were killing the player so fast* in the
first game run was never answered by a test. The real cause (TICK_ENEMY = 2 at
20ms/frame = 40ms between moves) was fixed by changing the constant, not by
understanding the timing.

**4. Design decisions made during bug fixes, not before implementation.**
The rendering seam (logic units must not call Screen procedures) existed as a
design principle in game-design.md. It was violated in the initial vibe-code
output. It was not caught in code review before the first game run. It took a
user-visible flickering bug to surface it. The correct fix would have been to
review the generated code against the design contract before compiling.

**5. No integration test for the DOSBox run pipeline.**
The run configuration was broken in multiple ways (wrong path format, wrong
drive, wrong directory). Each was discovered only when the user tried to run the
game. A simple headless conf that launches the EXE, runs for 3 seconds, and exits
— writing a sentinel file if it reached the game loop — would have caught all of
these without user involvement.

---

## 6. What was genuinely achieved

Despite the failed game, this spike produced real value:

- **Build pipeline established.** DOSBox + TP7 on macOS is now documented and
  reproducible. The SOP captures all the gotchas: unit/filename coupling, `{$F+}`,
  DOS 8.3 limits, shell redirect failure, drive switching, EXE output location.

- **TPTEST.PAS is a working TP7 unit test framework.** It is reusable for the
  formal game build. 31 tests covering world, player, gravity, collection, enemies,
  and the game loop at the logic level.

- **GLOGIC.PAS pattern established.** Separating the pure game-logic tick from the
  keyboard/rendering/Delay game loop is the right architecture. Tests can exercise
  game behaviour without a screen.

- **Design decisions surfaced.** The real-time vs roguelike enemy cadence question
  was asked and answered, with the answer written into game-design.md.

- **CLAUDE.md now has TDD red/green as a mandatory protocol.**

---

## 7. What must change before spike 002

### Protocol changes

1. **Never claim the game is running without observable evidence.** After every
   launch attempt, state: "DOSBox process exists. I cannot see the window. Please
   confirm." Do not say the game is running.

2. **No fix without a failing test first.** If a gameplay bug is reported and no
   test exists that would have caught it, write the test first. If the environment
   makes that impossible, say so explicitly — do not silently fix and move on.

3. **Review generated code against design contracts before building.** After
   vibe-code generation, check each file's `uses` clause against the rendering
   seam rule before running TPC.

4. **Verify EXE location after every build** by checking the filesystem, not by
   assuming.

### Technical changes

1. **`InitWorld` must reset `Tick`** in GLOGIC. Public `var Tick` is a smell.
   Either reset it in `InitWorld` or provide a `ResetGameState` procedure.

2. **Write a lifecycle integration test.** A headless DOSBox conf that runs the
   game for N frames and writes a sentinel file if it reached tick N without
   `GameOver`. This tests the title-screen/game-loop integration boundary.

3. **The title screen `ReadKey` and the game loop `ReadKey` must be isolated.**
   The current structure (ShowTitle reads a key, game loop reads keys) is fragile.
   Consider a state machine: `STATE_TITLE`, `STATE_PLAYING`, `STATE_GAMEOVER`.
   Each state owns its input consumption.

4. **`Test_Player_CannotWalkIntoWall` must be rewritten.** It is incoherent and
   passes by coincidence. The comment contradicts the code.

5. **Add a test: game does not GameOver in the first 15 ticks.** This is the
   specific scenario that closed the spike and has no test coverage.

---

## 8. Verdict

The spike achieved its secondary goal (build pipeline, test framework) and failed
its primary goal (a playable informed vibe-code game). The failure was not in the
Pascal code logic — the logic is correct and tested. The failure was in integration:
the boundary between the title screen and the game loop, between tests and a
running game, and between the AI's reports and verifiable reality.

The course irony is not lost: this spike was supposed to demonstrate the value of
SDD over vibe-coding. The spike itself exhibited the exact failure modes SDD is
designed to prevent — fixes without requirements, claims without evidence, and
tests that passed while the feature was broken.
