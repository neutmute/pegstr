// Dishwasher Button Cover
// Horseshoe-shaped ring with closed top, held by 3 embedded magnets.
// Gap faces -Y (front). Inner radius 9mm, outer radius 17mm.

inner_r        = 9;    // inner radius of ring
outer_r        = 17;   // outer radius of ring
ring_h         = 12;   // height of ring walls
cover_t        = 2;    // top cover plate thickness
opening_angle  = 90;   // gap angle for the horseshoe opening
cover_angle    = 360;  // top cover sweep: 360 = full circle, use arc_angle to match horseshoe

tdc_clock      = 12;   // clock position of TDC mark (1–12); 12 = top, 3 = right
tdc_depth      = 0.5;    // depth of TDC dimple
tdc_d          = 3;    // diameter of TDC dimple
tdc_inset      = 2;    // distance from outer edge to dimple centre

magnet_d       = 6;    // magnet diameter
magnet_depth   = 2.7;  // magnet pocket depth
magnet_fit     = 0.2;  // radial clearance
magnet_floor   = 1.5;  // solid floor below each pocket (pause-and-place layer)
magnet_spacing = 80;   // degrees between adjacent magnets

$fn = 64;

wall_t      = outer_r - inner_r;   // 8 mm wall
arc_angle   = 360 - opening_angle; // 270° solid arc
// Gap centred at 270° (-Y). Arc starts at 315° and sweeps 270° CCW.
start_angle = 270 + opening_angle / 2;

// 3 magnets centred on the arc midpoint, separated by magnet_spacing degrees
arc_mid = start_angle + arc_angle / 2;
m1 = arc_mid - magnet_spacing;
m2 = arc_mid;
m3 = arc_mid + magnet_spacing;

// --- Ring walls (horseshoe arc) ---
module horseshoe_walls() {
    rotate([0, 0, start_angle])
    rotate_extrude(angle = arc_angle, $fn = $fn)
        translate([inner_r, 0])
            square([wall_t, ring_h]);
}

// --- Top cover plate ---
module top_cover() {
    translate([0, 0, ring_h])
    rotate_extrude(angle = cover_angle, $fn = $fn)
        square([outer_r, cover_t]);
}

// --- Vertical magnet pocket with solid floor ---
// Opens from z = magnet_floor upward; printer pauses at that layer to insert magnets.
module magnet_pocket(angle) {
    wall_centre_r = (inner_r + outer_r) / 2;
    rotate([0, 0, angle])
    translate([wall_centre_r, 0, magnet_floor])
    cylinder(d = magnet_d + magnet_fit * 2, h = magnet_depth + 0.1, $fn = 32);
}

// --- TDC orientation dimple on top face ---
// Clock angle: 12 o'clock = 90°, 3 = 0°, 6 = 270°, 9 = 180°
module tdc_mark() {
    tdc_angle = 90 - tdc_clock * 30;
    tdc_r     = outer_r - tdc_inset;
    translate([cos(tdc_angle) * tdc_r, sin(tdc_angle) * tdc_r,
               ring_h + cover_t - tdc_depth])
    cylinder(d = tdc_d, h = tdc_depth + 0.1, $fn = 32);
}

// --- Final part ---
module button_cover() {
    difference() {
        union() {
            horseshoe_walls();
            top_cover();
        }
        magnet_pocket(m1);
        magnet_pocket(m2);
        magnet_pocket(m3);
        tdc_mark();
    }
}

button_cover();
