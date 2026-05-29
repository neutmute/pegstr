# Metric Allen Key Holder — Design Spec

Date: 2026-05-29

## Overview

A pegboard-mounted holder for 7 metric allen keys (2, 2.5, 3, 4, 5, 6, 8 mm). Keys sit long-arm-down in precisely-bored cylindrical holes so the short L-arm protrudes upward as a grab handle. Two rows of 4+3 keys. Follows the `drill-bits.scad` override pattern.

## Key Data

Keys are arranged in two rows. Each entry is `[shaft_diameter_mm, long_arm_length_mm]`. Long-arm lengths are standard approximations — verify against actual keys before final print.

```
Row 0 (back):  [2.0, 49],  [2.5, 56],  [3.0, 60],  [4.0, 70]   // 4 keys
Row 1 (front): [5.0, 80],  [6.0, 90],  [8.0, 100]               // 3 keys, 4th slot empty
```

`hole_wiggle = 0.5mm` added to each shaft diameter for fit tolerance.

Each hole is bored to that key's specific long-arm depth so all short arms protrude uniformly above the block top.

## Block Geometry

A solid rectangular block is `union()`d with `pegstr()`, then cylindrical holes are `difference()`d out.

- **Width**: 4 columns × (largest shaft 8mm + walls ~6mm) ≈ 56mm, snapped to pegboard grid
- **Depth**: 2 rows × (8mm + walls ~6mm) ≈ 28mm
- **Height**: longest long arm (100mm) + solid floor (~4mm) ≈ 104mm (~4 pegboard holes tall)
- **Attachment**: block sits flush with the face of the `pegstr()` backing plate; mounting pins come entirely from `pegstr()` clip geometry
- **Holes**: each cylinder centred in its column/row cell; diameter = shaft + wiggle; depth = that key's long-arm length
- **Labels**: size text embossed on the front face per column (matching `drill-bits.scad` pattern)

## Files

### `overrides/allen-keys.scad` (new)

Structure mirrors `drill-bits.scad`:

```
hole_wiggle = 0.5;
render_holder = true;
render_text = true;
text_size = 7;
text_depth = 1;

keys = [
  [[2.0, 49], [2.5, 56], [3.0, 60], [4.0, 70]],   // row 0
  [[5.0, 80], [6.0, 90], [8.0, 100]],               // row 1
];

if (render_holder) {
  difference() {
    union() {
      pegstr();
      // solid block in world-space coordinates
    }
    // per-key cylindrical holes
  }
}

if (render_text) {
  // size labels on front face
}
```

World-space coordinate transforms follow the `pegstr()` coordinate system documented in CLAUDE.md.

### `pegstr.json` — new preset `"allen-keys-metric"`

| Parameter | Value | Notes |
|---|---|---|
| `holder_x_count` | 4 | columns |
| `holder_y_count` | 2 | rows |
| `holder_x_size` | ~14 | cell width, tune after first render |
| `holder_y_size` | ~14 | cell depth, tune after first render |
| `holder_z_size` | ~104 | block height |
| `closed_bottom` | 0 | block provides structure |
| `wall_thickness` | 3 | between holes and outer faces |
| `$fn` | 200 | smooth cylinders |
| `board_thickness` | 0 | standard |
| `hole_spacing` | 25 | standard pegboard |

## Rendering

Override is not standalone. Render by temporarily editing `pegstr.scad`:
1. Comment out `pegstr();`
2. Add `include <overrides/allen-keys.scad>`
3. Run: `openscad-nightly pegstr.scad --backend Manifold -p pegstr.json -P allen-keys-metric -o allen-keys-metric.stl`
4. Revert `pegstr.scad`

Two separate STL exports may be needed: one with `render_holder=true, render_text=false` and one with `render_holder=false, render_text=true` for multi-material or painted labels.

## Tuning After First Render

- Verify long-arm lengths against actual keys and adjust the `keys` array
- Adjust `holder_x_size` / `holder_y_size` if column/row spacing needs changing
- Adjust `hole_wiggle` if fit is too tight or too loose
