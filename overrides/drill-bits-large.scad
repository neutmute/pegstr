hole_wiggle = 1.0;
countersink_h = 1.25;

// bits[row][col] = [diameter_mm, depth_mm]
// row 0 = back (closest to wall), row 2 = front
bits = [
  [[7.0, 45], [8.5, 45]],
  [[9.5, 45], [10.0, 45]],
  [[10.0, 45], [10.0, 45]],
];

difference() {
  union() {
    pegstr();
    for (row = [0:len(bits) - 1]) {
      for (col = [0:len(bits[row]) - 1]) {
        cx = wall_thickness + col * (wall_thickness + holder_x_size_actual) + holder_x_size_actual / 2;
        cy = wall_thickness + row * (wall_thickness + holder_y_size) + holder_y_size / 2;
        translate([cx, cy, tz - holder_z_size_actual / 2])
          cylinder(h=holder_z_size_actual, d=holder_x_size_actual + wall_thickness, center=true, $fn=$fn);
      }
    }
  }
  for (row = [0:len(bits) - 1]) {
    for (col = [0:len(bits[row]) - 1]) {
      d = bits[row][col][0];
      l = bits[row][col][1];
      dw = d + hole_wiggle;
      cx = wall_thickness + col * (wall_thickness + holder_x_size_actual) + holder_x_size_actual / 2;
      cy = wall_thickness + row * (wall_thickness + holder_y_size) + holder_y_size / 2;
      // hole from top (tz) downward l mm — floor at tz - l
      translate([cx, cy, tz - l / 2])
        cylinder(h=l + epsilon, d=dw, center=true, $fn=$fn);
      // countersink chamfer at entry
      translate([cx, cy, tz - countersink_h / 2])
        cylinder(h=countersink_h + epsilon, d1=dw, d2=dw + countersink_h, center=true, $fn=$fn);
    }
  }
}
