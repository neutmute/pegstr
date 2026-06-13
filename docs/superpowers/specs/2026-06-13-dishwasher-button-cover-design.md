# Dishwasher Button Safety Cover — Design Spec

**Date:** 2026-06-13
**Status:** Approved

## Purpose

A 3D-printed safety cover that prevents a dishwasher button from being accidentally pressed when someone leans against the appliance. The cover slides left to expose the button and right to cover it. It attaches to the dishwasher panel via embedded neodymium magnets — no drilling, no adhesive.

---

## Physical Constraints

| Constraint | Value |
|---|---|
| Button diameter | 12mm |
| Button protrusion from panel | ~2mm |
| Clearance above button edge | 10mm max |
| Clearance below button edge | 11mm max |
| Clearance to the right of button edge | 5mm max |
| Clearance to the left | unlimited |
| Print method | FDM (slicer pause for magnet insertion) |

---

## Design: Closed-Frame Approach

Two printed parts:

1. **Frame** — mounts to the dishwasher panel via magnets. Has top bar, bottom bar, and right wall. Left end is open; the cover slides in from the left.
2. **Cover** — slides left-right inside the frame. Rightmost position covers the button; leftmost exposes it. The right wall of the frame acts as the stopper preventing the cover from leaving the rail to the right.

---

## Dimensions

### Frame

| Property | Value |
|---|---|
| Overall width | 42mm |
| Overall height | 32mm (9mm top bar + 14mm interior + 9mm bottom bar) |
| Depth (protrusion from panel) | 5mm |
| Top bar ceiling | 10mm above button top edge (at limit) |
| Bottom bar floor | 10mm below button bottom edge (within 11mm limit) |
| Right wall thickness | 2mm |
| Left wall thickness | 2mm |
| Interior width | 38mm |
| Interior height | 14mm |

#### Magnet Pockets (in top and bottom bars)

- **Magnet spec:** 8mm diameter × 2mm thick neodymium (cylindrical)
- **Quantity:** 4 total — 2 in top bar, 2 in bottom bar
- **Pocket dimensions:** 8.2mm diameter × 2.1mm deep (slight oversize for press-fit)
- **Panel-side skin:** 0.4mm material between magnet face and panel-facing surface of bar
- **Pocket spacing:** approximately 1/3 and 2/3 along bar length (roughly x=10mm and x=30mm from frame left edge)
- **Insertion method:** pause print at the layer where pockets are enclosed, insert magnets, resume

#### Slide Channel

Each bar has a 1.2mm wide × 0.6mm deep groove on its interior face, running the full width of the frame. This retains the cover against the panel while allowing smooth horizontal sliding.

### Cover

| Property | Value |
|---|---|
| Width | 18mm |
| Height | 13.4mm (14mm interior − 0.3mm clearance each side) |
| Depth | 4.5mm (3mm cavity + 1.5mm front wall) |
| Cavity (panel-facing side) | 13mm diameter × 3mm deep circular recess |

The cavity provides 3mm clearance over the button protrusion (1mm margin above the 2mm protrusion). The cover has 1mm wide × 0.5mm tall tongues on its top and bottom edges that engage the frame bar grooves.

### Cover Travel

| Position | Description |
|---|---|
| Rightmost (covered) | Cover right edge against frame right wall inner face. Button is fully hidden under cover. |
| Leftmost (exposed) | Cover slides ~20mm left. Button fully exposed; 5mm margin beyond button left edge. |

Total designed travel: 20mm. Interior width (38mm) = cover width (18mm) + travel (20mm).

---

## Coordinate Reference

The button centre is the natural origin for all placement in OpenSCAD. World-space positions relative to button centre:

| Feature | Position |
|---|---|
| Frame right wall outer face | +11mm (button_x + 6mm radius + 5mm clearance) |
| Frame right wall inner face | +9mm |
| Frame interior right | +9mm |
| Frame interior left | −29mm |
| Frame left wall outer face | −31mm |
| Frame top bar top | +16mm (button_y + 6mm + 10mm) |
| Frame bottom bar bottom | −16mm (button_y − 6mm − 10mm) |
| Frame interior top | +7mm |
| Frame interior bottom | −7mm |

The frame itself does not need to know where the button is — it is positioned by the user when placing it on the dishwasher. The OpenSCAD model is centred on the frame's geometric centre for ease of printing.

---

## OpenSCAD File Plan

**File:** `dishwasher-button-cover.scad`

The model will be parametric with the following top-level variables:

```
button_diameter      = 12;   // mm
button_protrusion    = 2;    // mm
cover_clearance      = 3;    // mm internal cavity depth
wall_thickness       = 1.5;  // mm (front face of cover, bar faces)
bar_height           = 9;    // mm (fits 8mm magnet + 0.5mm walls each side)
interior_height      = 14;   // mm
interior_width       = 38;   // mm (cover_width + travel)
cover_width          = 18;   // mm
right_clearance      = 5;    // mm (right of button edge)
frame_depth          = 5;    // mm (protrusion from panel)
magnet_diameter      = 8;    // mm
magnet_height        = 2;    // mm
magnet_skin          = 0.4;  // mm (panel-side skin over magnet)
slide_tolerance      = 0.3;  // mm clearance each side
groove_width         = 1.2;  // mm
groove_depth         = 0.6;  // mm
tongue_width         = 1.0;  // mm
tongue_height        = 0.5;  // mm
$fn                  = 64;
```

Two top-level modules:
- `frame()` — builds the closed frame with bar channels, right-wall stopper, and magnet pockets
- `cover()` — builds the sliding cover with cavity and tongues

A top-level render switch (e.g. `render_part = "frame"` / `"cover"` / `"both"`) controls which part is output for slicing.

---

## Print Notes

- **Material:** PLA or PETG; PETG preferred for slight flex in tongues
- **Layer height:** 0.2mm recommended
- **Infill:** 20% for frame, 30% for cover
- **Orientation:** both parts print flat (panel-facing side down)
- **Magnet pause:** frame requires a slicer pause at the layer that closes the magnet pockets (~layer at z = magnet_skin). Insert all 4 magnets before resuming. Verify polarity all magnets face the same direction (all attract toward panel).
- **Tolerance tuning:** if cover is too tight, increase `slide_tolerance` by 0.1mm increments

---

## Out of Scope

- Labelling / text on cover face
- Locking mechanism (e.g. twist-lock)
- Left-end stopper (left end intentionally open for cover removal)
