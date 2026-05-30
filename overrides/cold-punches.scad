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
