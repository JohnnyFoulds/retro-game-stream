# Error Handling Standard — Turbo Pascal 7

## Purpose

This document defines how errors are detected, reported, and propagated in all Pascal source files. Turbo Pascal 7 does not have structured exception handling (that arrives only with Delphi). Errors are handled via return codes, boolean flags, and the `IOResult` / `{$I-}` mechanism. The patterns here establish consistent conventions across all game code.

---

## 1. Categories of error

| Category | Examples | Handling approach |
| --- | --- | --- |
| **Programmer error** | Array out of bounds, nil pointer dereference | Let the runtime halt with `{$R+}` range checking enabled during development; do not catch these |
| **Recoverable runtime error** | File not found, disk full, bad input | Use boolean result + `errorMsg` out-parameter pattern (see §3) |
| **Impossible state** | Tile value outside enum range in a switch | `Halt` with a descriptive message (see §4) |

---

## 2. Compiler-checked safety

Keep `{$R+}` (range checking) and `{$S+}` (stack checking) **on during development and testing**. Disable only in the release build, and record that decision explicitly in the source file:

```pascal
{$R+}  { range checking: ON during development }
{$S+}  { stack checking: ON during development }
```

Release build (`GAME.PAS`):
```pascal
{$R-}  { range checking off for release — enable with $R+ during development }
{$S-}  { stack checking off for release }
```

This makes programmer errors fail loudly and early during development rather than producing silent corruption.

---

## 3. Recoverable errors: the boolean + message pattern

Procedures that can fail for recoverable reasons return a `Boolean` success flag. An optional `errorMsg` output parameter carries a human-readable explanation when the procedure returns `False`.

```pascal
{ Loads world data from file. Returns False if the file cannot be opened.
  Precondition: fileName is a valid DOS 8.3 path. }
function LoadWorld(const fileName: String;
                   var W: TWorld;
                   var errorMsg: String): Boolean;
var
  f: File of TWorldRecord;
begin
  LoadWorld := False;
  {$I-}
  Assign(f, fileName);
  Reset(f);
  {$I+}
  if IOResult <> 0 then
  begin
    errorMsg := 'Cannot open world file: ' + fileName;
    Exit;
  end;
  Read(f, W.Data);
  Close(f);
  LoadWorld := True;
  errorMsg := '';
end;
```

Rules:

- Always set the return value explicitly before each exit path — never rely on the default value
- Always wrap file I/O in `{$I-}` / `{$I+}` and check `IOResult` immediately after
- The error message must identify **what failed** and **which resource** was involved — not just "error"
- The caller must check the return value. Silent ignoring of a `False` return is a defect

Calling pattern:
```pascal
if not LoadWorld('LEVEL1.DAT', world, msg) then
begin
  WriteLn('Fatal: ', msg);
  Halt(1);
end;
```

---

## 4. Impossible state: Halt with context

When the code reaches a state that should be structurally impossible (a value that violates a type invariant, a branch that "can never be taken"), call `Halt` with a message that identifies the location and the bad value:

```pascal
else
  begin
    WriteLn('INTERNAL ERROR: unknown tile value ', Ord(tile),
            ' at (', x, ',', y, ') in DrawTile');
    Halt(99);
  end;
```

Rules:

- Include the procedure name, the offending value, and relevant coordinates or identifiers
- Use exit code 99 for internal errors so the build system can distinguish them from normal exits (0) and file errors (1)
- Never silently skip an impossible case — that masks bugs until they produce wrong output

---

## 5. IOResult reference

`IOResult` returns 0 on success. Non-zero values are DOS error codes. The most common:

| Code | Meaning |
| --- | --- |
| 0 | Success |
| 2 | File not found |
| 3 | Path not found |
| 5 | Access denied |
| 100 | Disk read error |
| 101 | Disk write error |

Always call `IOResult` exactly once after `{$I+}` — a second call returns 0 regardless.

---

## 6. What not to do

| Anti-pattern | Why it is wrong |
| --- | --- |
| Ignore a non-zero `IOResult` | Subsequent operations on the file produce undefined behaviour |
| Check `IOResult` twice | Second call always returns 0 — the error is silently cleared |
| Use a generic "error" message | Makes debugging impossible; always name the resource |
| Leave `{$I-}` enabled across multiple I/O calls | `IOResult` only holds the result of the most recent call |
| Swallow impossible-state cases with `else { nothing }` | Masks bugs; use `Halt` |

---

## 7. Error handling checklist

Before committing a unit that does file I/O or returns a success flag:

- [ ] Every file operation is wrapped in `{$I-}` / `{$I+}` with an immediate `IOResult` check
- [ ] Every function that can fail returns a `Boolean` and sets it on every exit path
- [ ] Every error message names the resource and the reason
- [ ] Every callee's `False` return is checked by the caller
- [ ] Every structurally impossible case calls `Halt` with a message
- [ ] `{$R+}` is enabled in the development build
