# Garden Shears Holder Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a pegboard holder for two pairs of garden shears, with a 60mm-wide rear slot and a 35mm-wide front slot, each 24mm deep and 20mm tall.

**Architecture:** Add a `garden-shears` parameter set to `pegstr.json`, then create `overrides/bins-garden-shears.scad` using the allen-keys pattern — a `difference()` of `pegstr()` with two hand-positioned `cube()` cuts in world-space coordinates. No `lib/bins.scad` needed since the two slots have different widths.

**Tech Stack:** OpenSCAD (nightly), pegstr parametric model, pegstr.json parameter database.

---

## File Map

| Action | File |
|--------|------|
| Modify | `pegstr.json` — add `garden-shears` parameter set (insert after line 117) |
| Create | `overrides/bins-garden-shears.scad` — override with two custom slot cuts |

---

### Task 1: Add `garden-shears` parameter set to `pegstr.json`

**Files:**
- Modify: `pegstr.json:117` (insert after the closing `},` of `frost-dial-a-drill`)

- [ ] **Step 1: Insert the parameter set**

In `pegstr.json`, after line 117 (the closing `},` of `frost-dial-a-drill`), insert the following block. The new entry goes between `frost-dial-a-drill` and `helping-hands` to maintain alphabetical order.

```json
        "garden-shears": {
            "$fn": "200",
            "board_thickness": "0",
            "closed_bottom": "1",
            "closed_bottom_factor": "1",
            "closed_bottom_lip": "0",
            "corner_radius": "0",
            "flatten_bottom": "true",
            "flatten_front": "false",
            "flatten_method": "difference",
            "flatten_sides": "true",
            "flatten_top": "true",
            "holder_angle": "0",
            "holder_cutout_side": "0",
            "holder_offset": "0",
            "holder_sides_fn": "200",
            "holder_x_count": "1",
            "holder_x_size": "60",
            "holder_x_spacing": "0",
            "holder_y_count": "2",
            "holder_y_size": "24",
            "holder_z_size": "30",
            "hole_size": "5.85",
            "hole_spacing": "25",
            "hook_size": "5",
            "pin_extra_len": "4",
            "quantized_x_size": "false",
            "quantized_x_spacing": "false",
            "quantized_z_size": "false",
            "strength_factor": "1",
            "taper_ratio_x": "1",
            "taper_ratio_y": "1",
            "wall_thickness": "2"
        },
```

- [ ] **Step 2: Verify JSON is valid**

```bash
python -c "import json; json.load(open('pegstr.json')); print('OK')"
```

Expected output: `OK`

- [ ] **Step 3: Commit**

```bash
git add pegstr.json
git commit -m "feat: add garden-shears parameter set"
```

---

### Task 2: Create the override file

**Files:**
- Create: `overrides/bins-garden-shears.scad`

- [ ] **Step 1: Create the file**

Create `overrides/bins-garden-shears.scad` with the following content:

```scad
// Garden Shears Holder
//
// Two slots for two pairs of garden shears stored front-to-back.
//   Rear slot (closest to wall): 60mm wide x 24mm deep x 20mm tall
//   Front slot:                  35mm wide x 24mm deep x 20mm tall
//
// To render, temporarily edit pegstr.scad:
//   1. Comment out:  pegstr();
//   2. Uncomment:    include <overrides/bins-garden-shears.scad>
//
// Render:
//   openscad-nightly pegstr.scad --backend Manifold -p pegstr.json -P garden-shears -o garden-shears.stl
//
// Revert pegstr.scad after rendering.

module shear_slots() {
    slot_z = 20;

    // Rear slot (row 0, closest to wall): 60mm wide
    translate([tx/2, wall_thickness + holder_y_size/2, tz - slot_z/2])
        cube([60 + epsilon, holder_y_size + epsilon, slot_z + epsilon], center=true);

    // Front slot (row 1): 35mm wide
    translate([tx/2, 2*wall_thickness + 3*holder_y_size/2, tz - slot_z/2])
        cube([35, holder_y_size + epsilon, slot_z + epsilon], center=true);
}

render()
    difference() {
        pegstr();
        shear_slots();
    }
```

- [ ] **Step 2: Visual verification in OpenSCAD**

1. Open `pegstr.scad` in OpenSCAD
2. Comment out `pegstr();` (around line 601)
3. Add `include <overrides/bins-garden-shears.scad>` below it
4. In the Customizer panel, select parameter set `garden-shears`
5. Press F5 (preview)

Expected result: A rectangular holder with two open slots visible from the top. The rear slot (closest to the back face) is noticeably wider than the front slot.

- [ ] **Step 3: Revert `pegstr.scad`**

Undo the changes from Step 2 (re-enable `pegstr();`, remove the include line).

- [ ] **Step 4: Commit**

```bash
git add overrides/bins-garden-shears.scad
git commit -m "feat: add garden shears holder override"
```

---

### Task 3: Render to STL

**Files:**
- Read: `pegstr.scad` (temporarily modify then revert)
- Output: `garden-shears.stl`

- [ ] **Step 1: Edit `pegstr.scad` for rendering**

Around line 601 in `pegstr.scad`:
- Comment out: `pegstr();`
- Add below it: `include <overrides/bins-garden-shears.scad>`

- [ ] **Step 2: Render**

```bash
openscad-nightly pegstr.scad --backend Manifold -p pegstr.json -P garden-shears -o garden-shears.stl
```

Expected: `garden-shears.stl` created with no errors. Warnings about unused variables are normal.

- [ ] **Step 3: Revert `pegstr.scad`**

Undo the edits from Step 1.

- [ ] **Step 4: Commit STL and revert**

```bash
git add garden-shears.stl
git commit -m "feat: render garden shears holder STL"
```
