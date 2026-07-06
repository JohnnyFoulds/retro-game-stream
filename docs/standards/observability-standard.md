# Observability Standard — Turbo Pascal 7

## Purpose

This document defines how the game's runtime behaviour is made observable during development. It covers diagnostic output at operation boundaries, game-loop timing, state inspection, and the principles that determine *what* to instrument and *where*. For message format and log levels, see [logging-standard.md](logging-standard.md).

Turbo Pascal 7 runs in a single DOS process with no network, no distributed tracing, and no telemetry backend. The observability equivalent is: structured `WriteLn` output to a log file, compile-time state dumps, and a clear discipline about what gets measured and where.

---

## If you are coming from a language with observability tooling

Modern services use OpenTelemetry spans to record operation boundaries:

```python
# Python — OTel span wraps an operation
with tracer.start_as_current_span("load_session") as span:
    span.set_attribute("session.id", session_id)
    session = session_manager.resume(session_id)
    span.set_attribute("session.message_count", session.message_count)
```

The span answers: what operation ran, how long it took, what its inputs and outputs were, and whether it failed.

In TP7 there are no spans. The equivalent is a **before/after log pair** at the entry and exit of each significant operation, with the same information encoded as log message fields:

```pascal
{ TP7 equivalent of the OTel span above }
LogInfo('GAME.LoadLevel: loading level=' + IntToStr(levelNum));
if not LoadWorld(levelFile, world, msg) then
begin
  LogError('GAME.LoadLevel: load failed level=' + IntToStr(levelNum) +
           ' reason=' + msg);
  Exit;
end;
LogInfo('GAME.LoadLevel: load complete level=' + IntToStr(levelNum) +
        ' tiles=' + IntToStr(tileCount));
```

The same discipline applies: instrument at operation boundaries, make each log line self-describing, never put sensitive or high-frequency data in always-on output.

---

## 1. What is an operation boundary?

An operation boundary is a point where the program transitions from one logical phase to another. These are the right places to instrument.

| Boundary type | Examples | Level |
| --- | --- | --- |
| Program lifecycle | Start, shutdown, level load, level complete | `INFO` |
| Game-loop phase transitions | Update complete, render complete | `DEBUG` (gated) |
| Entity state transitions | Player spawned, player died, enemy direction changed | `INFO` or `DEBUG` |
| I/O operations | File opened, file closed, read complete | `INFO` on start; `ERROR` on failure |
| Error recovery | Fallback path taken, value clamped | `WARNING` |

### What is NOT an operation boundary

Do not instrument every statement. These are not operation boundaries:

- A variable assignment inside a procedure
- A single arithmetic calculation
- A loop iteration counter update
- A branch that is one of many equally-weighted branches

Instrumenting too finely produces output that is too noisy to read and hides the actual transitions you care about. This is the TP7 equivalent of OTel's Rule 7: *span granularity follows the diagnostic need, not the statement count*.

---

## 2. Every log line must be self-describing

A log line that requires reading the source code to interpret is not useful. Each line must carry enough context to answer: *what happened, to what, with what result?*

Minimum context by operation type:

| Operation type | Required fields |
| --- | --- |
| Program lifecycle | Program name, build configuration, relevant parameters |
| Level / world load | Level number or file name, tile count or world dimensions |
| Player state change | Old state, new state, position at transition |
| Enemy state change | Enemy index, old state, new state, position |
| I/O operation | File name, operation (read/write), byte count or record count |
| Error condition | Unit, procedure, resource, reason (see [error-handling.md](error-handling.md)) |

```pascal
{ Bad — reader must know the codebase to interpret }
LogInfo('GAME: loaded');
LogInfo('ENEMY: changed');

{ Good — self-describing }
LogInfo('GAME.LoadLevel: world loaded level=1 width=40 height=20 enemies=3');
LogInfo('ENEMY.UpdateEnemy: enemy[1] dir changed old=left new=right pos=(12,8)');
```

---

## 3. Game-loop timing

The Python telemetry standard uses histograms to measure operation latency. In TP7, the equivalent is measuring tick duration with the DOS `GetTime` function and logging it at `DEBUG` level when it exceeds a threshold.

```pascal
{ In GAME.PAS game loop — gated under LOG_DEBUG }
procedure RunGameLoop;
var
  tickStart, tickEnd : LongInt;
  tickMs             : LongInt;
begin
  repeat
    tickStart := GetTickMs;

    ProcessInput;
    UpdateWorld(world);
    UpdatePlayer(player, world);
    UpdateEnemies(enemies, world);
    DrawFrame(world, player, enemies, score);

    tickEnd := GetTickMs;
    tickMs  := tickEnd - tickStart;

    {$IFDEF LOG_DEBUG}
    if tickMs > TARGET_TICK_MS then
      LogDebug('GAME.RunGameLoop: slow tick ms=' + IntToStr(tickMs) +
               ' target=' + IntToStr(TARGET_TICK_MS));
    {$ENDIF}

    WaitForNextTick(tickStart);
  until gameOver;
end;
```

Only log slow ticks — logging every tick at `DEBUG` produces hundreds of lines per second. This mirrors OTel Rule 7's histogram approach: record the distribution of interest, not every sample.

A helper to get milliseconds from DOS `GetTime`:

```pascal
function GetTickMs: LongInt;
var
  h, m, s, cs : Word;
begin
  GetTime(h, m, s, cs);
  GetTickMs := (LongInt(h) * 3600000) +
               (LongInt(m) * 60000) +
               (LongInt(s) * 1000) +
               (LongInt(cs) * 10);
end;
```

---

## 4. State dumps

When diagnosing a hard-to-reproduce bug, a full state dump at the moment of failure is more useful than reconstructing state from individual log lines. Write a `DumpState` procedure in each unit that has complex state, callable from the error site.

```pascal
{ Writes a complete snapshot of W to the log at DEBUG level.
  Call when an invariant violation is detected. }
procedure DumpWorldState(const W: TWorld);
var
  y, x : Integer;
  row  : String;
begin
  LogDebug('WORLD.DumpWorldState: --- world state dump ---');
  LogDebug('WORLD.DumpWorldState: width=' + IntToStr(W.Width) +
           ' height=' + IntToStr(W.Height));
  for y := 0 to W.Height - 1 do
  begin
    row := '';
    for x := 0 to W.Width - 1 do
      row := row + TileChar(W.Tiles[y][x]);
    LogDebug('WORLD.DumpWorldState: row[' + IntToStr(y) + ']=' + row);
  end;
  LogDebug('WORLD.DumpWorldState: --- end dump ---');
end;
```

Rules:

- State dumps are always gated under `{$IFDEF LOG_DEBUG}` or triggered only from `Halt` paths
- Call `DumpState` immediately before `Halt(99)` in impossible-state handlers so the log contains the world state at the moment of failure
- Do not leave unconditional state dump calls in production code

```pascal
{ Call dump before Halt so the log captures the bad state }
LogError('WORLD.DrawTile: unknown tile value ' + IntToStr(Ord(tile)) +
         ' at (' + IntToStr(x) + ',' + IntToStr(y) + ')');
DumpWorldState(W);
Halt(99);
```

---

## 5. Instrumentation design rules

These rules mirror the OTel instrumentation design rules from the Python standard, adapted for TP7.

### Rule 1: Instrument at operation boundaries, not at statements

A log entry should correspond to a complete logical operation — a level load, an enemy state transition, a file read. Do not log individual variable assignments or arithmetic steps.

### Rule 2: Every log line must be self-describing

A log line that requires reading surrounding lines to interpret is not useful. Include all relevant identifiers in every line (do not rely on a preceding line having printed the session context).

### Rule 3: ERROR always active; DEBUG always gated

`LogError` and `LogWarning` are always compiled in. `LogInfo` and `LogDebug` must be gated by `{$IFDEF}` so they produce zero overhead in release builds.

### Rule 4: No diagnostic output to the gameplay screen

The game screen is the player's view. Any `WriteLn` outside `RENDER.PAS` that writes to the visible play area is a defect. Diagnostic output goes to the log file only.

### Rule 5: Log file is the single diagnostic output stream

All diagnostic output flows through `LOG.PAS`. No unit writes diagnostic `WriteLn` calls directly. This is the TP7 equivalent of the Python rule: all output goes through the logging framework, not to `print()`.

### Rule 6: Never include gameplay data in always-on log output

`ERROR` and `WARNING` are always written. Do not include information in these messages that would reveal level layout, enemy positions, or other gameplay content that could affect a player who reads the log file. Use `DEBUG` (gated) for gameplay-internal state.

### Rule 7: Granularity follows the diagnostic need

One `INFO` per lifecycle transition. One `DEBUG` per notable entity event. No log output per statement. Use state dumps (§4) for fine-grained inspection at failure sites.

---

## 6. Observability checklist

A game build has adequate observability when any runtime failure or unexpected behaviour can be diagnosed from `GAME.LOG` without running the game again.

- [ ] `InitLog` is the first call in `GAME.PAS`
- [ ] Every major lifecycle transition is logged at `INFO`
- [ ] Every `FALSE` return from a callee is accompanied by a `LogError`
- [ ] Every `Halt(99)` is preceded by a `LogError` and a state dump
- [ ] Every slow-tick condition is caught and logged at `DEBUG` (gated)
- [ ] No `WriteLn` to the gameplay screen outside `RENDER.PAS`
- [ ] All `DEBUG` and `INFO` calls are gated by `{$IFDEF}` and produce zero overhead in release
- [ ] `DumpState` procedures exist for units with complex invariants
- [ ] `CloseLog` is called on every exit path in `GAME.PAS`

---

## References

- Borland International, *Turbo Pascal 7.0 Language Guide*, 1992 — Chapter 8 (Compiler Directives), Chapter 17 (Text Files).
- aib-genai-standards, `logging/telemetry-standard.md` — the Python observability standard this document is adapted from.
- [Google SRE Book — Monitoring Distributed Systems](https://sre.google/sre-book/monitoring-distributed-systems/): the four golden signals concept applies even to single-process programs.
- [12 Factor App — Logs](https://12factor.net/logs): treat log output as a stream of time-ordered events.
