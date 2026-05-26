include <../lib/bins.scad>

render()
  difference() {
    pegstr();

    // double width
    bin_interior(0.5, 1);
    bin_interior(2.5, 1);
    bin_interior(4.5, 1);
    bin_interior(6.5, 1);
    bin_interior(7.5, 1);

    // double depth

    // 20mm bin row
    bin_height(y=1, h=20);
  }
