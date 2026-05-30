hole_wiggle = 1.0;
countersink = 1.25;

// [diameter, depth] — row (depth from board), col (left to right)
bits = [
  [[7.0, 45], [8.5, 45]],
  [[9.5, 45], [10.0, 45]],
  [[10.0, 45], [10.0, 45]],
];

union() {
  pegstr();

  for (row = [0:1:len(bits) - 1]) {
    for (col = [0:1:holder_x_count - 1]) {

      d = bits[row][col][0];
      dw = d + hole_wiggle;
      l = bits[row][col][1];

      translate(v=[
        -holder_offset - holder_y_size / 2 - wall_thickness - row * (holder_y_size + wall_thickness),
        (col + 0.5 - holder_x_count / 2) * (holder_x_size + wall_thickness),
        holder_z_size / 2 - clip_height / 2,
      ]) {
        // open_gap = unfilled cell above the fill cylinder top (tz - holder_z_size + clip_height/2)
        // fill_hole_depth = portion of total depth l that falls within the fill cylinder
        open_gap = tz - holder_z_size + clip_height / 2;
        fill_hole_depth = l - open_gap;

        difference() {
          cylinder(h=holder_z_size, d=holder_x_size + wall_thickness, center=true, $fn=holder_sides);

          // hole from fill top downward fill_hole_depth mm — floor at fill_top - fill_hole_depth
          translate(v=[0, 0, holder_z_size / 2 - fill_hole_depth / 2])
            cylinder(h=fill_hole_depth, d=dw, center=true, $fn=holder_sides * 2);

          // countersink at fill top (bit entry into fill)
          translate(v=[0, 0, (holder_z_size - countersink) / 2])
            cylinder(h=countersink, d1=dw + countersink, d2=dw, center=true, $fn=holder_sides * 2);
        }
      }
    }
  }
}
