# Metric Allen Key Holder Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `overrides/allen-keys.scad` and a `allen-keys-metric` JSON preset that renders a pegboard-mounted block holding 7 metric allen keys (long arm down, short arm up).

**Architecture:** An override SCAD file that calls `pegstr()` for the peg backing, unions a solid rectangular block on top, then differences cylindrical holes (one per key, bored to each key's long-arm depth) and recessed size labels from the front face. Coordinate math is in pegstr world-space as documented in CLAUDE.md.

**Tech Stack:** OpenSCAD (nightly). No automated tests — validation is visual in the OpenSCAD GUI.

---

## Coordinate System Reference

`pegstr()` applies `rotate([0,0,-90])` then `translate([tx/2, 0, tz-clip_height/2])` internally.
Geometry placed alongside `pegstr()` in `union()`/`difference()` must use **world-space** coordinates:

| World axis | Formula from pegstr params |
|---|---|
| X (horizontal) | `wall_thickness + col * (wall_thickness + holder_x_size_actual) + holder_x_size_actual/2` |
| Y (depth, 0=wall face, ty=front) | `wall_thickness + row * (wall_thickness + holder_y_size) + holder_y_size/2` |
| Z (vertical, 0=bottom, tz=top) | `tz - long_arm_length/2` (for hole centres) |

Key computed variables available from `pegstr.scad` globals (in scope when included):
- `tx` — total holder width
- `ty` — total holder depth (`holder_total_y + holder_offset`)
- `tz` — total height
- `holder_x_size_actual` — actual per-column cell width (= `holder_x_size` when not quantized)
- `holder_z_size_actual` — actual block height (= `holder_z_size` when `closed_bottom=0`)
- `wall_thickness`, `holder_y_size`, `epsilon`, `$fn`

## Files

| Action | Path | Responsibility |
|---|---|---|
| Modify | `pegstr.json` | Add `allen-keys-metric` parameter preset |
| Create | `overrides/allen-keys.scad` | Block geometry, holes, labels |

---

## Task 1: Add JSON Preset

**Files:**
- Modify: `pegstr.json`

- [ ] **Step 1: Insert the preset block**

Open `pegstr.json`. Find the line:

```json
    "parameterSets": {
```

Insert the following immediately after it (before the first existing preset), maintaining valid JSON (add a trailing comma after the closing `}`):

```json
        "allen-keys-metric": {
            "$fn": "200",
            "board_thickness": "0",
            "closed_bottom": "0",
            "corner_radius": "0",
            "holder_angle": "0",
            "holder_cutout_side": "0",
            "holder_offset": "0",
            "holder_x_count": "4",
            "holder_x_size": "14",
            "holder_x_spacing": "0",
            "holder_y_count": "2",
            "holder_y_size": "14",
            "holder_z_size": "104",
            "hole_size": "5.78",
            "hole_spacing": "25",
            "hook_size": "5.25",
            "pin_extra_len": "3",
            "quantized_x_size": "false",
            "quantized_z_size": "false",
            "strength_factor": "0",
            "taper_ratio_x": "1",
            "taper_ratio_y": "1",
            "wall_thickness": "3"
        },
```

These values give:
- `tx` = 3 + 4×(3+14) = **71 mm** wide (spans ~3 pegboard holes)
- `ty` = 3 + 2×(3+14) = **37 mm** deep
- `holder_z_size_actual` = **104 mm** tall (8 mm floor under the deepest 100 mm hole)
- Column cell width = 14 mm (3 mm wall each side of the 8 mm shaft = comfortable)

- [ ] **Step 2: Verify JSON is valid**

```bash
python -c "import json; json.load(open('pegstr.json'))" && echo "VALID"
```

Expected output: `VALID`

If you get a parse error, find and fix the syntax issue (missing/extra comma, mismatched braces).

- [ ] **Step 3: Commit**

```bash
git add pegstr.json
git commit -m "feat: add allen-keys-metric JSON preset"
```

---

## Task 2: Create the Override

**Files:**
- Create: `overrides/allen-keys.scad`

### Background: how the holder works

With the preset above:
- `holder_x_size_actual = 14`, `wall_thickness = 3`, `holder_y_size = 14`
- `tz ≈ 104` (strength_factor=0, so tz = holder_z_size_actual = 104)

**Block** (solid cube in world space):
```
centre = [tx/2, ty/2, tz - holder_z_size_actual/2]
size    = [tx,   ty,   holder_z_size_actual]
```
That spans X:[0→71], Y:[0→37], Z:[0→104].

**Hole centre for key at [row, col]** with shaft `d` and long arm `l`:
```
world_x = wall_thickness + col*(wall_thickness + holder_x_size_actual) + holder_x_size_actual/2
world_y = wall_thickness + row*(wall_thickness + holder_y_size) + holder_y_size/2
world_z = tz - l/2
```
Cylinder: `h = l + epsilon`, `d = d + hole_wiggle`, `center = true`

**Label position** (subtracted from front face at Y=ty, near block base):
```
[world_x, ty + epsilon, tz - holder_z_size_actual + text_size*2]
rotate([90, 0, 0])   // extrusion direction becomes -Y (into front face)
linear_extrude(height = text_depth + epsilon)
  text(str(key_size), size=text_size, halign="center", valign="center")
```
The `rotate([90,0,0])` mapping: +Z(extrude)→-Y(into block) ✓, +X→+X ✓, text "up" (+Y)→+Z ✓.

### Row/column layout

```
Row 0 (back,  world_y ≈ 10): col0=2.0mm  col1=2.5mm  col2=3.0mm  col3=4.0mm
Row 1 (front, world_y ≈ 27): col0=5.0mm  col1=6.0mm  col2=8.0mm  col3=empty
```

The `len(keys[row])` loop automatically skips the empty col-3 in row 1.

- [ ] **Step 1: Create `overrides/allen-keys.scad`**

```scad
hole_wiggle = 0.5;
render_holder = false;
render_text = true;
text_size = 7;
text_depth = 1;

// [shaft_diameter_mm, long_arm_length_mm]
// Row 0 = back (closest to wall), Row 1 = front. Col 3 of row 1 is intentionally absent.
keys = [
  [[2.0, 49], [2.5, 56], [3.0, 60], [4.0, 70]],
  [[5.0, 80], [6.0, 90], [8.0, 100]],
];

module key_holes() {
  for (row = [0:len(keys)-1]) {
    for (col = [0:len(keys[row])-1]) {
      d = keys[row][col][0];
      l = keys[row][col][1];
      world_x = wall_thickness + col * (wall_thickness + holder_x_size_actual) + holder_x_size_actual / 2;
      world_y = wall_thickness + row * (wall_thickness + holder_y_size) + holder_y_size / 2;
      translate([world_x, world_y, tz - l / 2])
        cylinder(h=l + epsilon, d=d + hole_wiggle, center=true, $fn=$fn);
    }
  }
}

module key_labels() {
  for (row = [0:len(keys)-1]) {
    for (col = [0:len(keys[row])-1]) {
      d = keys[row][col][0];
      world_x = wall_thickness + col * (wall_thickness + holder_x_size_actual) + holder_x_size_actual / 2;
      translate([world_x, ty + epsilon, tz - holder_z_size_actual + text_size * 2])
        rotate([90, 0, 0])
          linear_extrude(height=text_depth + epsilon)
            text(str(d), size=text_size, halign="center", valign="center");
    }
  }
}

if (render_holder) {
  difference() {
    union() {
      pegstr();
      color("lightblue")
        translate([tx / 2, ty / 2, tz - holder_z_size_actual / 2])
          cube([tx, ty, holder_z_size_actual], center=true);
    }
    key_holes();
    key_labels();
  }
}

if (render_text) {
  key_labels();
}
```

- [ ] **Step 2: Wire up the override in `pegstr.scad` for preview**

In `pegstr.scad`, around line 601:

```scad
// Comment this out:
// pegstr();

// Add this:
include <overrides/allen-keys.scad>
```

- [ ] **Step 3: Open in OpenSCAD GUI and preview**

Open `pegstr.scad` in OpenSCAD (nightly), select parameter set `allen-keys-metric` in the Customizer. Press F5 (preview).

With defaults (`render_holder=false, render_text=true`), you should see 7 floating label glyphs positioned on where the front face will be.

Check:
- Labels appear in a 4-wide × 2-tall grid arrangement
- Row 1 has 3 labels (not 4)
- Labels read: 2, 2.5, 3, 4 (back row) and 5, 6, 8 (front row)

- [ ] **Step 4: Preview the holder body**

In `overrides/allen-keys.scad`, temporarily flip flags:

```scad
render_holder = true;
render_text = false;
```

Press F5 in OpenSCAD. You should see:
- A solid rectangular block (~71 × 37 × 104 mm) mounted on the peg backing plate
- 7 cylindrical holes bored from the top, varying diameter/depth
- Row 0 (back): 4 holes, smallest diameter at left
- Row 1 (front): 3 holes, larger diameters, rightmost slot empty
- Recessed label slots on the front face, near the base
- Peg clips protruding from the back

Common issues and fixes:
- **Block floats above backing**: `holder_z_size_actual` or `tz` mismatch — add `echo(tz=tz, holder_z_size_actual=holder_z_size_actual)` and check console output.
- **Holes don't reach the top**: adjust `world_z = tz - l/2` — verify `tz` echoed value matches expectation.
- **Labels missing/wrong position**: verify `ty` echoed value; adjust `tz - holder_z_size_actual + text_size*2` offset.

- [ ] **Step 5: Render to STL (holder)**

With `render_holder=true, render_text=false`:

```bash
"C:\Program Files\OpenSCAD (Nightly)\openscad.exe" pegstr.scad --backend Manifold -p pegstr.json -P allen-keys-metric -o allen-keys-metric-holder.stl
```

Confirm output file is created and non-zero size.

- [ ] **Step 6: Render to STL (labels)**

Set `render_holder=false, render_text=true`, then:

```bash
"C:\Program Files\OpenSCAD (Nightly)\openscad.exe" pegstr.scad --backend Manifold -p pegstr.json -P allen-keys-metric -o allen-keys-metric-labels.stl
```

- [ ] **Step 7: Revert `pegstr.scad`**

Restore `pegstr.scad` to its original state (re-enable `pegstr();`, remove the include):

```scad
pegstr();

//include <overrides/allen-keys.scad>
```

- [ ] **Step 8: Reset render flags in override**

Set the flags back to defaults in `overrides/allen-keys.scad`:

```scad
render_holder = false;
render_text = true;
```

- [ ] **Step 9: Commit**

```bash
git add overrides/allen-keys.scad
git commit -m "feat: add metric allen key holder override"
```

---

## Tuning (after printing or first render inspection)

These are not plan tasks — do them as needed after the first physical print:

- **Hole too tight/loose**: adjust `hole_wiggle` (increase for looser fit, decrease for tighter)
- **Key bottoms out wrong**: measure actual long-arm lengths with calipers and update `keys` array values
- **Block too narrow/wide**: adjust `holder_x_size` in the JSON preset
- **Labels too small/large**: adjust `text_size` in the override
