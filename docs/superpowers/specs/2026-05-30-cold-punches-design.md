# Cold Punches Holder — Design Spec

## Overview

A pegboard holder for 6 cold punches stored tip-up. Flat punch bases rest on a closed bottom floor inside each cylindrical hole. Single row, 6 columns.

## Hole Sizes

| Column | Punch diameter | Hole diameter (+ 1mm wiggle) |
|--------|---------------|------------------------------|
| 0 | 8mm | 9mm |
| 1 | 9mm | 10mm |
| 2 | 9mm | 10mm |
| 3 | 9mm | 10mm |
| 4 | 12mm | 13mm |
| 5 | 12mm | 13mm |

Hole depth: 40mm. No countersink. No text labels.

## Files

- `overrides/cold-punches.scad` — override geometry
- `pegstr.json` — new preset `cold-punches`

## Preset Parameters (`pegstr.json`)

| Parameter | Value |
|-----------|-------|
| `holder_x_count` | 6 |
| `holder_y_count` | 1 |
| `holder_x_size` | 15 |
| `holder_y_size` | 15 |
| `holder_z_size` | 50 |
| `wall_thickness` | 1.5 |
| `closed_bottom` | 1 |
| `closed_bottom_factor` | 1 |
| `flatten_method` | `"difference"` |
| `flatten_top` | `true` |
| `corner_radius` | 30 |
| `$fn` | 200 |

## SCAD Structure

Fill + cut approach (drill-bits-large pattern):

```
difference() {
  union() {
    pegstr()
    fill cylinders per cell (d = holder_x_size_actual + wall_thickness, h = holder_z_size_actual)
  }
  hole cylinders per cell (d = hole diameter, h = 40mm, centred at tz - 20)
}
```

World-space cell centres:
- `cx = wall_thickness + col*(wall_thickness + holder_x_size_actual) + holder_x_size_actual/2`
- `cy = wall_thickness + holder_y_size/2`  (single row, row=0)
- Fill cylinder centred at `[cx, cy, tz - holder_z_size_actual/2]`
- Hole centred at `[cx, cy, tz - hole_depth/2]`

## Validation

Run geometry check after implementation:

```bash
"/c/Program Files/OpenSCAD (Nightly)/openscad.exe" pegstr.scad --backend Manifold \
  -p pegstr.json -P "cold-punches" \
  --render --summary all --summary-file - -o output.stl 2>&1; echo "EXIT:$?"
```

Assertions:
- Exit code == 0
- `simple == true`
- `vertices > 500`
- `size[2] ≈ 50mm` (holder_z_size)
