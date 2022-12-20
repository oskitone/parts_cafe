module perfboard(
    width = 4 * 25.4,
    length = 4 * 25.4,
    height = 2,

    pitch = 2.54,
    hole_diameter = 1.5
) {
    e = .05821;

    difference() {
        cube([width, length, height]);

        for (ix = [0 : ceil(width / pitch)]) {
            translate([ix * pitch, 0, 0]) {
                render() {
                    for (iy = [0 : ceil(length / pitch)]) {
                        translate([0, iy * pitch, -e]) {
                            cylinder(
                                d = hole_diameter,
                                h = height + e * 2
                            );
                        }
                    }
                }
            }
        }
    }
}

perfboard();
