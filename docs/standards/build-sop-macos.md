# Build SOP — macOS (DOSBox + Turbo Pascal 7)

## Purpose

Step-by-step procedure for compiling and running Turbo Pascal 7 source on macOS
using DOSBox. Follow this every time — do not rely on memory.

---

## Prerequisites

| Item | Location on host |
| --- | --- |
| TP7 installation | `~/Downloads/turbo_pascal_701_fr/` |
| DOSBox application | `/Applications/dosbox.app/` |
| DOSBox binary | `/Applications/dosbox.app/Contents/MacOS/DOSBox` |

`dosbox` is **not** on the system PATH. Always use the full binary path.

### TP7 installation layout

```
~/Downloads/turbo_pascal_701_fr/
  BIN/
    TPC.EXE        ← command-line compiler
    TURBO.TPL      ← standard library (System, Crt, Dos — no separate .TPU needed)
    TPC.CFG        ← contains /UD:\TP\UNITS — ignore, override at command line
  UNITS/
    STRINGS.TPU, OBJECTS.TPU, GRAPH.TPU, etc.  ← extended units
```

`CRT`, `System`, and `Dos` are compiled into `TURBO.TPL` in `BIN/`. TPC finds
`TURBO.TPL` automatically from its own directory — no flag needed.

---

## Drive mapping convention

| DOS drive | Host path | Contents |
| --- | --- | --- |
| `C:` | `~/Downloads/turbo_pascal_701_fr` | TP7 compiler and units |
| `D:` | `<project-root>` | Source files and build output |

`<project-root>` is the directory containing the `.PAS` source files being compiled.

---

## Step 1 — Create the build output directory

```bash
mkdir -p <project-root>/build
```

TPC will fail silently if the output directory does not exist.

---

## Step 2 — Write a DOSBox config

Create `<project-root>/dosbox-build.conf`:

```ini
[sdl]
fullscreen=false
autolock=false

[dosbox]
memsize=16

[cpu]
cycles=max

[autoexec]
mount c /Users/johannes/Downloads/turbo_pascal_701_fr
mount d <absolute-host-path-to-project-root>
c:
set PATH=%PATH%;C:\BIN
md D:\BUILD
TPC.EXE D:\<ENTRYPOINT>.PAS /UD:\;C:\UNITS /B /OD:\BUILD\ > D:\BUILD\BUILD.LOG
exit
```

Replace `<absolute-host-path-to-project-root>` and `<ENTRYPOINT>` for each project.

**TPC flags:**

| Flag | Meaning |
| --- | --- |
| `/UD:\;C:\UNITS` | Unit search path: project root first, then TP7 extended units |
| `/B` | Batch mode — non-interactive, exits on completion |
| `/OD:\BUILD\` | Write EXE, TPU, MAP output to `D:\BUILD\` |

The `md D:\BUILD` line ensures the output directory exists — TPC drops output
silently to the source root if the `/O` directory is missing.

The `> D:\BUILD\BUILD.LOG` redirect captures compiler output so it can be read
on the host after DOSBox closes.

The original `TPC.CFG` hard-codes `/UD:\TP\UNITS` (a phantom DOS path). The `/U`
flag on the command line **overrides** it entirely — no need to edit `TPC.CFG`.

---

## Step 3 — Compile

```bash
/Applications/dosbox.app/Contents/MacOS/DOSBox \
  -conf <project-root>/dosbox-build.conf 2>/dev/null &
```

Run in the background (`&`) so the shell does not block. DOSBox runs the
`[autoexec]` block, compiles, writes `BUILD.LOG`, and exits (via the `exit` line).

**Do not use `open -a dosbox` for the build** — the build config exits immediately
after compiling, which confuses the macOS app lifecycle. The direct binary invocation
works fine for headless batch builds.

After DOSBox exits, read the log:

```bash
cat <project-root>/build/BUILD.LOG
```

### Verify EXE location

The `md D:\BUILD` line in `[autoexec]` creates the output directory inside DOSBox.
**Always verify where the EXE actually landed** — if `BUILD\` was not created
successfully, TPC silently drops the EXE in the source root instead:

```bash
# Check expected location first
ls <project-root>/build/*.EXE

# If missing, check source root
ls <project-root>/*.EXE
```

If the EXE is in the source root, move it:

```bash
mv <project-root>/<ENTRYPOINT>.EXE <project-root>/build/
```

---

## Step 4 — Check the build

On the host, verify:

```bash
ls -lh <project-root>/build/*.EXE   # must exist and be non-zero
```

A successful TP7 compile prints:

```
Turbo Pascal Version 7.0 ...
<filename>.PAS(n): ...
  0 errors, 0 warnings
```

Any line containing `Error` or `Warning` means the build failed. Do not commit
`Build: passed` unless the output is clean.

---

## Step 5 — Run the game

Create a second config (or reuse the same one without `exit`) to launch the EXE:

```ini
[autoexec]
mount c /Users/johannes/Downloads/turbo_pascal_701_fr
mount d <absolute-host-path-to-project-root>
D:\BUILD\<ENTRYPOINT>.EXE
```

Launch with:

```bash
/Applications/dosbox.app/Contents/MacOS/DOSBox \
  -conf <project-root>/dosbox-run.conf
```

---

## Worked example — spike/001-informed-vibe-code

| Variable | Value |
| --- | --- |
| Project root (host) | `/Users/johannes/code/retro/retro-game-stream/spikes/001-informed-vibe-code` |
| Entry point | `CORPLADR.PAS` |
| Output EXE | `spikes/001-informed-vibe-code/build/CORPLADR.EXE` |

`dosbox-build.conf` `[autoexec]`:

```dos
mount c /Users/johannes/Downloads/turbo_pascal_701_fr
mount d /Users/johannes/code/retro/retro-game-stream/spikes/001-informed-vibe-code
c:
set PATH=%PATH%;C:\BIN
md D:\BUILD
TPC.EXE D:\CORPLADR.PAS /UD:\;C:\UNITS /B /OD:\BUILD\ > D:\BUILD\BUILD.LOG
exit
```

`dosbox-run.conf` `[autoexec]`:

```dos
mount c /Users/johannes/Downloads/turbo_pascal_701_fr
mount d /Users/johannes/code/retro/retro-game-stream/spikes/001-informed-vibe-code
D:\BUILD\CORPLADR.EXE
```

---

## Multi-file projects (units)

When the program uses `unit` files (e.g. `WORLD.PAS`, `PLAYER.PAS`), TPC compiles
the program unit listed on the command line and resolves `uses` clauses from the
unit search path. Because `D:\` (the project root) is first in `/UD:\;C:\UNITS`,
all local units are found automatically — no need to list them individually.

TPC compiles units on demand and caches `.TPU` files in the output directory
(`/OD:\BUILD\`). On a clean build, delete `BUILD\*.TPU` first.

---

## TP7 language constraints (confirmed from spike)

These are **not** bugs in the code — they are TP7 language rules that differ from
Delphi and modern Pascal. Violating any of these produces `Error 3: Unknown identifier`.

| Rule | Detail |
| --- | --- |
| Unit name must match filename | `unit Player` → file must be `PLAYER.PAS`. TPC looks up units by filename, not by the `unit` keyword. |
| Unit name clashing with an exported variable | If `World` exports `var Player: TPlayer` and you `uses Player` (a unit), TP7 resolves bare `Player` as the unit identifier. Qualify all variable references as `World.Player.*` inside any unit that also `uses Player`. |
| `CursorOff` / `CursorOn` do not exist | These are Delphi additions. Remove them or use a direct BIOS call via `Mem[$40:$60]`. |
| Unit-qualified function calls not supported | `World.TileAt(x, y)` is invalid syntax. Just call `TileAt(x, y)` — it is in scope via `uses World`. Unit qualification works only for variables, not procedure/function calls. |

---

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| `Unit not found: CRT` | `TURBO.TPL` not found by TPC | Ensure TPC is invoked from `C:\` where `BIN\TURBO.TPL` lives (the `c:` line in `[autoexec]` handles this) |
| `Unit not found: WORLD` | Unit file not in search path | Confirm `D:\` is first in `/U` flag |
| EXE missing after compile — lands in source root | `BUILD\` directory did not exist when TPC ran | The `md D:\BUILD` line in `[autoexec]` prevents this; `md` on an existing directory is a no-op in DOS |
| DOSBox window closes instantly before log is written | `exit` fires before TPC finishes | Remove `exit` from `[autoexec]` temporarily to confirm |
| `Error 2` on TPC | File not found — wrong path or filename | DOS filenames are uppercase; check mount point and path |
| `Error 3: Unknown identifier` on a unit name | Unit name / filename mismatch, or unit name clashes with a global variable | See TP7 language constraints table above |

---

## .gitignore additions needed

```
spikes/*/build/*.EXE
spikes/*/build/*.TPU
spikes/*/build/*.MAP
spikes/*/build/*.OBJ
spikes/*/build/*.BAK
```

Build logs (`build.log`, `build-manifest.txt`) are committed as evidence.
