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
        cube([35 + epsilon, holder_y_size + epsilon, slot_z + epsilon], center=true);
}

render()
    difference() {
        pegstr();
        shear_slots();
    }
