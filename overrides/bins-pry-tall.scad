include <../lib/bins.scad>

render()
  difference() {
    pegstr();

    bin_interior(0.5, 0);
    bin_interior(1.5, 0);
    bin_interior(2.5, 0);
    bin_interior(3.5, 0);
    // bin_interior(4.5, 0);
    // bin_interior(5.5, 0);
    bin_interior(6.5, 0);
    bin_interior(7.5, 0);
    bin_interior(8.5, 0);
    bin_interior(9.5, 0);

    bin_height(row=1, back_h=holder_z_size, front_h=holder_z_size - 9);
  }
