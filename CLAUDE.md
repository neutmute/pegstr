# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Pegstr** (Pegboard Wizard) is a parametric 3D model generator built with OpenSCAD. It creates custom pegboard mounts, holders, and bins for US-style pegboards (1/4" holes, 1" / 25mm spacing). Licensed CC-NC.

## Build & Export

Requires OpenSCAD (nightly recommended). Geometry validation uses the headless `--summary` flag (see Render Validation below) — this is the unit test. Visual validation via the OpenSCAD GUI is optional.

**Render a single design to STL:**
```bash
openscad-nightly pegstr.scad --backend Manifold -p pegstr.json -P "parameter-set-name" -o output.stl
```

**Batch export (example):**
```bash
bash scripts/nut-drivers-wiha-export.sh
```

**Interactive design:** Open `pegstr.scad` in OpenSCAD GUI, select a parameter set from the Customizer panel.

### Render Validation (headless unit test)

**MANDATORY: Run this for every new or modified preset/override before declaring work complete.** Do not report done until all four assertions below pass.

OpenSCAD nightly supports `--summary all --summary-file -` which outputs a JSON geometry report to stdout. Use this as a lightweight sanity check — it runs in ~50–100ms and catches geometry regressions without a GUI.

**For standard presets** (no override), run directly:
```bash
"/c/Program Files/OpenSCAD (Nightly)/openscad.exe" pegstr.scad --backend Manifold \
  -p pegstr.json -P "parameter-set-name" \
  --render --summary all --summary-file - -o output.stl 2>&1; echo "EXIT:$?"
```

**For overrides**, temporarily edit `pegstr.scad` using the Edit tool (exact string match), run the test, then revert with another Edit call:

Step 1 — edit (comment out `pegstr();`, add the include):
```
old: pegstr();
new: //pegstr();
     include <overrides/your-override.scad>
```

Step 2 — run the geometry check:
```bash
"/c/Program Files/OpenSCAD (Nightly)/openscad.exe" pegstr.scad --backend Manifold \
  -p pegstr.json -P "parameter-set-name" \
  --render --summary all --summary-file - -o output.stl 2>&1; echo "EXIT:$?"
```

Step 3 — revert (undo the edit from step 1). Use the exact same Edit tool call in reverse.

> Use the Edit tool for steps 1 and 3 — not shell sed or PowerShell regex. Exact string matching is reliable; regex patching of SCAD files is fragile.

Visual image output — always write to `demo-images/`:
```bash
"C:\Program Files\OpenSCAD (Nightly)\openscad.exe" pegstr.scad --backend Manifold \
  -p pegstr.json -P "parameter-set-name" \
  --render --camera=40,27,35,55,0,25,200 -o demo-images/preset-name-top.png

"C:\Program Files\OpenSCAD (Nightly)\openscad.exe" pegstr.scad --backend Manifold \
  -p pegstr.json -P "parameter-set-name" \
  --render --camera=40,27,60,0,0,0,200 -o demo-images/preset-name-overhead.png
```

The two camera presets give a **top-diagonal** view (good for seeing hole geometry) and an **overhead** view (good for confirming through-holes). Adjust the first three `--camera` values to re-centre if the model is off-screen.

**Summary JSON output fields:**
```json
{
  "geometry": {
    "bounding_box": {
      "min": [x, y, z],
      "max": [x, y, z],
      "size": [width, depth, height]
    },
    "dimensions": 3,
    "facets": 2434,
    "simple": true,
    "vertices": 1219
  }
}
```

**Key assertions to make after any geometry change:**

| Check | Command | Catches |
|---|---|---|
| No SCAD errors | Exit code == 0 | Syntax errors, broken boolean ops |
| Manifold geometry | `simple == true` | Non-printable geometry |
| Non-trivial geometry | `vertices > 500` | Holder body completely removed by cuts |
| Expected height | `size[2] ≈ tz` | Wrong `holder_z_size` (too small = flatten eats the body) |

**Reading the output:** The summary JSON is the last `{...}` block in the output (after the `ECHO:` lines). Check the four assertions manually from the raw output — `python3` is not available in this Windows environment.

**Known geometry values for reference** (update when parameters change):

| Preset | Expected Z (tz) | Min vertices |
|---|---|---|
| `garden-shears` | ~34.8mm | 500 |
| `drill-bits-large` | ~58.35mm | 7000 |

> **Key lesson:** `holder_z_size` must be large enough that `tz` leaves sufficient holder body after `flatten_top` clips at `tz`. The visible body height = `tz - (tz - holder_z_size_actual/2)` = `holder_z_size_actual/2`. All existing bin presets use `holder_z_size` ≥ 50mm. With `holder_z_size = 30` and `slot_z = 20`, flatten consumed the entire body.

> **Key lesson (override world-space coordinates):** Use the `allen-keys.scad` pattern for placing geometry alongside `pegstr()`. Cell centres in world space: `cx = wall_thickness + col*(wall_thickness + holder_x_size_actual) + holder_x_size_actual/2`, `cy = wall_thickness + row*(wall_thickness + holder_y_size) + holder_y_size/2`, `cz = tz - holder_z_size_actual/2`. Fill cylinders centred there span exactly the holder body (tz-holder_z_size_actual to tz). Holes cut from tz downward: `translate([cx, cy, tz - l/2]) cylinder(h=l, ...)`. The old `drill-bits.scad` formula (`-holder_offset - holder_y_size/2 - ...`) uses the wrong axis convention and places fills outside the holder body — do not use it as a reference.

## Architecture

### Core Files

- **`pegstr.scad`** — Main parametric model. All geometry flows from `pegstr()` → `build()` → `holder()` / `pinboard()` / `pin()`. The `flatten()` module applies final boolean operations (difference/intersection/union) to prepare geometry for clean STL export.
- **`pegstr.json`** — Database of ~50+ named parameter presets (e.g., `acetone-holder`, `caliper4`, `drill-bits`). Each preset is ~30+ key/value pairs under `parameterSets.{name}`.
- **`lib/bins.scad`** — Reusable `bin_interior` / `bin_height` modules for tray designs.
- **`overrides/*.scad`** — Per-item specializations that import custom geometry, STL tool models (e.g., `v6_large.stl`), and perform additional boolean ops on top of the base holder.

### Parameter System

Parameters are grouped into:
- **Size**: `holder_x_size`, `holder_y_size`, `holder_z_size`, `holder_x_count`, `holder_y_count`
- **Shape**: `corner_radius`, `wall_thickness`, `taper_ratio_x/y`, `holder_angle`, `closed_bottom`
- **Pins**: `hole_size`, `hook_size`, `hole_spacing` (25mm standard), `board_thickness`
- **Quantization**: `quantized_x_size`, `quantized_z_size` — auto-snap dimensions to pegboard grid
- **Render**: `$fn`, `holder_sides_fn` (set to 200 for quality), `flatten_method`, `flatten_top/bottom/sides/front`

Parameters suffixed `_actual` are computed values derived from user inputs.

### Override Pattern

Overrides in `overrides/*.scad` follow the pattern of loading the base `pegstr.scad` with specific parameters, then adding or subtracting custom geometry (often imported STL models of real tools) to create a precise-fit holder.

**Overrides are not standalone files.** They must be rendered by temporarily editing `pegstr.scad`. Always use the Edit tool for this — do not use shell regex or PowerShell string replacement, which is fragile:
1. Edit tool: comment out `pegstr();` (line ~601) and add `include <overrides/your-override.scad>` on the next line
2. Run the geometry unit test (see Render Validation above) — all four assertions must pass
3. Edit tool: revert step 1 exactly

`lib/bins.scad` only defines helper modules (`bin_interior`, `bin_height`) — it does **not** include `pegstr.scad`. Overrides that include `lib/bins.scad` rely on `pegstr.scad` already being in scope (i.e., the override is included from `pegstr.scad`).

### pegstr() Coordinate System

`pegstr()` internally applies `rotate([0,0,-90])` then `translate([tx/2, 0, tz-clip_height/2])` to all geometry. Any geometry placed in a `union()` or `difference()` alongside `pegstr()` must use **world-space coordinates**, computed as:

```
world X = build Y + tx/2           // horizontal left-right
world Y = -build X                 // depth (wall → front)
world Z = build Z + (tz - clip_height/2)
```

Key world-space interior bounds (for a standard upright holder, `holder_angle=0`, `holder_offset=0`):

| Bound | Formula |
|---|---|
| Interior left X | `tx/2 - holder_x_size_actual/2` |
| Interior right X | `tx/2 + holder_x_size_actual/2` |
| Interior depth centre Y | `wall_thickness + holder_y_size/2` |
| Interior floor Z | `tz - holder_z_size_actual + closed_bottom*wall_thickness` |
| Interior top Z | `tz` |

Using build-space coordinates for `union()`/`difference()` children of `pegstr()` will place geometry far outside the holder.

## Code Conventions

- `.editorconfig`: LF line endings, 4-space indent for JSON, UTF-8
- `epsilon` variable used throughout to prevent Z-fighting in boolean ops
- `echo()` statements log computed parameters to console for debugging
- `render()` calls wrap expensive geometry for OpenSCAD performance
- Color assignments (`red`, `green`, etc.) are visualization aids only — not meaningful in exported STL

## Print Notes

See `print-notes.md` for tolerance and material guidance specific to FDM printing.
