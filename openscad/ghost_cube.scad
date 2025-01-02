module ghost_cube(
    dimensions = [0,0,0],
    size = .1
) {
    width = dimensions.x;
    length = dimensions.y;
    height = dimensions.z;

    // top and bottom
    for (z = [0, height - size]) {
        for (y = [0, length - size]) {
            translate([0, y, z]) {
                cube([width, size, size]);
            }
        }

        for (x = [0, width - size]) {
            translate([x, 0, z]) {
                cube([size, length, size]);
            }
        }
    }

    // sides
    for (x = [0, width - size]) {
        for (y = [0, length - size]) {
            translate([x, y, 0]) {
                cube([size, size, height]);
            }
        }
    }
}

* ghost_cube([10,20,30]);