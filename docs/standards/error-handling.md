# Error Handling Standard — Turbo Pascal 7

## Purpose

This document defines how errors are detected, classified, reported, propagated, and documented in all Pascal source files. Turbo Pascal 7 does not have structured exception handling (that arrives only with Delphi). Errors are handled via return codes, boolean flags, and the `IOResult` / `{$I-}` mechanism. The patterns here establish consistent conventions across all game code.

---

## 1. Categories of error

Every error belongs to exactly one of three categories. The category determines how the error is handled and what the caller is expected to do.

| Category | Examples | Handling approach |
| --- | --- | --- |
| **Programmer error** | Array out of bounds, nil pointer dereference, wrong argument type | Caught by `{$R+}` / `{$S+}` at runtime during development; do not catch or mask these |
| **Recoverable runtime error** | File not found, disk full, bad save-file format | Boolean return + `errorMsg` out-parameter; caller must check and act |
| **Impossible state** | Tile value outside enum range, game-loop invariant violated | `Halt` with a descriptive message; caller cannot recover |

When you are writing a new procedure, decide its category first. The category determines which pattern below to apply.

---

## 2. Compiler-checked safety

Keep `{$R+}` (range checking) and `{$S+}` (stack checking) **on during development and all acceptance tests**. Disable only in the release build, and record that decision explicitly at the top of every source file.

Development (default for all source files):

```pascal
{$R+}  { range checking: ON during development }
{$S+}  { stack checking: ON during development }
```

Release build (`GAME.PAS` only — override at program level):

```pascal
{$R-}  { range checking off for release — enable with $R+ during development }
{$S-}  { stack checking off for release }
```

This makes programmer errors fail loudly and early in development rather than producing silent data corruption.

---

## 3. Recoverable errors: the boolean + message pattern

Procedures and functions that can fail for recoverable reasons return a `Boolean` success flag. An `errorMsg` output parameter carries a human-readable explanation when the procedure returns `False`.

```pascal
{ Loads world data from file.
  Errors:
    [caller]   File not found or access denied: returns False,
               sets errorMsg to a message naming the file and the
               DOS error code.
    [internal] IOResult is consumed before returning; caller does
               not need to check it. }
function LoadWorld(const fileName: String;
                   var W: TWorld;
                   var errorMsg: String): Boolean;
var
  f    : File of TWorldRecord;
  ioErr: Integer;
begin
  LoadWorld := False;
  {$I-}
  Assign(f, fileName);
  Reset(f);
  {$I+}
  ioErr := IOResult;
  if ioErr <> 0 then
  begin
    errorMsg := 'Cannot open world file "' + fileName +
                '" (DOS error ' + IntToStr(ioErr) + ')';
    Exit;
  end;
  Read(f, W.Data);
  Close(f);
  LoadWorld := True;
  errorMsg := '';
end;
```

### 3.1 Rules for the callee

- Set the return value explicitly on **every** exit path — never rely on the Pascal default (`False` for Boolean)
- Capture `IOResult` into a local variable immediately after `{$I+}` — do not call `IOResult` twice (the second call always returns 0)
- The error message must identify **what** failed, **which resource** was involved, and **why** (include the DOS error code for I/O failures)
- Never return `True` until all operations that could fail have succeeded

### 3.2 Rules for the caller

The caller **must** check every `Boolean` return value. Silently ignoring a `False` return is a defect.

```pascal
{ Good — failure is handled }
if not LoadWorld('LEVEL1.DAT', world, msg) then
begin
  WriteLn('Fatal: ', msg);
  Halt(1);
end;

{ Bad — return value ignored; world is in undefined state if load failed }
LoadWorld('LEVEL1.DAT', world, msg);
DrawWorld(world);
```

### 3.3 Consistency rule

All procedures in the same unit that can fail must signal failure the same way. Do not return `False` in one procedure and `0` (or `nil`, or an empty string) in another for the same class of error.

```pascal
{ Bad — inconsistent: one returns Boolean, another returns 0 as sentinel }
function LoadWorld(...): Boolean;
function GetTileChar(tile: TTile): Char;  { returns '?' on unknown tile }

{ Good — consistent: both return Boolean + errorMsg }
function LoadWorld(...; var errorMsg: String): Boolean;
function ValidateTile(tile: TTile; var errorMsg: String): Boolean;
```

Callers that use a unit must be able to apply a single mental model for checking failures. A unit that mixes patterns forces callers to remember which function uses which convention — that is where silent errors are born.

---

## 4. Impossible state: Halt with context

When the code reaches a state that is structurally impossible — a value that violates a type invariant, a branch that "can never be taken" — call `Halt` with a message that names the procedure, the offending value, and any relevant context.

```pascal
case tile of
  tileEmpty  : { draw nothing };
  tileWall   : DrawChar('#');
  tileLadder : DrawChar('H');
  tileDollar : DrawChar('$');
  tileExit   : DrawChar('>');
  else
  begin
    WriteLn('INTERNAL ERROR in DrawTile: unknown TTile value ',
            Ord(tile), ' at (', x, ',', y, ')');
    Halt(99);
  end;
end;
```

Rules:

- Include the procedure name, the offending value (use `Ord()` for enum values), and relevant coordinates or identifiers
- Use exit code **99** for internal errors — this distinguishes them from normal exit (0) and I/O errors (1) in build tooling
- Never silently skip an impossible case (`else { nothing }`) — silent skips mask bugs until they produce wrong output far from the actual defect site

### 4.1 Non-critical failures: the swallow rule

Occasionally a failure is genuinely non-critical — the program can continue correctly without it (e.g. failing to write a high-score log file does not affect gameplay). When a failure is intentionally swallowed:

1. **It must never be silently swallowed.** At minimum, write a `WriteLn` to indicate the failure was observed.
2. **It must have an explanatory comment** at the swallow site stating why the failure is safe to ignore.
3. **The program state must remain valid** — the caller must verify that continuing without the failed operation leaves all invariants intact.

```pascal
{ Bad — silently swallowed; no indication anything went wrong }
SaveHighScore('SCORES.DAT', score, msg);
ContinueGame;

{ Good — failure observed and explained }
if not SaveHighScore('SCORES.DAT', score, msg) then
begin
  WriteLn('Warning: could not save high score (', msg, ') — continuing');
  { Non-critical: score persistence failure does not affect current game
    session; the player can continue playing. }
end;
ContinueGame;
```

---

## 5. Error message quality

Every error message must answer three questions:

| Question | Example |
| --- | --- |
| **What** failed? | "Cannot open world file" |
| **Which** resource? | `'"LEVEL1.DAT"'` |
| **Why** (if determinable)? | `'(DOS error 2 — file not found)'` |

```pascal
{ Bad — caller cannot identify the problem }
errorMsg := 'Error loading file';

{ Bad — names the resource but not the cause }
errorMsg := 'Cannot load LEVEL1.DAT';

{ Good }
errorMsg := 'Cannot open world file "' + fileName +
            '" (DOS error ' + IntToStr(ioErr) + ')';
```

For internal errors (§4), the message must additionally name the **procedure** and the **bad value**:

```pascal
{ Good internal error message }
WriteLn('INTERNAL ERROR in UpdateEnemy: enemy index ', i,
        ' out of range [0..', MAX_ENEMIES - 1, ']');
```

---

## 6. IOResult reference

`IOResult` returns 0 on success. Non-zero values are DOS error codes. Always capture `IOResult` into a named local variable immediately after `{$I+}` — this makes the intent explicit and prevents accidental double-calls.

```pascal
var
  ioErr : Integer;
begin
  {$I-}
  Reset(f);
  {$I+}
  ioErr := IOResult;   { capture exactly once }
  if ioErr <> 0 then ...
```

Common DOS I/O error codes:

| Code | Meaning |
| --- | --- |
| 0 | Success |
| 2 | File not found |
| 3 | Path not found |
| 5 | Access denied |
| 6 | Invalid file handle |
| 100 | Disk read error |
| 101 | Disk write error |
| 102 | File not assigned (`Assign` not called) |
| 103 | File not open |
| 104 | File not open for input |
| 105 | File not open for output |

---

## 7. Anti-patterns

| Anti-pattern | Why it is wrong | Correct approach |
| --- | --- | --- |
| Ignore a non-zero `IOResult` | Subsequent file operations produce undefined behaviour | Check `IOResult` on every `{$I+}` exit |
| Call `IOResult` twice | Second call always returns 0 — the error is lost | Capture into a local variable once |
| Use a generic "error" message | Makes debugging impossible | Name the resource, the operation, and the cause |
| Leave `{$I-}` active across multiple I/O calls | `IOResult` holds only the most recent result — earlier errors are lost | Use `{$I-}` / `{$I+}` brackets around each individual I/O call |
| Silently skip an impossible `else` case | Masks type invariant violations until they produce wrong output | `Halt(99)` with a message |
| Silently swallow a non-critical failure | Hides problems that may indicate deeper bugs | Write a `WriteLn` warning and add an explanatory comment |
| Inconsistent failure signalling within a unit | Forces callers to remember per-function conventions | One signalling pattern per unit |
| Set `errorMsg` on the success path | Confuses callers who check `errorMsg` without checking the return value | Set `errorMsg := ''` on success; only populate it on failure |

---

## 8. Documentation requirement

Every exported function or procedure that can fail must document its error behaviour in its header comment using the `Errors:` field defined in [documentation-standards.md](documentation-standards.md). Every error condition must be classified as `[caller]`, `[internal]`, or `[fatal]`.

```pascal
{ Saves the current score to the high-score file.

  Errors:
    [caller]   File cannot be created or written: returns False,
               sets errorMsg to a message naming the file and DOS error.
    [internal] IOResult is consumed before returning.
    [fatal]    score < 0: Halt(99) — score invariant violated. }
function SaveHighScore(const fileName: String;
                       score: Integer;
                       var errorMsg: String): Boolean;
```

See [documentation-standards.md §3 — Errors](documentation-standards.md) for the full field specification.

---

## 9. Error handling checklist

Before committing any unit:

- [ ] Every error is classified as programmer error, recoverable, or impossible state
- [ ] Every file operation is wrapped in its own `{$I-}` / `{$I+}` bracket
- [ ] `IOResult` is captured into a named local variable exactly once per bracket
- [ ] Every function that can fail returns `Boolean` and sets it explicitly on every exit path
- [ ] Every error message names the resource, the operation, and the cause (DOS error code for I/O)
- [ ] Every `False` return from a callee is checked by the caller
- [ ] Every structurally impossible case calls `Halt(99)` with a message naming the procedure and the bad value
- [ ] Every intentionally swallowed non-critical failure has a `WriteLn` warning and an explanatory comment
- [ ] All procedures in the same unit that can fail use the same signalling pattern
- [ ] Every exported failing procedure has an `Errors:` field in its documentation comment
- [ ] `{$R+}` and `{$S+}` are enabled in the development build

---

## References

- Borland International, *Turbo Pascal 7.0 Language Guide*, 1992 — Chapter 19 (Run-Time Errors).
- Borland International, *Turbo Pascal 7.0 Programmer's Guide*, 1992 — Appendix B (Error Codes).
- aib-genai-standards, `coding/error-handling.md` — the Python standard this document is adapted from.
- [PEP 20 — The Zen of Python](https://peps.python.org/pep-0020/): "Errors should never pass silently. Unless explicitly silenced."
