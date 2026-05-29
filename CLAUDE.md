# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Pegstr** (Pegboard Wizard) is a parametric 3D model generator built with OpenSCAD. It creates custom pegboard mounts, holders, and bins for US-style pegboards (1/4" holes, 1" / 25mm spacing). Licensed CC-NC.

## Build & Export

Requires OpenSCAD (nightly recommended). No automated test suite — validation is visual in the OpenSCAD GUI.

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

OpenSCAD nightly supports `--summary all --summary-file -` which outputs a JSON geometry report to stdout. Use this as a lightweight sanity check — it runs in ~50–100ms and catches geometry regressions without a GUI.

**Command (for overrides — requires pegstr.scad temporarily edited to include the override):**
```bash
"C:\Program Files\OpenSCAD (Nightly)\openscad.exe" pegstr.scad --backend Manifold \
  -p pegstr.json -P "parameter-set-name" \
  --render --summary all --summary-file - -o output.stl
```

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

**Parse with Python:**
```bash
openscad-nightly pegstr.scad ... --summary all --summary-file - -o out.stl 2>&1 \
  | python -c "
import json, sys
lines = sys.stdin.read()
data = json.loads(lines.split('{', 1)[1].rsplit('}', 1)[0].join(['{', '}']))
geo = data['geometry']
assert geo['simple'], 'Not manifold'
assert geo['vertices'] > 500, f\"Too few vertices: {geo['vertices']}\"
print('PASS', geo['bounding_box']['size'])
"
```

**Known geometry values for reference** (update when parameters change):

| Preset | Expected Z (tz) | Min vertices |
|---|---|---|
| `garden-shears` | ~84.8mm | 500 |

> **Key lesson:** `holder_z_size` must be large enough that `tz` leaves sufficient holder body after `flatten_top` clips at `tz`. The visible body height = `tz - (tz - holder_z_size_actual/2)` = `holder_z_size_actual/2`. All existing bin presets use `holder_z_size` ≥ 50mm. With `holder_z_size = 30` and `slot_z = 20`, flatten consumed the entire body.

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

**Overrides are not standalone files.** They must be rendered by temporarily editing `pegstr.scad`:
1. Comment out `pegstr();` (line ~601)
2. Uncomment (or add) `include <overrides/your-override.scad>`
3. Run: `"C:\Program Files\OpenSCAD (Nightly)\openscad.exe" pegstr.scad --backend Manifold -p pegstr.json -P your-preset -o output.stl`
4. Revert `pegstr.scad`

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
