# Stanley Blades Dual-Bin Holder Design

## Summary

A single pegboard holder with two side-by-side open-top bins: a narrow left bin for razor blade refills and a taller right bin for a Stanley knife.

## Parameters

| Parameter | Value |
|---|---|
| `holder_x_size` | `64` (27 + 2mm divider + 35) |
| `holder_x_count` | `1` |
| `holder_y_size` | `23` |
| `holder_z_size` | `55` |
| `closed_bottom` | `1` (2mm floor) |
| `wall_thickness` | `2` |
| `hole_size` / `hook_size` / `pin_extra_len` | `4.9` |

## Override Logic

`overrides/stanley-blades.scad` uses `union()` to add back two pieces of material into the large hollow produced by `pegstr()`:

1. **Divider wall** — 2mm wall at the junction between bins, full interior depth and height
2. **Left bin raised floor** — fills the bottom 33mm of the left bin area, leaving a 22mm cavity from the top

## Bin Dimensions (interior)

| Bin | Width | Depth | Height |
|---|---|---|---|
| Left (razor blade refills) | 27mm | 23mm | 22mm |
| Right (Stanley knife) | 35mm | 23mm | 55mm |

## Print Dimensions

68mm wide × 27mm deep × 57mm tall
