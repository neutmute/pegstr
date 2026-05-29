hole_wiggle = 0.5;
render_holder = false;
render_text = true;
text_size = 7;
text_depth = 1;

// [shaft_diameter_mm, long_arm_length_mm]
// Row 0 = back (closest to wall), Row 1 = front. Col 3 of row 1 is intentionally absent.
keys = [
  [[2.0, 49], [2.5, 56], [3.0, 60], [4.0, 70]],
  [[5.0, 80], [6.0, 90], [8.0, 100]],
];

module key_holes() {
  for (row = [0:len(keys)-1]) {
    for (col = [0:len(keys[row])-1]) {
      d = keys[row][col][0];
      l = keys[row][col][1];
      world_x = wall_thickness + col * (wall_thickness + holder_x_size_actual) + holder_x_size_actual / 2;
      world_y = wall_thickness + row * (wall_thickness + holder_y_size) + holder_y_size / 2;
      translate([world_x, world_y, tz - l / 2])
        cylinder(h=l + epsilon, d=d + hole_wiggle, center=true, $fn=$fn);
    }
  }
}

module key_labels() {
  for (row = [0:len(keys)-1]) {
    for (col = [0:len(keys[row])-1]) {
      d = keys[row][col][0];
      world_x = wall_thickness + col * (wall_thickness + holder_x_size_actual) + holder_x_size_actual / 2;
      world_z = tz - holder_z_size_actual + text_size * 2 + row * (text_size + 2);
      translate([world_x, ty + epsilon, world_z])
        rotate([90, 0, 0])
          linear_extrude(height=text_depth + epsilon)
            text(str(d), size=text_size, halign="center", valign="center");
    }
  }
}

if (render_holder) {
  difference() {
    union() {
      pegstr();
      color("lightblue")
        translate([tx / 2, ty / 2, tz - holder_z_size_actual / 2])
          cube([tx, ty, holder_z_size_actual], center=true);
    }
    key_holes();
    key_labels();
  }
}

if (render_text) {
  key_labels();
}
