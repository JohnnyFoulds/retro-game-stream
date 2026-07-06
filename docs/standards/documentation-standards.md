# Documentation Standards — Turbo Pascal 7

## Purpose

This document defines the inline documentation requirements for all Pascal source files. It specifies what must be documented, the exact comment format for each construct, and the rules for parameter, return-value, exception, and example documentation. The goal is that any procedure or function in the `interface` section can be understood — and used correctly — without reading its implementation.

---

## 1. Scope: what must be documented

| Construct | Required | Notes |
| --- | --- | --- |
| Exported procedures and functions | **Mandatory** | Every declaration in the `interface` section |
| Exported types (`TPlayer`, `TTile`, …) | **Mandatory** | At least one sentence describing the invariant or role |
| Exported constants | **Mandatory** when non-obvious | Omit only if the name is fully self-explanatory (e.g. `MAX_ENEMIES = 5`) |
| Exported variables | **Mandatory** | State who owns it and when it is valid |
| Units (module-level) | **Mandatory** | One short paragraph at the top of the `interface` section |
| Private procedures and functions | **When non-obvious** | Required when the purpose cannot be inferred from the name and signature alone |
| Private types, constants, variables | Optional | Add when they encode a non-obvious invariant |

---

## 2. Format

Pascal does not have a language-defined documentation syntax (no equivalent to Python docstrings or Java Javadoc). This project uses **structured brace comments** in a fixed field order. All documentation comments use `{ }` — never `(* *)`.

### 2.1 Short form

Use when there are no parameters, no return value, and no preconditions to document:

```pascal
{ Clears all tiles in W to tileEmpty and resets the world dimensions. }
procedure InitWorld(var W: TWorld);
```

One sentence, full stop, fits on one line if possible.

### 2.2 Full form

Use when any of the following apply: the procedure has parameters whose purpose is not obvious from the name; it returns a value; it has preconditions, postconditions, or side effects; it can fail.

```pascal
{ Moves the player one cell in the given direction if the destination
  is passable. Does not wrap at world boundaries.

  Parameters:
    W    - the world map; read-only during movement
    P    - player record; X and Y are updated on success
    Dir  - direction of movement; dirNone is a no-op

  Returns:
    True  if the move succeeded and P was updated
    False if the destination is out of bounds or blocked

  Preconditions:
    W must be initialised via InitWorld.
    P.X and P.Y must be within world bounds.

  Side effects:
    None. Rendering is the caller's responsibility.

  Errors:
    [caller] Destination out of bounds or blocked: returns False,
             P is unchanged. }
function MovePlayer(const W: TWorld; var P: TPlayer;
                    Dir: TDirection): Boolean;
```

### 2.3 Field order

Fields always appear in this order; omit fields that do not apply:

1. **Summary** — one-sentence description of what the procedure does (mandatory)
2. **Extended description** — additional sentences for non-obvious behaviour, edge cases, or what it does NOT do (when needed)
3. **Parameters** — one line per parameter: `name - description` (when any parameter is non-obvious)
4. **Returns** — what `True`/`False` mean for functions, or what value is returned (mandatory for all functions)
5. **Preconditions** — what the caller must guarantee (when non-trivial)
6. **Postconditions** — what will be true after the call (when non-trivial and not captured by Returns)
7. **Side effects** — global state modified, screen output written, files opened/closed (mandatory if any exist)
8. **Errors** — one labelled entry per error condition, classified as `[caller]`, `[internal]`, or `[fatal]` (mandatory for any procedure that can fail or does I/O)
9. **Example** — a short call sequence (mandatory for "tool procedures" — public entry points that are the primary way a unit is used)

---

## 3. Field reference

### Summary line

- First sentence only; full stop at the end
- Active voice, third-person singular: "Draws…", "Initialises…", "Returns…"
- 80 characters maximum
- Do not repeat the procedure name verbatim: `{ MovePlayer moves the player }` adds nothing

```pascal
{ Good }
{ Moves the player one cell in the given direction if the destination is passable. }

{ Bad — restates the name }
{ MovePlayer: moves player. }
```

### Parameters

Document every parameter whose role is not completely obvious from its name and type. Omit only when the parameter is trivially named (e.g. `x, y: Integer` in a `DrawAt(x, y)` procedure — their roles are self-evident).

Format: `name - description`. No type repetition (the signature already carries the type).

```pascal
{ Parameters:
    W      - world map; used read-only to check tile passability
    P      - player record; X and Y updated if move succeeds
    Dir    - direction of travel; dirNone is accepted and is a no-op }
```

For `var` parameters, note that the value is modified:

```pascal
{   score  - running total; incremented by SCORE_PER_DOLLAR on collection }
```

### Returns

Mandatory for every `function`. State every distinct return value and its meaning.

```pascal
{ Returns:
    True  if the dollar was collected and score incremented
    False if (x, y) does not contain tileDollar }
```

For functions that return a numeric result:

```pascal
{ Returns:
    The ASCII code of the key pressed, or 0 if no key is waiting. }
```

### Preconditions

Document non-trivial caller obligations. Trivial ones (e.g. "x must be an Integer") are not worth documenting.

```pascal
{ Preconditions:
    W must have been initialised via InitWorld before this call.
    (x, y) must be within [0, WORLD_WIDTH-1] x [0, WORLD_HEIGHT-1]. }
```

### Postconditions

Use when the post-state is non-obvious and not captured by the Returns field.

```pascal
{ Postconditions:
    W.Tiles[y][x] = tileEmpty.
    All other tiles in W are unchanged. }
```

### Side effects

List every observable effect beyond the return value and `var` parameters: screen output, global variable modification, file I/O, cursor movement.

```pascal
{ Side effects:
    Writes to the screen at the current cursor position.
    Does not restore the cursor after drawing. }
```

If there are no side effects, write `{ Side effects: none. }` only when a caller might reasonably expect some (e.g. a procedure called `DrawWorld` — the caller knows it draws, so this field is redundant and should be omitted).

### Errors

Mandatory for any procedure or function that can fail, does file I/O, or reaches a state from which it cannot recover. Use one labelled entry per distinct error condition, classified by what the **caller** must do about it.

Three classes:

| Class | Label | Meaning |
| --- | --- | --- |
| Caller must handle | `[caller]` | The procedure signals failure via its return value or an `errorMsg` parameter; the caller is expected to check and act |
| Internally handled | `[internal]` | The error is detected and absorbed inside the procedure (e.g. `IOResult` consumed, a default applied); the caller receives no signal and needs to do nothing |
| Fatal / unrecoverable | `[fatal]` | The procedure calls `Halt`; the caller cannot intercept this |

Format: one line per condition — `[class] <condition>: <what happens>`.

```pascal
{ Errors:
    [caller]   File not found or access denied: returns False,
               sets errorMsg to a message naming the file.
    [internal] IOResult is consumed before returning; caller does
               not need to check it.
    [fatal]    World dimensions exceed MAX_WORLD_SIZE: Halt(99)
               with a message identifying the bad value. }
function LoadWorld(const fileName: String;
                   var W: TWorld;
                   var errorMsg: String): Boolean;
```

Rules:

- Every `[caller]` entry must name the return value or out-parameter that carries the signal
- Every `[fatal]` entry must match a corresponding `[fatal]` rule in [error-handling.md](error-handling.md) §4
- `[internal]` entries are written when a caller might reasonably expect to need to handle an error themselves (e.g. `IOResult` after file I/O) — omit when there is no realistic chance of confusion
- If a procedure has no error conditions at all, omit the `Errors:` field entirely — do not write `Errors: none`

Bad/good contrast:

```pascal
{ Bad — unclassified, caller cannot tell what action is required }
{ Error behaviour:
    Returns False and sets errorMsg if the file cannot be opened.
    IOResult is consumed internally. }

{ Good — each condition is classified }
{ Errors:
    [caller]   File not found or access denied: returns False,
               sets errorMsg to a message naming the file.
    [internal] IOResult is consumed before returning. }
```

### Example

Mandatory for "tool procedures" — the primary public entry point of a unit, or any procedure whose correct call sequence is non-obvious.

The example must be:
- **Minimal** — shows only what is needed to demonstrate correct use
- **Complete** — can be read without external context
- **Correct** — matches the actual procedure signature

```pascal
{ Example:
    InitWorld(world);
    world.Tiles[3][5] := tileDollar;
    if not TryCollect(world, 5, 3, score, msg) then
      WriteLn('Collect failed: ', msg); }
```

---

## 4. Unit-level documentation

Place a documentation block immediately after the `unit` keyword and before `interface`. It describes the unit's single responsibility.

```pascal
unit WORLD;

{ Owns the world map: tile storage, initialisation, and tile-level queries.
  Does not handle rendering (see RENDER) or player state (see PLAYER).

  The world is a fixed 2D grid of TTile values. All coordinates are
  zero-based: (0,0) is the top-left cell. }

interface
```

Rules:
- One sentence stating the single responsibility
- One sentence stating what this unit does NOT do (the boundary)
- One sentence describing the core data structure, if non-obvious

---

## 5. Type documentation

Exported types must have a comment describing their invariant or role, placed immediately above the `type` declaration:

```pascal
{ Represents the complete state of one player. X and Y are zero-based
  world coordinates. isAlive becomes False when the player touches an
  enemy; the game loop must check this each tick. }
TPlayer = record
  X, Y    : Integer;
  isAlive : Boolean;
end;
```

For enumerations, document any values whose meaning is non-obvious:

```pascal
{ The set of directions the player or an enemy can move.
  dirNone is used as a sentinel when no movement has been requested. }
TDirection = (dirNone, dirLeft, dirRight, dirUp, dirDown);
```

---

## 6. Exported variable documentation

Global exported variables must document who is responsible for initialising them and when they are valid:

```pascal
var
  { Current score. Initialised to 0 by InitGame. Updated by CollectDollar.
    Read by the render loop each tick. }
  score : Integer;
```

---

## 7. Inline comments

These are distinct from documentation headers. See [coding-standards.md §8](coding-standards.md) for the rule (write only when the *why* is non-obvious). A few patterns worth calling out:

**`{$...}` directives** must have a trailing comment explaining any non-default setting:

```pascal
{$R-}  { range checking off for release build }
```

**Magic-number guards** — when a literal cannot yet be extracted to a constant, explain it inline:

```pascal
if P.Y >= 20 then  { 20 = WORLD_HEIGHT; extract to const once WORLD unit exists }
```

**Workarounds** — document the bug or constraint being worked around, not what the code does:

```pascal
GotoXY(1, 1);  { TP7 does not reset cursor after ClrScr on some BIOS versions }
```

---

## 8. Documentation checklist

Before committing a unit:

- [ ] Unit has a unit-level documentation block
- [ ] Every exported procedure and function has at least a summary comment
- [ ] Every function has a `Returns:` field
- [ ] Every exported type has a comment stating its role or invariant
- [ ] Any procedure that can fail or does I/O has an `Errors:` field with every condition classified as `[caller]`, `[internal]`, or `[fatal]`
- [ ] Any procedure with side effects (screen output, global mutation) has a `Side effects:` field
- [ ] Primary entry-point procedures have an `Example:` field
- [ ] No comment repeats information already in the type signature
- [ ] All `{$...}` non-default directives have an explanatory comment

---

## References

- Borland International, *Turbo Pascal 7.0 Language Guide*, 1992 — Chapter 2 (Comments).
- aib-genai-standards, `coding/docstring-standards.md` — the Python standard this document is adapted from.
