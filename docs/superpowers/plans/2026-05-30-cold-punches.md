# Cold Punches Holder Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a pegboard holder for 6 cold punches (tip-up, flat base) as a `cold-punches` preset and matching SCAD override.

**Architecture:** Add a JSON preset to `pegstr.json` and a new `overrides/cold-punches.scad` that follows the `drill-bits-large.scad` fill+cut pattern — union fill cylinders per cell, then difference blind holes 40mm deep from the top. The closed bottom in the preset leaves solid material below the holes for the punch bases to rest on.

**Tech Stack:** OpenSCAD (nightly), pegstr parametric system

---

### Task 1: Add JSON preset

**Files:**
- Modify: `pegstr.json:397` (insert after the closing `},` of `drill-bits-large`)

- [ ] **Step 1: Insert the `cold-punches` preset**

In `pegstr.json`, find line 397 (the `},` that closes `drill-bits-large`) and insert the following block immediately after it, before `"z_acetone-holder"`:

```json
        "cold-punches": {
            "$fn": "200",
            "board_thickness": "0",
            "closed_bottom": "1",
            "closed_bottom_factor": "1",
            "closed_bottom_lip": "2",
            "corner_radius": "30",
            "flatten_method": "difference",
            "flatten_top": "true",
            "holder_angle": "0",
            "holder_cutout_side": "0",
            "holder_offset": "0",
            "holder_sides_fn": "200",
            "holder_x_count": "6",
            "holder_x_size": "15",
            "holder_y_count": "1",
            "holder_y_size": "15",
            "holder_z_size": "50",
            "hole_size": "4.9",
            "hole_spacing": "25",
            "hook_size": "4.9",
            "pin_extra_len": "4.9",
            "strength_factor": "0",
            "taper_ratio_x": "1",
            "taper_ratio_y": "1",
            "wall_thickness": "1.5"
        },
```

The result should look like:

```
        },        ← end of drill-bits-large
        "cold-punches": {
            ...
        },
        "z_acetone-holder": {
```

- [ ] **Step 2: Commit**

```bash
git add pegstr.json
git commit -m "add cold-punches JSON preset"
```

---

### Task 2: Create the SCAD override

**Files:**
- Create: `overrides/cold-punches.scad`

- [ ] **Step 1: Create `overrides/cold-punches.scad`**

```scad
hole_depth = 40;

// hole diameter = punch diameter + 1mm wiggle, left to right
// punches: 8, 9, 9, 9, 12, 12 mm
holes = [9, 10, 10, 10, 13, 13];

difference() {
  union() {
    pegstr();
    for (col = [0:len(holes)-1]) {
      cx = wall_thickness + col * (wall_thickness + holder_x_size_actual) + holder_x_size_actual / 2;
      cy = wall_thickness + holder_y_size / 2;
      translate([cx, cy, tz - holder_z_size_actual / 2])
        cylinder(h=holder_z_size_actual, d=holder_x_size_actual + wall_thickness, center=true, $fn=$fn);
    }
  }
  for (col = [0:len(holes)-1]) {
    d = holes[col];
    cx = wall_thickness + col * (wall_thickness + holder_x_size_actual) + holder_x_size_actual / 2;
    cy = wall_thickness + holder_y_size / 2;
    translate([cx, cy, tz - hole_depth / 2])
      cylinder(h=hole_depth + epsilon, d=d, center=true, $fn=$fn);
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add overrides/cold-punches.scad
git commit -m "add cold-punches SCAD override"
```

---

### Task 3: Geometry validation

**Files:**
- Modify temporarily: `pegstr.scad:601` (comment out `pegstr();`, add include — revert after)

The override must be tested by temporarily editing `pegstr.scad` so it includes the override instead of calling `pegstr()` directly. Use the Edit tool for both edits — do not use shell regex.

- [ ] **Step 1: Edit `pegstr.scad` line 601**

Use the Edit tool. Change:
```
pegstr();
```
to:
```
//pegstr();
include <overrides/cold-punches.scad>
```

- [ ] **Step 2: Run geometry validation**

```bash
"/c/Program Files/OpenSCAD (Nightly)/openscad.exe" pegstr.scad --backend Manifold \
  -p pegstr.json -P "cold-punches" \
  --render --summary all --summary-file - -o output.stl 2>&1; echo "EXIT:$?"
```

Check all four assertions in the JSON summary block (the last `{...}` in the output):

| Assertion | Expected |
|-----------|----------|
| Exit code | `EXIT:0` |
| `simple` | `true` |
| `vertices` | `> 500` |
| `size[2]` | `≈ 50mm` |

If any assertion fails, diagnose before continuing. Common issues:
- Non-zero exit / SCAD errors → syntax error in the override file
- `simple: false` → geometry is non-manifold, likely a bad boolean op
- `vertices < 500` → fill cylinders failed or holder body was consumed
- `size[2]` wrong → `holder_z_size` or `flatten_top` issue

- [ ] **Step 3: Revert `pegstr.scad` line 601**

Use the Edit tool. Change back:
```
//pegstr();
include <overrides/cold-punches.scad>
```
to:
```
pegstr();
```

- [ ] **Step 4: Commit**

```bash
git add overrides/cold-punches.scad pegstr.json
git commit -m "cold-punches: verified geometry, clean up output.stl"
```

(Delete `output.stl` if it was created in the repo root — it is a build artefact and should not be committed.)

```bash
# if output.stl was created:
rm output.stl
```
