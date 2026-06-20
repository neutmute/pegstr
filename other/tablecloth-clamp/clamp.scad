// https://makerworld.com/en/models/1127960-table-clip-generator-parametric-clamp?from=search#profileId-1127684

/* [Clamp Dimensions] */
// Top arm length (mm) 
top_arm_length   = 30; // [10:1:250]
// Lower arm length (mm) 
lower_arm_length = 25; // [10:1:250]
// Clamp height, i.e. distance between arms (mm) 
clamp_height = 13; // [5:1:250]
// Width of the clamp (mm)
clamp_width   = 20; // [5:1:100]
// Thickness of the clamp, i.e. more increases stability
clamp_thickness = 2; // [1:0.5:6]

/* [Clamp Features] */
// Increases the grip by adding a pattern to the top arm
with_texture       = true;
// Use S‐curve for the lower arm when enabled; otherwise, a straight lower arm is used.
with_s_curve = true;
// Helps to avoid stress fractures by adding a stress relief on the corner of the lower arm
add_stress_relief = true;

// Increase the back wall height by 1 mm if texture is enabled.
effective_clamp_height = clamp_height + (with_texture ? 1 : 0);

/* --- Function: S-Curve Center Line --- */
function s_curve_y(x) = - (clamp_thickness / sqrt(3)) * sin(360 * x / lower_arm_length) + (clamp_thickness / 2);

/* --- Module: S-Curve Lower Arm --- */
module lower_arm_s_curve() {
  translate([clamp_thickness/2, clamp_thickness/2]) {
    num_segments = 100; // Increase for a smoother curve.
    union() {
      for (i = [0 : num_segments-1]) {
        x0 = lower_arm_length * i / num_segments;
        x1 = lower_arm_length * (i+1) / num_segments;
        y0 = s_curve_y(x0);
        y1 = s_curve_y(x1);
        hull() {
          translate([x0, y0])
            circle(r = clamp_thickness/2, $fn = 50);
          translate([x1, y1])
            circle(r = clamp_thickness/2, $fn = 50);
        }
      }
    }
  }
}

/* --- Module: Rounded Lower Arm (if S-curve is disabled) --- */
module lower_arm_rounded() {
  translate([0, 0]) {
    union() {
      square([lower_arm_length, clamp_thickness]);
      intersection() {
         translate([lower_arm_length, clamp_thickness/2])
           circle(r = clamp_thickness/2, $fn = 50);
         translate([lower_arm_length, 0])
           square([clamp_thickness, clamp_thickness]);
      }
    }
  }
}

/* --- Module: Rounded Top Arm --- */
module top_arm_rounded() {
  union() {
    square([top_arm_length, clamp_thickness]);
    intersection() {
      translate([top_arm_length, clamp_thickness/2])
        circle(r = clamp_thickness/2, $fn = 50);
      translate([top_arm_length, 0])
        square([clamp_thickness, clamp_thickness]);
    }
  }
}

difference() {
  $fn = 100;
  linear_extrude(height = clamp_width) {
    union() {
      // Lower Arm 
      if (with_s_curve)
        lower_arm_s_curve();
      else
        lower_arm_rounded();
      
      // Back Wall
      translate([0, clamp_thickness])
        square([clamp_thickness, effective_clamp_height]);
      
      // Top Arm
      translate([0, clamp_thickness + effective_clamp_height])
        top_arm_rounded();
      
      // Optional Texture on the Top Arm's Inner Side
      if (with_texture) {
        texture_length = top_arm_length - clamp_thickness;
        for (i = [0 : texture_length - 1]) {
          translate([clamp_thickness + i, clamp_thickness + effective_clamp_height]) {
            hull() {
              polygon(points = [[0, 0], [1, 0], [0.5, -1]]);
              translate([0.01, 0])
                polygon(points = [[0, 0], [1, 0], [0.5, -1]]);
            }
          }
        }
      }
    }
  }
  
  // Subtractive Stress Relief
  if (add_stress_relief) {
    if (with_s_curve) {
    translate([clamp_thickness*1.1, clamp_thickness*1.5])
      linear_extrude(height = clamp_width + 1)
        circle(r = clamp_thickness * 0.3);
    } else {
    translate([clamp_thickness*1.1, clamp_thickness*1])
      linear_extrude(height = clamp_width + 1)
        circle(r = clamp_thickness * 0.3);
    }
  }
}
