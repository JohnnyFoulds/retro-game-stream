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
TPC.EXE D:\<ENTRYPOINT>.PAS /UD:\;C:\UNITS /B /OD:\BUILD\
exit
```

Replace `<absolute-host-path-to-project-root>` and `<ENTRYPOINT>` for each project.

**TPC flags:**

| Flag | Meaning |
| --- | --- |
| `/UD:\;C:\UNITS` | Unit search path: project root first, then TP7 extended units |
| `/B` | Batch mode — non-interactive, exits on completion |
| `/OD:\BUILD\` | Write EXE, TPU, MAP output to `D:\BUILD\` |

The original `TPC.CFG` hard-codes `/UD:\TP\UNITS` (a phantom DOS path). The `/U`
flag on the command line **overrides** it entirely — no need to edit `TPC.CFG`.

---

## Step 3 — Compile

```bash
/Applications/dosbox.app/Contents/MacOS/DOSBox \
  -conf <project-root>/dosbox-build.conf
```

A DOSBox window opens, runs the `[autoexec]` block, compiles, and exits. The
compiled `.EXE` lands at `<project-root>/build/<ENTRYPOINT>.EXE` on the host.

Compiler output is printed to the DOSBox window before it closes. To capture it,
remove the `exit` line from `[autoexec]` and read the terminal output manually,
or add a `> D:\BUILD\BUILD.LOG` redirect to the TPC line (TP7 batch mode supports
stdout redirect inside DOSBox).

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
TPC.EXE D:\CORPLADR.PAS /UD:\;C:\UNITS /B /OD:\BUILD\
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

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| `Unit not found: CRT` | `TURBO.TPL` not found by TPC | Ensure TPC is invoked from `C:\` where `BIN\TURBO.TPL` lives (the `c:` line in `[autoexec]` handles this) |
| `Unit not found: WORLD` | Unit file not in search path | Confirm `D:\` is first in `/U` flag |
| EXE missing after compile | `BUILD\` directory did not exist | Run `mkdir -p build` on host before launching DOSBox |
| DOSBox window closes instantly | `exit` line runs before output is visible | Remove `exit` from `[autoexec]` to inspect compiler output |
| `Error 2` on TPC | File not found — wrong path or filename | DOS filenames are uppercase; check mount point and path |

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
