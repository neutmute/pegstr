include <../lib/bins.scad>

render()
  difference() {
    pegstr();

    // double width
    bin_interior(5.5, 0);

    bin_interior(3.5, 1);
    bin_interior(5.5, 1);

    bin_interior(0.5, 2);
    bin_interior(2.5, 2);
    bin_interior(4.5, 2);
    bin_interior(6.5, 2);

    // double depth

    bin_height(row=0, back_h=holder_z_size, front_h=holder_z_size - 12.5);
    bin_height(row=1, back_h=72.5, front_h=60);
    bin_height(row=2, back_h=25, front_h=12.5);
  }
