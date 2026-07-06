# Logging Standard — Turbo Pascal 7

## Purpose

This document defines how diagnostic output is written in all Pascal source files. It covers log levels, message format, output routing, what to log at each stage of the game loop, and the relationship between logging and error handling. For game-loop timing and performance observation, see [observability-standard.md](observability-standard.md).

Turbo Pascal 7 has no logging framework. All diagnostic output is `WriteLn` to the console or to a log file. The patterns here establish consistent conventions so that output is useful during development, silent in release, and never mixed with gameplay output.

---

## If you are coming from a language with a logging framework

Python, Java, and most modern languages have a logging framework with named loggers, configurable levels, and output handlers:

```python
# Python
import logging
logger = logging.getLogger(__name__)
logger.info("Player moved to (%d, %d)", x, y)
logger.error("Failed to load world: %s", msg)
```

In TP7 there is no equivalent library. The patterns in this document reproduce the same discipline — levels, routing, message format, configuration — using `WriteLn`, a compile-time `{$DEFINE}` flag, and an output file handle. The concepts are identical; only the mechanism differs.

---

## 1. Log levels

Four levels apply, in descending severity. The level determines where output goes and whether it appears in development vs release builds.

| Level | Macro | When to use | Development | Release |
| --- | --- | --- | --- | --- |
| `ERROR` | `LogError` | I/O failures, unrecoverable states, anything that means the program cannot continue correctly | Always emitted — to log file and screen | Always emitted — to log file |
| `WARNING` | `LogWarning` | Expected-but-notable conditions: a file not found at an optional path, a value clamped to its boundary | Always emitted — to log file | Always emitted — to log file |
| `INFO` | `LogInfo` | State transitions and lifecycle events: game started, level loaded, player spawned | Emitted when `{$DEFINE LOG_INFO}` is set | Never emitted |
| `DEBUG` | `LogDebug` | Verbose per-tick diagnostics: player position each frame, tile lookup results | Emitted when `{$DEFINE LOG_DEBUG}` is set | Never emitted |

### Rules

- `ERROR` is always on in all builds. A release build that silently suppresses errors provides no diagnostic information when something goes wrong.
- Do not use `INFO` for events that occur every game tick — use `DEBUG`. High-frequency `INFO` output obscures the lifecycle events `INFO` is meant to capture.
- Do not use `WARNING` for errors that require action — use `ERROR`. A warning implies the program can continue correctly; an error implies it may not.
- `DEBUG` output must never appear in a release build. Verbose per-tick output in a release binary degrades performance and fills the log file with noise.

---

## 2. Log output routing

Two output destinations:

| Destination | When used | Content |
| --- | --- | --- |
| **Log file** (`GAME.LOG`) | Development and release | All levels that are active for the current build |
| **Screen** (`WriteLn` to console) | Development only, `ERROR` level only | Errors that the operator needs to see immediately |

The screen is gameplay territory. Any `WriteLn` that writes to the visible play area outside of the `RENDER` unit is a defect. Diagnostic output in development uses a dedicated log file, not the gameplay screen.

In release builds, `ERROR` and `WARNING` go to the log file only — the screen is exclusively for the game.

---

## 3. Implementation: the LOG unit

All logging is routed through a single `LOG.PAS` unit. Calling code never writes to the log file directly.

### 3.1 Interface

```pascal
unit LOG;

{ Provides levelled diagnostic output for development and release builds.
  All output goes to GAME.LOG. ERROR output is also written to the screen
  in development builds.

  Initialise once at program start with InitLog before calling any other
  procedure in this unit. }

interface

{ Initialises the log file. Must be called before any LogXxx procedure.
  Errors:
    [caller] File cannot be created: returns False, sets errorMsg. }
function InitLog(const fileName: String; var errorMsg: String): Boolean;

{ Closes the log file and flushes all pending output. }
procedure CloseLog;

{ Writes a message at ERROR level. Always active in all builds.
  Also writes to the screen in development builds ({$DEFINE DEBUG_BUILD}). }
procedure LogError(const msg: String);

{ Writes a message at WARNING level. Always active in all builds. }
procedure LogWarning(const msg: String);

{ Writes a message at INFO level.
  Active only when {$DEFINE LOG_INFO} is set at compile time. }
procedure LogInfo(const msg: String);

{ Writes a message at DEBUG level.
  Active only when {$DEFINE LOG_DEBUG} is set at compile time. }
procedure LogDebug(const msg: String);
```

### 3.2 Implementation sketch

```pascal
implementation

uses
  Dos;  { for GetTime }

var
  logFile    : Text;
  logIsOpen  : Boolean;

function TimeStamp: String;
var
  h, m, s, cs : Word;
begin
  GetTime(h, m, s, cs);
  TimeStamp := '[' +
    Copy('0' + IntToStr(h),  Length('0' + IntToStr(h)) - 1, 2) + ':' +
    Copy('0' + IntToStr(m),  Length('0' + IntToStr(m)) - 1, 2) + ':' +
    Copy('0' + IntToStr(s),  Length('0' + IntToStr(s)) - 1, 2) +
  ']';
end;

procedure WriteLog(const level, msg: String);
begin
  if not logIsOpen then Exit;
  WriteLn(logFile, TimeStamp + ' [' + level + '] ' + msg);
  Flush(logFile);
end;

procedure LogError(const msg: String);
begin
  WriteLog('ERROR', msg);
  {$IFDEF DEBUG_BUILD}
  WriteLn('ERROR: ', msg);  { also echo to screen in dev builds }
  {$ENDIF}
end;

procedure LogWarning(const msg: String);
begin
  WriteLog('WARN ', msg);
end;

procedure LogInfo(const msg: String);
begin
  {$IFDEF LOG_INFO}
  WriteLog('INFO ', msg);
  {$ENDIF}
end;

procedure LogDebug(const msg: String);
begin
  {$IFDEF LOG_DEBUG}
  WriteLog('DEBUG', msg);
  {$ENDIF}
end;
```

The `{$IFDEF}` guards mean that `LogDebug` and `LogInfo` calls compile to zero bytes in a release build — there is no runtime cost for disabled levels.

---

## 4. Message format

Every log message must answer three questions in this order: **when**, **where**, **what**.

The timestamp is written by `WriteLog` automatically. The calling code is responsible for **where** and **what**.

```
[HH:MM:SS] [LEVEL] <unit>.<procedure>: <what happened> [<identifiers>]
```

Examples:

```
[14:23:01] [ERROR] WORLD.LoadWorld: cannot open world file "LEVEL1.DAT" (DOS error 2)
[14:23:01] [INFO ] GAME.StartGame: game started level=1 player=(5,10)
[14:23:15] [WARN ] PLAYER.MovePlayer: player clamped to world boundary x=0
[14:23:16] [DEBUG] ENEMY.UpdateEnemy: enemy[2] moved dir=left pos=(12,8)
```

### 4.1 Include the unit and procedure name

Always prefix the message with `UNITNAME.ProcedureName:`. This replaces the Python `logging.getLogger(__name__)` mechanism — since there is no logger hierarchy, the prefix provides the same navigational information.

```pascal
{ Good — locatable }
LogError('WORLD.LoadWorld: cannot open world file "' + fileName + '"');

{ Bad — impossible to locate in a large codebase }
LogError('File not found');
```

### 4.2 Include resource identifiers

Include the relevant identifiers so that a log line can be understood in isolation: file names, level numbers, player/enemy coordinates, tile values.

```pascal
{ Good }
LogInfo('GAME.LoadLevel: level loaded level=' + IntToStr(levelNum) +
        ' tiles=' + IntToStr(tileCount));

{ Bad — no context }
LogInfo('GAME.LoadLevel: level loaded');
```

### 4.3 ERROR messages must name the cause

For `ERROR` level, include the DOS error code or the specific condition that caused the failure. See [error-handling.md §5 — Error message quality](error-handling.md).

```pascal
LogError('WORLD.LoadWorld: cannot read world data from "' +
         fileName + '" (DOS error ' + IntToStr(ioErr) + ')');
```

### 4.4 Do not construct expensive strings for DEBUG messages

In development, `LogDebug` calls are active. Avoid constructing long strings inside the call if the information is not needed:

```pascal
{ Acceptable for DEBUG — position is cheap to format }
LogDebug('PLAYER.Update: pos=(' + IntToStr(P.X) + ',' + IntToStr(P.Y) + ')');

{ Avoid — do not call expensive formatting functions just to log }
LogDebug('RENDER.DrawWorld: ' + WorldToString(W));  { WorldToString is expensive }
```

---

## 5. What to log at each level

### ERROR — log when a recoverable procedure returns False

Every time a called procedure returns `False` (indicating failure), log at `ERROR` before taking recovery action.

```pascal
if not LoadWorld('LEVEL1.DAT', world, msg) then
begin
  LogError('GAME.StartGame: world load failed — ' + msg);
  Halt(1);
end;
```

### WARNING — log notable-but-continuing conditions

```pascal
if P.X < 0 then
begin
  LogWarning('PLAYER.MovePlayer: player X clamped from ' +
             IntToStr(P.X) + ' to 0');
  P.X := 0;
end;
```

### INFO — log lifecycle transitions

Log once at each major state change: program start, level load, level complete, game over. Not per-tick.

```pascal
LogInfo('GAME.StartGame: game started lives=' + IntToStr(lives) +
        ' level=' + IntToStr(levelNum));
LogInfo('GAME.LevelComplete: level ' + IntToStr(levelNum) +
        ' completed score=' + IntToStr(score));
```

### DEBUG — log per-tick state for active diagnosis

Only add `DEBUG` calls when actively diagnosing a problem. Remove or gate them under a specific `{$DEFINE}` when the bug is fixed. Do not leave permanent per-tick `DEBUG` calls in the codebase — they fill the log file.

```pascal
{$IFDEF LOG_MOVEMENT}
LogDebug('PLAYER.MovePlayer: player moved dir=' + DirName(dir) +
         ' pos=(' + IntToStr(P.X) + ',' + IntToStr(P.Y) + ')');
{$ENDIF}
```

---

## 6. Build configuration

Three compile-time configurations:

| Configuration | Defines | Intended use |
| --- | --- | --- |
| **Development** | `DEBUG_BUILD`, `LOG_INFO` | Day-to-day development — ERROR echoed to screen, INFO to log file |
| **Verbose** | `DEBUG_BUILD`, `LOG_INFO`, `LOG_DEBUG` | Active bug investigation — all levels to log file |
| **Release** | *(none)* | Course demonstration — ERROR and WARNING to log file only; no screen output; zero overhead for INFO/DEBUG calls |

Set these in `GAME.PAS` at the top, before any `uses` clause:

```pascal
{ Development build — comment out for release }
{$DEFINE DEBUG_BUILD}
{$DEFINE LOG_INFO}

{ Verbose build — uncomment only when actively debugging }
{ {$DEFINE LOG_DEBUG} }
```

---

## 7. Log initialisation and shutdown

Log initialisation must be the **first** thing that happens in `GAME.PAS`, before any other unit is used. This ensures that errors during initialisation of other units are captured.

```pascal
begin
  { Initialise log before anything else }
  if not InitLog('GAME.LOG', msg) then
  begin
    WriteLn('FATAL: cannot open log file: ', msg);
    Halt(1);
  end;

  LogInfo('GAME: program started');

  { ... rest of initialisation ... }

  LogInfo('GAME: program exiting normally');
  CloseLog;
end.
```

`CloseLog` must be called before `Halt` on every exit path to ensure the log file is flushed and closed. An unflushed `Text` file in TP7 loses the last buffer of output.

```pascal
{ Correct — CloseLog before every Halt }
if not LoadWorld('LEVEL1.DAT', world, msg) then
begin
  LogError('GAME.Init: ' + msg);
  CloseLog;
  Halt(1);
end;
```

---

## 8. Libraries must not initialise the log

Units other than `GAME.PAS` must never call `InitLog` or `CloseLog`. They may call `LogXxx` procedures freely. The calling program is responsible for log lifetime — a unit that initialises the log will conflict with the program's own setup.

This mirrors the Python rule: libraries must never call `logging.basicConfig()`.

---

## 9. Logging checklist

Before committing any unit:

- [ ] Every `False` return from a callee is accompanied by a `LogError` call
- [ ] Every `WARNING`-level condition has an explanatory log message that includes the value that triggered it
- [ ] Every lifecycle transition (start, load, complete, end) is logged at `INFO`
- [ ] All `DEBUG` calls are gated under a specific `{$DEFINE}` and not left permanently active
- [ ] Every log message is prefixed with `UNITNAME.ProcedureName:`
- [ ] Every log message includes the relevant identifiers (file name, level, coordinates)
- [ ] No `WriteLn` to the gameplay screen outside of `RENDER.PAS`
- [ ] `CloseLog` is called before every `Halt` in `GAME.PAS`
- [ ] No unit other than `GAME.PAS` calls `InitLog` or `CloseLog`

---

## References

- Borland International, *Turbo Pascal 7.0 Language Guide*, 1992 — Chapter 17 (Text Files), Chapter 8 (Conditional Compilation).
- aib-genai-standards, `logging/logging-standard.md` — the Python standard this document is adapted from.
- [12 Factor App — Logs](https://12factor.net/logs): treat log output as an event stream.
