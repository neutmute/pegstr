// Garden Shears Holder
//
// A solid plate with two through-holes. Blades drop DOWN through the holes;
// the widest part of each shear (handles) rests on the plate lip.
//   Rear hole (closest to wall): 60mm wide x 24mm deep (X x Y)
//   Front hole:                  35mm wide x 24mm deep (X x Y)
//   Plate thickness:             20mm (Z)
//
// To render, temporarily edit pegstr.scad:
//   1. Comment out:  pegstr();
//   2. Uncomment:    include <overrides/bins-garden-shears.scad>
//
// Render:
//   openscad-nightly pegstr.scad --backend Manifold -p pegstr.json -P garden-shears -o garden-shears.stl
//
// Revert pegstr.scad after rendering.

plate_z = 20;

module garden_plate() {
    translate([tx/2, ty/2, tz - plate_z/2])
        cube([tx, ty, plate_z + epsilon], center=true);
}

module shear_holes() {
    // Rear hole (row 0, closest to wall): 60mm wide
    translate([tx/2, wall_thickness + holder_y_size/2, tz - plate_z/2])
        cube([60 + epsilon, holder_y_size + epsilon, plate_z + epsilon], center=true);

    // Front hole (row 1): 35mm wide
    translate([tx/2, 2*wall_thickness + 3*holder_y_size/2, tz - plate_z/2])
        cube([42 + epsilon, holder_y_size + epsilon, plate_z + epsilon], center=true);
}

render()
    difference() {
        union() {
            pegstr();
            garden_plate();
        }
        shear_holes();
    }
