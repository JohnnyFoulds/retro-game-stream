# Unit Testing for Turbo Pascal 7 — Research Report

**Date:** 2026-07-06
**Status:** Research complete — design decision pending

---

## Executive summary

Unit testing in Turbo Pascal 7 is constrained by the absence of exceptions, RTTI, generics, and the modern `class` keyword. Every mainstream Pascal testing framework (DUnit, DUnitX, FPCUnit, FPTest, pascal-tap) is architecturally incompatible with TP7. The sole framework with confirmed, tested TP7 support — **tap4pascal** — is abandoned (2010) but demonstrates the right pattern: procedural-type registration arrays producing **TAP** (Test Anything Protocol) plain-text output.

A hand-rolled `TPTEST.PAS` unit, built on the same principles, can achieve all the practically useful pytest features within TP7's constraints. VS Code Testing tab integration is feasible via a TAP-to-VS Code bridge script, with no changes required to the TP7 runner itself.

**Recommendation:** Build a project-specific `TPTEST.PAS` unit. Do not attempt to port or use any existing framework. See §7.

---

## 1. Historical context: testing in the TP7 era

In the Turbo Pascal 7 era (released 1992), no testing framework existed for Pascal. The dominant practice in commercial and educational Pascal development was:

- **Assertion procedures**: hand-written `Assert(condition, message)` wrappers that call `Halt` on failure. These appear in Borland's own examples and in period textbooks.
- **Driver programs**: a separate `TEST.PAS` program (not a unit) that calls procedures under test and `WriteLn`s PASS or FAIL. Each test was written as an explicit `if/then/WriteLn` block.
- **Interactive testing**: running the program in the Turbo Pascal IDE debugger and inspecting variables in the watch window.

None of these constitute a framework. There was no concept of test isolation, test registration, or structured output in the period literature. The xUnit family (SUnit, JUnit) did not appear until 1994–1998 — after TP7.

---

## 2. The mainstream Pascal testing landscape

### 2.1 DUnit (Delphi)

**Origin:** Port of JUnit to Delphi, first released around 1999–2002.
**Requirements:** Delphi 5 or later; `class` keyword; `try`/`except`/`raise`; VCL or console runner.
**How it works:** Test classes inherit from `TTestCase`. Test methods are discovered automatically via Delphi's RTTI (`published` methods). Each test method runs inside a `try/except` block; a raised `ETestFailure` is caught and recorded as a failure; any other exception is recorded as an error. Results are reported via a GUI or console runner.
**TP7 compatibility:** None. Requires `class`, `published`, `try/except`, and RTTI — all absent in TP7.

### 2.2 DUnitX (Delphi 2010+)

**Requirements:** Delphi 2010 or later; custom attributes (`[Test]`); enhanced RTTI (`System.Rtti`); generics.
**TP7 compatibility:** None whatsoever. Requires language features that arrived ~18 years after TP7.

### 2.3 FPCUnit (Free Pascal Compiler built-in)

**Origin:** Modelled after DUnit/JUnit/SUnit. Included with FPC since approximately FPC 2.0.
**How it works:** Tests inherit from `TTestCase`. Test methods are `published` procedures discovered via FPC's RTTI. On assertion failure, `EAssertionFailedError` is raised and caught by the runner — execution of that test stops at the first failure. A separate `TTestRunner` walks the registered test suites.
**TP7 compatibility:** None. Requires `class` with `published` methods, exceptions, and FPC-specific RTTI. The `{$mode objfpc}` directive required in most FPCUnit examples has no TP7 equivalent.

### 2.4 FPTest (FPC)

**Origin:** Fork of DUnit2 for Free Pascal.
**How it works:** Uses RTTI-based `published` method discovery. Requires `{$mode delphi}` or `{$mode objfpc}`, FPC `class` keyword, and exceptions.
**TP7 compatibility:** None. The `{$IFDEF FPC}` blocks in its source are the first hint; the RTTI dependency is the definitive blocker.

### 2.5 pascal-tap (FPC)

**Repository:** github.com/bbrtj/pascal-tap
**How it works:** Produces TAP output. Uses FPC generics (`fgl` unit), `{$mode objfpc}`, and exception classes (`EBailout = class(Exception)`).
**TP7 compatibility:** None. Uses multiple FPC-only language features in every source file.

### 2.6 tap4pascal (SourceForge — abandoned 2010)

**Repository:** sourceforge.net/projects/tap4pascal
**Last release:** 2010-09-15. Status: Abandoned.
**How it works:** Produces TAP-compliant plain-text output. Uses `{$IFDEF VER70}` conditional compilation to handle TP7-specific type gaps (e.g. `LongWord` aliased to `LongInt`). Ships a `Makefile.tp` for TP7's `MAKE.EXE`. Author documented: *"Has been tested under: Turbo Pascal 7 under DOS (yes, THAT DOS)."*
**TP7 compatibility:** Confirmed. This is the only framework in the Pascal ecosystem with a documented, tested TP7 success.

**Summary table:**

| Framework | Language target | TP7 compatible? | Key blocker |
| --- | --- | --- | --- |
| DUnit | Delphi 5–2006 | No | `class`, `published`, exceptions |
| DUnitX | Delphi 2010+ | No | Attributes, enhanced RTTI, generics |
| FPCUnit | FPC | No | `class`, `published`, exceptions |
| FPTest | FPC | No | RTTI, `{$mode}` directives |
| pascal-tap | FPC | No | Generics, exceptions, `{$mode objfpc}` |
| tap4pascal | TP7 + FPC | **Yes** | None — designed for TP7 |

---

## 3. TP7's constraints and their testing implications

Understanding exactly what TP7 lacks is essential to designing a viable test framework.

### 3.1 No exceptions

TP7 has no `try`, `except`, `raise`, or `finally`. Runtime errors (array bounds violations, stack overflow) cause the program to halt immediately with a runtime error number and address. There is no mechanism to catch a runtime error and continue.

**Testing implication:** The JUnit pattern — `assert` raises an exception, the runner catches it, records a failure, and continues to the next test — is impossible in TP7. Failure must be signalled through a return value or a global flag, and the runner must check this flag after each test call and decide whether to continue.

### 3.2 No RTTI or published methods

TP7's `object` keyword (from TP 5.5) has `private` and `public` visibility only — no `published` section. There is no runtime type information system. Method names cannot be enumerated at runtime.

**Testing implication:** Auto-discovery of test methods (the mechanism used by every JUnit-descended framework) is impossible. Tests must be explicitly registered by the programmer. This is a real ergonomic cost but is unavoidable.

### 3.3 No class keyword

TP7 has the `object` type (object-oriented Pascal, TP 5.5 style) but not the Delphi/Java/C# `class` type. Object instances are stack-allocated (no implicit reference semantics). Virtual methods require explicit `virtual` declarations and a `constructor` to initialise the VMT.

**Testing implication:** The TTestCase inheritance pattern is possible using `object` but adds complexity. The simpler and more appropriate approach is plain procedure registration — no inheritance hierarchy needed.

### 3.4 Procedural types are available

TP7 *does* have procedural types (procedure variables). A variable of a procedural type can hold `nil`, or the address of any global procedure with a matching signature. The `@` address operator is not required in TP7 mode (unlike FPC default mode).

```pascal
type
  TTestProc = procedure;

var
  myTest : TTestProc;
begin
  myTest := SomeTestProcedure;  { assignment without @ in TP7 mode }
  myTest;                        { call via variable }
end;
```

**Testing implication:** A registration array of `(name: String; proc: TTestProc)` records is viable. This is the foundation of any TP7-compatible test runner.

### 3.5 No generics

**Testing implication:** Assertion helpers must be written for each type: `AssertTrue`, `AssertEqual` (Integer), `AssertEqualStr`, `AssertEqualChar`, etc. No generic `Assert<T>`. This is a moderate ergonomic cost.

### 3.6 DOS real mode, 640 KB limit

TP7 targets 16-bit real mode DOS. A large test suite that loads much game state could approach memory limits.

**Testing implication:** Keep the test binary separate from the game binary. `TEST.EXE` compiles only the units under test plus the test runner — not the full game program.

---

## 4. TAP: Test Anything Protocol

TAP is the right output format for a TP7 test runner. It was designed to be producible by any language — even `sh` — and consumable by any tool.

### 4.1 Format

A TAP stream consists of:

1. A **plan line** at the beginning (or end, never middle): `1..N` — declares the total number of tests
2. One **result line** per test: `ok N description` or `not ok N description`
3. Optional **diagnostic lines**: `# anything` — ignored by parsers but displayed to humans

Complete example:

```
1..5
ok 1 world initialises to correct dimensions
ok 2 player starts at spawn position
not ok 3 player collects dollar sign
# expected score=1, got score=0
ok 4 player cannot walk through wall
ok 5 enemy moves left when direction is left
```

### 4.2 Why TAP is ideal for TP7

- **Zero dependencies.** Valid TAP is produced entirely with `WriteLn`.
- **Language-agnostic consumers.** Any tool that reads TAP can process the output — shell scripts, Node.js, Python, CI systems.
- **Standard exit code convention.** Exit 0 = all tests passed; non-zero = failures exist. This integrates with `make test`.
- **Parseable by VS Code adapters.** TAP consumers exist for VS Code (see §6).

### 4.3 tap4pascal as reference

tap4pascal's `TAP.pas` unit (available on SourceForge) demonstrates the TP7-compatible TAP approach. Key observations from its source:

- Uses `{$IFDEF VER70}` to handle TP7 type differences
- Uses procedural types for test registration
- Emits TAP lines via `WriteLn`
- No exceptions, no RTTI, no `class`

Its API is more complex than necessary for a course project. The design of `TPTEST.PAS` (see §7) simplifies it considerably.

---

## 5. Achievable pytest-equivalent features in TP7

| pytest feature | Achievable in TP7? | Mechanism |
| --- | --- | --- |
| Named test output (`PASSED test_name`) | **Yes** | `ok N name` in TAP output |
| Pass/fail per test | **Yes** | `ok` / `not ok` lines |
| Summary count (N passed, M failed) | **Yes** | Count during runner loop; `WriteLn` at end |
| Continue after individual test failure | **Yes** | Global `testFailed` flag; runner checks after each call |
| Failure message / description | **Yes** | TAP diagnostic lines (`# expected X got Y`) |
| Setup / teardown | **Yes** | Explicit `SetUp`/`TearDown` procedures called by runner |
| Auto-discovery of test procedures | **No** | Must register explicitly — no RTTI |
| Parameterised tests | **Partial** | Manual loop over a data array; registerable |
| Nested test suites / grouping | **Partial** | Naming convention (`GroupName_TestName`); TAP has no native grouping |
| Exception testing (`with pytest.raises`) | **No** | No exceptions in TP7 |
| Fixtures / dependency injection | **No** | Use global state or explicit parameters instead |

The two hard losses — auto-discovery and exception testing — are unavoidable. Everything else is achievable. For a course project testing a DOS game, neither loss is significant: the test suite is small enough that explicit registration is no burden, and the game code uses boolean return codes rather than exceptions anyway.

---

## 6. VS Code Testing tab integration

### 6.1 Current state

No Pascal or TP7-specific VS Code test adapter exists as of the research date. The VS Code Testing API requires a test adapter extension that:

1. Discovers test items (populates the Testing sidebar tree)
2. Runs tests and reports results back to VS Code
3. Optionally supports debugging and per-line annotations

### 6.2 TAP bridge approach

TAP output from a TP7 test binary can be bridged to VS Code via a small Node.js or Python script acting as a VS Code test adapter:

```
make test
  → runs TEST.EXE under DOSBox / js-dos
  → TEST.EXE writes TAP to stdout
  → stdout captured by the Makefile
  → Node.js TAP parser reads stdout
  → Reports pass/fail to VS Code Testing API
```

The TAP parsing layer is trivial — the format is simple enough to parse with a 20-line script. The harder part is the VS Code extension boilerplate for a custom test adapter.

### 6.3 Practical recommendation for the course

For the course context, the VS Code Testing tab integration is **optional and deferred**. The primary test workflow is:

1. `make test` in the terminal — exits 0 on all pass, non-zero on any failure
2. TAP output readable directly in the terminal
3. CI/build system can parse exit code

A future enhancement could add a VS Code extension, but this is not blocking for the course day.

### 6.4 Generic TAP consumers in VS Code

The extension **Test Explorer UI** (by Holger Benl, widely used) supports generic test adapters. A custom adapter implementing its API could parse TAP output from any process. Several TAP-consuming adapters already exist for Node.js, Perl, and Python tests within this framework — the Pascal case would require a new adapter but no new concept.

---

## 7. Recommended design: TPTEST.PAS

Based on the research findings, the recommended approach is a project-specific `TPTEST.PAS` unit. This section outlines the design; a formal standard document and implementation follow separately.

### 7.1 Core design

```pascal
unit TPTEST;

{ Minimal TAP-producing test runner for Turbo Pascal 7.
  Provides test registration, pass/fail tracking, assertion helpers,
  and TAP output. Compatible with TP7 real-mode DOS. }

interface

const
  MAX_TESTS = 64;

type
  TTestProc = procedure;

{ Register a test procedure with a name. Call once per test before RunTests. }
procedure RegisterTest(const name: String; proc: TTestProc);

{ Run all registered tests. Emits TAP to stdout. Returns number of failures. }
function RunTests: Integer;

{ Assertion helpers — call from inside a test procedure }
procedure AssertTrue(const desc: String; condition: Boolean);
procedure AssertFalse(const desc: String; condition: Boolean);
procedure AssertEqualInt(const desc: String; expected, actual: Integer);
procedure AssertEqualStr(const desc: String; const expected, actual: String);
procedure AssertEqualChar(const desc: String; expected, actual: Char);
procedure Fail(const desc: String);
```

### 7.2 Test isolation without exceptions

Since TP7 has no exceptions, isolation is achieved via a global failure flag:

```pascal
{ Inside TPTEST implementation }
var
  currentTestFailed : Boolean;

procedure AssertTrue(const desc: String; condition: Boolean);
begin
  if not condition then
  begin
    WriteLn('# FAIL: ', desc);
    currentTestFailed := True;
    { Cannot raise — mark flag and return; runner checks after the call }
  end;
end;
```

The runner resets `currentTestFailed := False` before each test call, calls the test, then checks the flag:

```pascal
{ Runner loop (simplified) }
for i := 1 to testCount do
begin
  currentTestFailed := False;
  tests[i].proc;   { call the test procedure }
  if currentTestFailed then
  begin
    WriteLn('not ok ', i, ' ', tests[i].name);
    Inc(failCount);
  end
  else
    WriteLn('ok ', i, ' ', tests[i].name);
end;
```

This gives complete isolation: one failing assertion marks the test as failed but does not halt the runner or affect subsequent tests.

### 7.3 Usage pattern

A test file (`TEST.PAS`) looks like this:

```pascal
program TEST;

uses TPTEST, WORLD, PLAYER;

{ --- Test procedures --- }

procedure Test_WorldInitialisesToEmptyTiles;
var
  W : TWorld;
begin
  InitWorld(W);
  AssertEqualInt('world width',  40, W.Width);
  AssertEqualInt('world height', 20, W.Height);
  AssertTrue('tile[0][0] is empty', W.Tiles[0][0] = tileEmpty);
end;

procedure Test_PlayerStartsAtSpawnPosition;
var
  P : TPlayer;
begin
  InitPlayer(P, 5, 10);
  AssertEqualInt('player X', 5, P.X);
  AssertEqualInt('player Y', 10, P.Y);
  AssertTrue('player alive', P.isAlive);
end;

procedure Test_CollectDollarIncreasesScore;
var
  W     : TWorld;
  score : Integer;
  msg   : String;
begin
  InitWorld(W);
  W.Tiles[3][5] := tileDollar;
  score := 0;
  AssertTrue('collect succeeds',
    CollectDollar(W, 5, 3, score, msg));
  AssertEqualInt('score incremented', 1, score);
  AssertTrue('tile replaced', W.Tiles[3][5] = tileEmpty);
end;

{ --- Main --- }

begin
  RegisterTest('world initialises to empty tiles',
               Test_WorldInitialisesToEmptyTiles);
  RegisterTest('player starts at spawn position',
               Test_PlayerStartsAtSpawnPosition);
  RegisterTest('collect dollar increases score',
               Test_CollectDollarIncreasesScore);

  if RunTests > 0 then Halt(1);
end.
```

Output:

```
1..3
ok 1 world initialises to empty tiles
ok 2 player starts at spawn position
not ok 3 collect dollar increases score
# FAIL: collect succeeds: expected True got False
# 1 failed of 3
```

### 7.4 Comparison with pytest

```python
# pytest
def test_collect_dollar_increases_score():
    world = World()
    world.set_tile(5, 3, DOLLAR)
    score = collect_dollar(world, 5, 3, score=0)
    assert score == 1
    assert world.get_tile(5, 3) == EMPTY
```

```pascal
{ TPTEST equivalent }
procedure Test_CollectDollarIncreasesScore;
var W: TWorld; score: Integer; msg: String;
begin
  InitWorld(W);
  W.Tiles[3][5] := tileDollar;
  score := 0;
  AssertTrue('collect succeeds', CollectDollar(W, 5, 3, score, msg));
  AssertEqualInt('score', 1, score);
  AssertTrue('tile cleared', W.Tiles[3][5] = tileEmpty);
end;
```

The verbosity gap is real (explicit `var` block, `InitWorld` call, message strings on every assertion) but the *discipline* is identical: set up state, call the function under test, assert postconditions.

---

## 8. What to test: unit vs acceptance

The course uses two complementary test types:

| Type | File | What it tests | When it runs |
| --- | --- | --- | --- |
| **Unit tests** (`TPTEST.PAS`) | `tests/TEST.PAS` | Individual procedures in isolation — pure logic, no screen output | `make test` — automated, every commit |
| **Manual acceptance tests** | `tests/manual-acceptance-tests.md` | Observable game behaviour — player moves, enemies chase, score displays | Manually, before every commit that closes a requirement |

Unit tests are appropriate for:
- Pure logic procedures: `CollectDollar`, `ValidateMove`, `UpdateEnemy`
- Data initialisation: `InitWorld`, `InitPlayer`
- Tile queries: `IsTilePassable`, `TileChar`

Unit tests are **not** appropriate for:
- Rendering procedures (`DrawWorld`, `DrawPlayer`) — screen output cannot be asserted programmatically in TP7
- Input handling (`ReadKey`, `GetDirection`) — requires interactive keyboard
- Full game-loop integration — tested by manual acceptance tests

---

## 9. Key decisions for the standards document

The following decisions need to be made (or recommended) in the subsequent standards document:

| Decision | Recommended choice | Rationale |
| --- | --- | --- |
| Framework | Hand-rolled `TPTEST.PAS` | Only viable option; tap4pascal is abandoned and over-engineered for this scope |
| Output format | TAP | Standard, parseable, trivially producible, future VS Code bridge-ready |
| Test file name | `TEST.PAS` (program, not unit) | Keeps test binary separate; DOS 8.3 filename |
| Test procedure naming | `Test_UnitName_What` | Readable in TAP output; groups by unit under test |
| Failure isolation | Global flag pattern | Only viable pattern without exceptions |
| Assertion messages | Mandatory on every assertion | Makes TAP diagnostic output self-describing |
| Test registration | Explicit `RegisterTest` calls | No RTTI auto-discovery possible |
| `make test` exit code | Non-zero on any failure | Integrates with CI and build tooling |
| VS Code integration | Deferred | Not blocking; TAP output suffices for terminal workflow |

---

## 10. Sources and confidence

All findings are based on multi-source verification (3-agent adversarial verification per claim). Two claims were **refuted** during verification:

1. *"FPCUnit requires tests to be written as published methods"* — partially incorrect: FPCUnit's runner uses `published` for auto-discovery but tests can also be registered manually. This does not affect TP7 compatibility (exceptions and `class` are still blockers).

2. *"FPTest uses the `{$mode objfpc}{$H+}` compiler directive in all source files"* — partially incorrect: FPTest supports `{$mode delphi}` as well. Again does not affect TP7 compatibility.

| Claim | Confidence |
| --- | --- |
| tap4pascal is the only TP7-compatible Pascal test framework | High |
| TAP is trivially producible from TP7 with WriteLn | High |
| DUnit, FPCUnit, FPTest, DUnitX, pascal-tap are incompatible with TP7 | High |
| TP7's core constraints (no exceptions, no RTTI, no class) | High |
| A procedural-type registration array achieves near-pytest ergonomics | Medium |
| No VS Code TAP adapter for Pascal exists | Medium |

---

## References

- tap4pascal, SourceForge: https://sourceforge.net/projects/tap4pascal/
- TAP specification: https://testanything.org/tap-specification.html
- TAP producers list (confirms tap4pascal): https://testanything.org/producers.html
- DUnit: https://dunit.sourceforge.net/
- FPCUnit: https://wiki.freepascal.org/FPCUnit
- FPTest: https://wiki.freepascal.org/FPTest / https://github.com/graemeg/fptest
- DUnitX: https://github.com/VSoftTechnologies/DUnitX
- pascal-tap: https://github.com/bbrtj/pascal-tap
- Test Explorer UI (VS Code): https://marketplace.visualstudio.com/items?itemName=hbenl.vscode-test-explorer
- Borland International, *Turbo Pascal 7.0 Language Guide*, 1992
- 12 Factor App — Logs: https://12factor.net/logs
