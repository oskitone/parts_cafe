module rounded_xy_cube(dimensions, radius = 0) {
    if (radius > 0) {
        hull() {
            for (x = [radius, dimensions[0] - radius]) {
                for (y = [radius, dimensions[1] - radius]) {
                    translate([x, y, 0]) {
                        cylinder(r = radius, h = dimensions[2]);
                    }
                }
            }
        }
    } else {
        cube(dimensions);
    }
}
