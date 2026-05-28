// To render:
//   1. In pegstr.scad, comment out `pegstr();` and add `include <overrides/stanley-blades.scad>`
//   2. Run: "C:\Program Files\OpenSCAD (Nightly)\openscad.exe" pegstr.scad --backend Manifold -p pegstr.json -P stanley-blades -o stanley-blades.stl
//   3. Revert pegstr.scad

// Left bin (razor blade refills): 27mm wide x 23mm deep x 22mm tall
// Right bin (Stanley knife):      35mm wide x 23mm deep x 55mm tall
// holder_x_size must equal razor_bin_w + wall_thickness + stanley_bin_w = 27 + 2 + 35 = 64

razor_bin_w = 27;
razor_bin_h = 22;

wall     = wall_thickness;
floor_h  = closed_bottom * wall_thickness;

// pegstr() internally applies rotate([0,0,-90]) then translate([tx/2, 0, tz-clip_height/2]).
// All union() children must use the resulting world-space coordinates:
//   world X = build Y + tx/2   (horizontal, left-right)
//   world Y = -build X         (depth, wall-to-front)
//   world Z = build Z + (tz - clip_height/2)

// Interior world-space extents
int_left_x  = tx / 2 - holder_x_size_actual / 2;  // left edge of interior
int_y_ctr   = wall + holder_y_size / 2;            // depth centre
int_z_bot   = tz - holder_z_size_actual + floor_h; // floor surface
int_z_top   = tz;                                  // top of holder
int_height  = int_z_top - int_z_bot;
int_z_ctr   = (int_z_bot + int_z_top) / 2;

// Divider wall between the two bins
div_x_ctr = int_left_x + razor_bin_w + wall / 2;

// Raised floor in left (razor blade) bin
razor_x_ctr      = int_left_x + razor_bin_w / 2;
fill_h            = int_height - razor_bin_h;
razor_floor_z_ctr = int_z_bot + fill_h / 2;

render()
  union() {
    pegstr();

    // Divider wall separating the two bins
    translate([div_x_ctr, int_y_ctr, int_z_ctr])
      cube([wall, holder_y_size + 2 * epsilon, int_height + 2 * epsilon], center = true);

    // Raised floor in the razor blade bin (makes cavity only razor_bin_h deep from top)
    translate([razor_x_ctr, int_y_ctr, razor_floor_z_ctr])
      cube([razor_bin_w + 2 * epsilon, holder_y_size + 2 * epsilon, fill_h + 2 * epsilon], center = true);
  }
