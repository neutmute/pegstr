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

## Code Conventions

- `.editorconfig`: LF line endings, 4-space indent for JSON, UTF-8
- `epsilon` variable used throughout to prevent Z-fighting in boolean ops
- `echo()` statements log computed parameters to console for debugging
- `render()` calls wrap expensive geometry for OpenSCAD performance
- Color assignments (`red`, `green`, etc.) are visualization aids only — not meaningful in exported STL

## Print Notes

See `print-notes.md` for tolerance and material guidance specific to FDM printing.
