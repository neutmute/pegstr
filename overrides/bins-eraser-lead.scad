include <../lib/bins.scad>

render()
  difference() {
    pegstr();

    bin_height(row=0, back_h=holder_z_size, front_h=25);
  }
