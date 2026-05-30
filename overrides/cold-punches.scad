hole_depth = 40;
hole_wiggle = 1;

// punch diameters left to right; hole_wiggle is added at cut time
punches = [8, 9, 9, 9, 12, 12];

difference() {
  union() {
    pegstr();
    for (col = [0:len(punches)-1]) {
      cx = wall_thickness + col * (wall_thickness + holder_x_size_actual) + holder_x_size_actual / 2;
      cy = wall_thickness + holder_y_size / 2; // single row — holder_y_count = 1
      translate([cx, cy, tz - holder_z_size_actual / 2])
        cylinder(h=holder_z_size_actual, d=holder_x_size_actual + wall_thickness, center=true, $fn=$fn);
    }
  }
  for (col = [0:len(punches)-1]) {
    cx = wall_thickness + col * (wall_thickness + holder_x_size_actual) + holder_x_size_actual / 2;
    cy = wall_thickness + holder_y_size / 2; // single row — holder_y_count = 1
    translate([cx, cy, tz - hole_depth / 2])
      cylinder(h=hole_depth + epsilon, d=punches[col] + hole_wiggle, center=true, $fn=$fn);
  }
}
