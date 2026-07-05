# Coding Standards — Turbo Pascal 7

## Purpose

This document defines code style, naming, unit structure, and compiler-directive conventions for all Pascal source files in this repository. Consistency matters more than any individual rule — when in doubt, follow existing code.

---

## 1. File and unit naming

- Filenames are **UPPERCASE**, 8 characters maximum (DOS FAT limit): `WORLD.PAS`, `PLAYER.PAS`, `RENDER.PAS`
- Unit names match the filename exactly: `unit WORLD;`, `unit PLAYER;`
- Program file is `GAME.PAS`; test harness is `TEST.PAS`

---

## 2. Indentation and line length

- **2 spaces** per indent level — never tabs
- Maximum line length: **80 characters** (fits a DOS 80-column terminal without wrapping)
- `BEGIN` and `END` on their own lines at the same indent level as the controlling keyword

```pascal
{ Good }
procedure MovePlayer(var P: TPlayer; Dir: TDirection);
begin
  case Dir of
    dirLeft:  Dec(P.X);
    dirRight: Inc(P.X);
  end;
end;

{ Bad — BEGIN on same line as procedure header }
procedure MovePlayer(var P: TPlayer; Dir: TDirection); begin
  ...
end;
```

---

## 3. Naming conventions

| Construct | Convention | Example |
| --- | --- | --- |
| Types | `T` prefix, PascalCase | `TPlayer`, `TDirection`, `TTile` |
| Pointer types | `P` prefix, PascalCase | `PPlayer` |
| Constants | ALL_CAPS with underscores | `MAX_ENEMIES`, `WORLD_WIDTH` |
| Variables | camelCase | `playerX`, `enemyCount`, `score` |
| Procedure / function | PascalCase | `DrawWorld`, `UpdateEnemy` |
| Parameters | camelCase, descriptive | `var player: TPlayer`, `tileChar: Char` |
| Units | UPPERCASE, matches filename | `WORLD`, `RENDER` |
| Boolean variables | Verb prefix: `is`, `has`, `can` | `isAlive`, `hasKey`, `canClimb` |

### Enumerations

Enumeration values use a short prefix of the type name in lowercase, followed by PascalCase:

```pascal
type
  TDirection = (dirNone, dirLeft, dirRight, dirUp, dirDown);
  TTile      = (tileEmpty, tileWall, tileLadder, tileDollar, tileExit);
```

This prevents name clashes since Pascal enumeration values are scoped to the program, not the type.

---

## 4. Unit structure

Every unit follows this section order. Use `{--- Section name ---}` dividers between sections:

```pascal
unit UNITNAME;

{--- Interface ---}
interface

uses
  { comma-separated list, one per line if more than two };

const
  { exported constants };

type
  { exported types };

var
  { exported variables — keep to a minimum };

{ exported procedure/function declarations }

{--- Implementation ---}
implementation

uses
  { implementation-only dependencies };

{ private constants, types, variables }

{ procedure/function bodies }

{--- Initialisation ---}
begin
  { unit initialisation — omit the begin..end if empty }
end.
```

Keep the `interface` section minimal: export only what other units genuinely need. Prefer passing data as parameters over exporting global variables.

---

## 5. Procedure and function headers

All exported procedures, functions, types, and units must carry structured documentation comments. The full format specification — field order, mandatory fields, examples — is in [documentation-standards.md](documentation-standards.md).

Quick rule: every exported procedure or function needs at minimum a one-sentence summary; every function also needs a `Returns:` field. Private procedures need a comment only when the purpose is not obvious from the name and signature.

---

## 6. Constants vs magic numbers

No magic numbers in logic. Every literal with domain meaning gets a named constant:

```pascal
{ Good }
const
  WORLD_WIDTH  = 40;
  WORLD_HEIGHT = 20;
  SCORE_PER_DOLLAR = 1;

{ Bad }
if P.X >= 40 then P.X := 39;
```

Compiler-time expressions in constants are encouraged:

```pascal
const
  WORLD_CELLS = WORLD_WIDTH * WORLD_HEIGHT;
```

---

## 7. Compiler directives

Place all `{$...}` directives at the top of the file, before the `unit` or `program` keyword, grouped by category:

```pascal
{$A+}          { word alignment }
{$R+}          { range checking — disable in release with $R- }
{$S+}          { stack checking }

unit WORLD;
```

For the program file, include a short comment explaining any directive that is non-default:

```pascal
{$R-}          { range checking off for release build — enable during development }
```

---

## 8. Comments

Write comments only when the **why** is not obvious from the code. Do not narrate what the code does if the code already says it.

```pascal
{ Good — explains a non-obvious constraint }
Dec(P.X);  { X is 0-based; the left wall occupies column 0 }

{ Bad — restates the code }
Dec(P.X);  { decrement player X }
```

Comment style:
- Single-line comments: `{ comment }`
- Multi-line comments: `{ first line ... }` with continuation on the next line, still using `{}`
- Do not use `(*` / `*)` style unless `{}` is unavailable

---

## 9. Variable declarations

- Declare variables at the narrowest possible scope (inside a procedure, not in the unit's global `var` block, unless they genuinely need to persist across calls)
- One variable per line in `var` blocks
- Align the colon separator within a `var` block when it improves readability:

```pascal
var
  playerX  : Integer;
  playerY  : Integer;
  score    : Integer;
  isAlive  : Boolean;
```

---

## 10. Case statements

- Align the `:` separators when the case values are short
- Always include an `else` clause when the value space is not fully covered, even if the body is just a comment:

```pascal
case Tile of
  tileWall   : DrawChar('#');
  tileLadder : DrawChar('H');
  tileDollar : DrawChar('$');
  tileExit   : DrawChar('>');
  else
    { tileEmpty — draw nothing }
end;
```

---

## 11. Boolean expressions

- Never compare a Boolean to `True` or `False`
- Use `not` for negation

```pascal
{ Good }
if isAlive then ...
if not hasKey then ...

{ Bad }
if isAlive = True then ...
if hasKey = False then ...
```

---

## References

- Borland International, *Turbo Pascal 7.0 Language Guide*, 1992.
- Borland International, *Turbo Pascal 7.0 Programmer's Guide*, 1992.
