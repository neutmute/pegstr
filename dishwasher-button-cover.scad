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
travel_distance   = 20;    // mm, how far cover slides left to expose button
cover_width       = 18;    // mm, width of sliding cover
interior_width    = cover_width + travel_distance;  // 38mm
frame_depth       = 5;     // mm, total depth from panel (Z)
wall_thickness    = 1.5;   // mm, cover front-face wall

// --- Magnets (8mm dia x 2mm thick neodymium, x4) ---
magnet_diameter   = 8;     // mm
magnet_height     = 2;     // mm
magnet_skin       = 0.4;   // mm, plastic skin on panel side over magnet

// --- Frame wall ---
frame_wall        = 2;     // mm, left and right wall thickness (also = right stopper thickness)

// --- Tolerances ---
slide_tolerance   = 0.2;   // mm clearance per side in Y (height axis) for smooth sliding

// --- Render ---
render_part = "both"; // "frame", "cover", "both"

// --- Derived (do not edit) ---
frame_w    = interior_width + frame_wall * 2;            // 42mm
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

        // Interior channel — starts at left wall inner face; cover slides in from left
        translate([frame_wall, bar_height, -epsilon])
            cube([interior_width, interior_height, frame_depth + epsilon * 2]);

        // Magnet pockets — open from Z=0 (panel face), with magnet_skin cap
        // Pocket spans Z=magnet_skin to Z=magnet_skin+magnet_height
        // Slicer pause at z_print=4.6mm from bed (= frame_depth - magnet_skin)
        for (bx = [magnet_x1, magnet_x2]) {
            for (by = [bottom_bar_cy, top_bar_cy]) {
                translate([bx, by, magnet_skin])
                    cylinder(d = magnet_diameter + 0.2, h = magnet_height + 0.1);
            }
        }
    }
}
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
