# Garden Shears Holder — Design Spec

**Date:** 2026-05-30

## Overview

A pegboard holder for two pairs of garden shears, stored one behind the other (front-to-back). Each shear sits in its own rectangular slot cut into the top of the holder. The rear slot (closest to the wall) is wider than the front slot.

## Slot Dimensions

| Slot | X (width) | Y (depth) | Z (height) |
|------|-----------|-----------|------------|
| Rear (row 0, closest to wall) | 60mm | 24mm | 20mm |
| Front (row 1) | 35mm | 24mm | 20mm |

Both slots are open at the top. The holder has a closed bottom so shears rest rather than fall through.

The front slot (35mm) is narrower than the bin interior (60mm), leaving 12.5mm ledges on each side that support the front shear.

## Files

### `pegstr.json` — parameter set `garden-shears`

| Parameter | Value |
|---|---|
| `holder_x_count` | 1 |
| `holder_x_size` | 60 |
| `holder_y_count` | 2 |
| `holder_y_size` | 24 |
| `holder_z_size` | 30 |
| `wall_thickness` | 2 |
| `closed_bottom` | 1 |
| `closed_bottom_factor` | 1 |
| `closed_bottom_lip` | 0 |
| `corner_radius` | 0 |
| `flatten_top` | true |
| `flatten_sides` | true |
| `flatten_bottom` | true |
| `flatten_front` | false |
| `flatten_method` | difference |
| `holder_angle` | 0 |
| `holder_offset` | 0 |
| `holder_cutout_side` | 0 |
| `taper_ratio_x` | 1 |
| `taper_ratio_y` | 1 |
| `holder_x_spacing` | 0 |
| `hole_size` | 5.85 |
| `hole_spacing` | 25 |
| `hook_size` | 5 |
| `pin_extra_len` | 4 |
| `board_thickness` | 0 |
| `holder_sides_fn` | 200 |
| `$fn` | 200 |
| `quantized_x_size` | false |
| `quantized_x_spacing` | false |
| `quantized_z_size` | false |
| `strength_factor` | 1 |

### `overrides/bins-garden-shears.scad`

Uses `difference()` with `pegstr()` and two hand-positioned `cube()` cuts in world-space coordinates (allen-keys pattern — no `lib/bins.scad` needed).

```
render()
  difference() {
    pegstr();
    // rear slot (row 0): 60mm wide, open at top
    // front slot (row 1): 35mm wide, open at top
  }
```

**World-space slot centres:**

- Rear: `(tx/2, wall_thickness + holder_y_size/2, tz - 10)`
- Front: `(tx/2, 2*wall_thickness + 1.5*holder_y_size, tz - 10)`

Both cubes are `center=true` with `[width, holder_y_size, 20]` dimensions, plus epsilon on Z to avoid Z-fighting at the top face.

## Render Instructions

To render, temporarily edit `pegstr.scad`:
1. Comment out `pegstr();`
2. Add `include <overrides/bins-garden-shears.scad>`
3. Run:
   ```
   openscad-nightly pegstr.scad --backend Manifold -p pegstr.json -P garden-shears -o garden-shears.stl
   ```
4. Revert `pegstr.scad`
