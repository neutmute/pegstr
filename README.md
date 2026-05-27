# Pegstr - Pegboard Wizard

Fork of https://github.com/MGX3D/pegstr, targeting [Rack It Pegboard ](https://rack-it.com.au/products/wall-pegboard/) sold in AU/NZD

Rack It Properties

1. 5mm holes, spaced 25mm apart
2. Model pin and holes should be ~4.6mm. Must be less than 5mm or won't fit.


## Models

| Model | Description |
|---|---|
| `sidecutters-3x` | Hold 3x side cutters |
| `ryobi-laser-measure-rlm30` | Bin for the laser measurer |
| `helping-hands` | Bin for holding the magnifier/alligator clip helping hand |
| `z_*` | Inherited from the fork, retained for examples |


## Architecture

### `pegstr.json` vs `overrides/*.scad`

`pegstr.json` holds named parameter presets and covers the common case: a uniform grid of identically-sized cups or hooks. Open `pegstr.scad` in OpenSCAD, pick a preset from the Customizer, and export.

When a design needs more than the parameter system can express, an `overrides/*.scad` file takes over. There are three patterns:

| Pattern | Examples | Why an override is needed |
|---|---|---|
| **Custom bin geometry** | `bins-pry.scad`, `bins-eraser-lead.scad` | Carves different compartment widths and front/back wall heights per row using `bin_interior()` / `bin_height()` from `lib/bins.scad` — not expressible as a uniform parameter set |
| **STL tool model boolean ops** | `screwdrivers.scad`, `multimeter.scad` | Imports a measured STL scan of the real tool and uses it as a boolean cutter against the `pegstr()` base, so the holder conforms exactly to the tool's shape. The `screwdrivers_*` keys in `pegstr.json` are tuning knobs (scale, offsets, which STL) that feed into the override |
| **Standalone complex designs** | `caliper4.scad` | Builds a full hinged two-part snap-fit mould using the BOSL2 library — its own hinge, snap-lock, and multi-layer extrusion. `pegstr()` is barely involved; the `pegstr.json` entry is a leftover scaffold |
