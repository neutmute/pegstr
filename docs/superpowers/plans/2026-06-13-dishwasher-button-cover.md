# Dishwasher Button Cover Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce `dishwasher-button-cover.scad` — a parametric OpenSCAD file that generates two 3D-printable parts: a magnet-mounted frame and a sliding cover that protects a dishwasher button.

**Architecture:** Single `.scad` file with a `render_part` switch (`"frame"`, `"cover"`, `"both"`). Two modules — `frame()` and `cover()` — derive all geometry from top-level parameters. No JSON preset file; parameters live directly in the `.scad` file. Geometry is validated headlessly using OpenSCAD's `--summary` flag after each module is implemented.

**Tech Stack:** OpenSCAD (nightly), Manifold backend, FDM 3D printing (PLA/PETG)

---

## Coordinate System

All geometry uses this model coordinate system:

| Axis | Range | Meaning |
|---|---|---|
| X | 0 → 42mm | Width, slide direction (left = exposed, right = covered) |
| Y | 0 → 32mm | Height (0 = bottom, 32 = top) |
| Z | 0 → 5mm | Depth from panel (Z=0 = panel face, Z=5 = outer/user face) |

**Print orientation for both parts:** panel face UP (Z=0 at top of print, Z=5 at bed). Frame slicer pause at z_print = 4.6mm from bed to insert magnets before the 0.4mm skin layers close the pockets.

## Key Layout (frame)

```
Y=32 ┌────────────────────────────────────────┐
     │  TOP BAR  (Y=23..32, magnet pockets)  │
Y=23 ├──┬────────────────────────────────┬───┤
     │  │                                │   │  ← interior (cover slides here)
     │LW│    cover →→→                  │RW │  ← button at X≈31
     │  │                                │   │
Y=9  ├──┴────────────────────────────────┴───┤
     │  BOTTOM BAR (Y=0..9, magnet pockets)  │
Y=0  └────────────────────────────────────────┘
    X=0   X=2                          X=40  X=42
          LW = left wall (2mm)   RW = right wall (stopper, 2mm)
```

---

## File Structure

| File | Purpose |
|---|---|
| `dishwasher-button-cover.scad` | All parameters, `frame()`, `cover()`, render switch |

---

## Task 1: Skeleton with parameters and render switch

**Files:**
- Create: `dishwasher-button-cover.scad`

- [ ] **Step 1: Create the file with all parameters and a render switch**

```openscad
// Dishwasher button safety cover
// Two parts: frame (magnets) + sliding cover
// Print orientation: panel face UP (Z=0 at top)

// --- Button geometry ---
button_diameter   = 12;    // mm, button face diameter
button_protrusion = 2;     // mm, how far button sticks out from panel
cover_clearance   = 3;     // mm, internal cavity depth (clears button + margin)

// --- Frame geometry ---
bar_height        = 9;     // mm, top and bottom bar height (fits 8mm magnet + 0.5mm walls)
interior_height   = 14;    // mm, interior channel height
interior_width    = 38;    // mm, interior channel width (cover_width + travel)
cover_width       = 18;    // mm, width of sliding cover
frame_depth       = 5;     // mm, total depth from panel (Z)
wall_thickness    = 1.5;   // mm, cover front-face wall

// --- Magnets (8mm dia x 2mm thick neodymium, x4) ---
magnet_diameter   = 8;     // mm
magnet_height     = 2;     // mm
magnet_skin       = 0.4;   // mm, plastic skin on panel side over magnet

// --- Tolerances ---
slide_tolerance   = 0.2;   // mm clearance per side (Y) for smooth cover sliding

// --- Render ---
render_part = "both"; // "frame", "cover", "both"

// --- Derived (do not edit) ---
frame_w    = interior_width + 4;                        // 42mm
frame_h    = bar_height * 2 + interior_height;          // 32mm
cover_h    = interior_height - slide_tolerance * 2;     // 13.6mm
cover_depth = cover_clearance + wall_thickness;         // 4.5mm

epsilon = 0.01;
$fn = 64;

// --- Render switch ---
if (render_part == "frame" || render_part == "both") {
    frame();
}
if (render_part == "cover" || render_part == "both") {
    translate([0, -(cover_h + 5), 0])
        cover();
}

module frame() { /* Task 2 */ }
module cover()  { /* Task 4 */ }
```

- [ ] **Step 2: Verify file opens in OpenSCAD without errors**

```bash
"/c/Program Files/OpenSCAD (Nightly)/openscad.exe" dishwasher-button-cover.scad \
  --backend Manifold -D "render_part=\"frame\"" \
  --render --summary all --summary-file - -o /tmp/dbc-frame.stl 2>&1; echo "EXIT:$?"
```

Expected: EXIT:0, geometry reports as empty/zero vertices (modules are stubs — that is fine at this stage). No syntax errors.

---

## Task 2: Implement `frame()` — body and interior cutout

**Files:**
- Modify: `dishwasher-button-cover.scad` — replace `module frame() { /* Task 2 */ }`

- [ ] **Step 1: Replace the frame stub with the solid body minus interior**

```openscad
module frame() {
    difference() {
        // Outer solid block
        cube([frame_w, frame_h, frame_depth]);

        // Interior channel — starts at left wall inner face (X=2); cover slides in from left
        translate([2, bar_height, -epsilon])
            cube([interior_width, interior_height, frame_depth + epsilon * 2]);
    }
}
```

- [ ] **Step 2: Run geometry validation**

```bash
"/c/Program Files/OpenSCAD (Nightly)/openscad.exe" dishwasher-button-cover.scad \
  --backend Manifold -D "render_part=\"frame\"" \
  --render --summary all --summary-file - -o /tmp/dbc-frame.stl 2>&1; echo "EXIT:$?"
```

Check the JSON block at the end of the output. Assert all four:

| Check | Expected |
|---|---|
| Exit code | 0 |
| `simple` | `true` |
| `vertices` | > 50 |
| `size[0]` (X) | ≈ 42 |
| `size[1]` (Y) | ≈ 32 |
| `size[2]` (Z) | ≈ 5 |

If any assertion fails, fix before continuing.

---

## Task 3: Add magnet pockets to `frame()`

The frame is printed panel-face UP (Z=0 at top of print). Magnet pockets are recessed from Z=0 (panel face), so they appear near the END of the print. Pause the slicer at **z_print = frame_depth − magnet_skin = 4.6mm** from bed, insert all 4 magnets, then resume. The final 0.4mm skin closes the pockets.

**Files:**
- Modify: `dishwasher-button-cover.scad` — add magnet pocket cuts inside `frame()` difference()

- [ ] **Step 1: Add the four magnet pocket cylinders inside the existing `difference()` block**

Replace the `frame()` module body with:

```openscad
module frame() {
    // X centres for magnet pockets (1/4 and 3/4 of frame width)
    magnet_x1 = frame_w * 0.25;  // 10.5mm
    magnet_x2 = frame_w * 0.75;  // 31.5mm
    // Y centres: middle of each bar
    bottom_bar_cy = bar_height / 2;                                    // 4.5mm
    top_bar_cy    = bar_height + interior_height + bar_height / 2;     // 27.5mm

    difference() {
        // Outer solid block
        cube([frame_w, frame_h, frame_depth]);

        // Interior channel
        translate([2, bar_height, -epsilon])
            cube([interior_width, interior_height, frame_depth + epsilon * 2]);

        // Magnet pockets — open from Z=0 (panel face), with magnet_skin cap
        // Pocket spans Z=magnet_skin to Z=magnet_skin+magnet_height
        for (bx = [magnet_x1, magnet_x2]) {
            for (by = [bottom_bar_cy, top_bar_cy]) {
                translate([bx, by, magnet_skin])
                    cylinder(d = magnet_diameter + 0.2, h = magnet_height + 0.1);
            }
        }
    }
}
```

- [ ] **Step 2: Run geometry validation**

```bash
"/c/Program Files/OpenSCAD (Nightly)/openscad.exe" dishwasher-button-cover.scad \
  --backend Manifold -D "render_part=\"frame\"" \
  --render --summary all --summary-file - -o /tmp/dbc-frame.stl 2>&1; echo "EXIT:$?"
```

Assert:

| Check | Expected |
|---|---|
| Exit code | 0 |
| `simple` | `true` |
| `vertices` | > 200 (magnet pockets add significant vertex count) |
| `size` | ≈ [42, 32, 5] |

- [ ] **Step 3: Visual sanity check (optional but recommended)**

```bash
"/c/Program Files/OpenSCAD (Nightly)/openscad.exe" dishwasher-button-cover.scad \
  --backend Manifold -D "render_part=\"frame\"" \
  --render --camera=21,16,30,55,0,25,150 \
  -o demo-images/dbc-frame-top.png 2>&1; echo "EXIT:$?"
```

Open `demo-images/dbc-frame-top.png`. Confirm: U-shaped frame (open left end visible), four circular pocket recesses visible on top face (panel face), right wall solid.

---

## Task 4: Implement `cover()` — body and button cavity

**Files:**
- Modify: `dishwasher-button-cover.scad` — replace `module cover() { /* Task 4 */ }`

- [ ] **Step 1: Replace cover stub with body and cavity**

```openscad
module cover() {
    difference() {
        // Cover body
        cube([cover_width, cover_h, cover_depth]);

        // Button clearance cavity on panel face (Z=0)
        // Circular recess: 1mm margin around 12mm button → 13mm diameter, 3mm deep
        translate([cover_width / 2, cover_h / 2, -epsilon])
            cylinder(d = button_diameter + 1, h = cover_clearance + epsilon);
    }
}
```

- [ ] **Step 2: Run geometry validation**

```bash
"/c/Program Files/OpenSCAD (Nightly)/openscad.exe" dishwasher-button-cover.scad \
  --backend Manifold -D "render_part=\"cover\"" \
  --render --summary all --summary-file - -o /tmp/dbc-cover.stl 2>&1; echo "EXIT:$?"
```

Assert:

| Check | Expected |
|---|---|
| Exit code | 0 |
| `simple` | `true` |
| `vertices` | > 100 |
| `size[0]` (X) | ≈ 18 |
| `size[1]` (Y) | ≈ 13.6 |
| `size[2]` (Z) | ≈ 4.5 |

---

## Task 5: Final validation — both parts together and STL export

- [ ] **Step 1: Validate combined render**

```bash
"/c/Program Files/OpenSCAD (Nightly)/openscad.exe" dishwasher-button-cover.scad \
  --backend Manifold -D "render_part=\"both\"" \
  --render --summary all --summary-file - -o /tmp/dbc-both.stl 2>&1; echo "EXIT:$?"
```

Assert exit 0, `simple=true`.

- [ ] **Step 2: Export frame STL for slicing**

```bash
"/c/Program Files/OpenSCAD (Nightly)/openscad.exe" dishwasher-button-cover.scad \
  --backend Manifold -D "render_part=\"frame\"" \
  --render -o dishwasher-button-cover-FRAME.stl 2>&1; echo "EXIT:$?"
```

Assert EXIT:0. File `dishwasher-button-cover-FRAME.stl` created.

- [ ] **Step 3: Export cover STL for slicing**

```bash
"/c/Program Files/OpenSCAD (Nightly)/openscad.exe" dishwasher-button-cover.scad \
  --backend Manifold -D "render_part=\"cover\"" \
  --render -o dishwasher-button-cover-COVER.stl 2>&1; echo "EXIT:$?"
```

Assert EXIT:0. File `dishwasher-button-cover-COVER.stl` created.

- [ ] **Step 4: Demo images for both parts**

```bash
"/c/Program Files/OpenSCAD (Nightly)/openscad.exe" dishwasher-button-cover.scad \
  --backend Manifold -D "render_part=\"frame\"" \
  --render --camera=21,16,30,55,0,25,150 \
  -o demo-images/dbc-frame-top.png 2>&1; echo "EXIT:$?"

"/c/Program Files/OpenSCAD (Nightly)/openscad.exe" dishwasher-button-cover.scad \
  --backend Manifold -D "render_part=\"cover\"" \
  --render --camera=9,6.8,15,55,0,25,80 \
  -o demo-images/dbc-cover-top.png 2>&1; echo "EXIT:$?"
```

Both images should show clean geometry with no visual artefacts.

---

## Print Instructions (reference)

### Frame (`dishwasher-button-cover-FRAME.stl`)

| Setting | Value |
|---|---|
| Orientation | Panel face UP (flip in slicer so Z=0 face is at top) |
| Slicer pause | At z = **4.6mm** from bed |
| At pause | Insert 4× neodymium magnets (8mm × 2mm) into pockets. Check polarity: all must attract toward the dishwasher panel. Press firmly. Resume print. |
| Layer height | 0.2mm |
| Infill | 20% |
| Material | PLA or PETG |

### Cover (`dishwasher-button-cover-COVER.stl`)

| Setting | Value |
|---|---|
| Orientation | Panel face UP (cavity opens upward) |
| Layer height | 0.2mm |
| Infill | 30% |
| Material | Same as frame |

### Assembly

1. Slide cover into frame interior from the left end. Cover panel face and frame panel face must be on the same side.
2. Place assembly on dishwasher panel with magnets facing the metal surface.
3. Slide cover right to cover the button; slide left to expose it.

### Tolerance tuning

If cover slides too tightly, increase `slide_tolerance` from `0.2` to `0.3` and re-export. If cover is sloppy, decrease to `0.15`.

---

## Notes

**Magnet pocket geometry:** Pockets are recessed 0.4mm from the panel face (`magnet_skin`). When printed panel-face-up, the slicer pause at 4.6mm leaves the pockets fully formed and open at the current top surface. Resuming prints the final 0.4mm skin that encloses the magnets. The skin keeps the magnets from contacting the dishwasher panel directly (reduces scratching) while still providing strong hold through the thin plastic layer.

**No tongue/groove retention:** The cover is retained in Z primarily by the snug Y fit (0.2mm clearance per side) and by the magnetic force holding the whole assembly flush to the panel. Tongue/groove can be added if the cover rattles in Z when not on the dishwasher, but is unnecessary for in-use performance.
