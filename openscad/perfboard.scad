PERFBOARD_HEIGHT = 2;
PERFBOARD_PITCH = 2.54;
PERFBOARD_HOLE_DIAMETER = 1.5;

function get_pefboard_dimension(
    size,
    pitch = 2.54
) = (
    ceil(size / pitch) * pitch
);

module perfboard(
    width = 4 * 25.4,
    length = 4 * 25.4,
    height = PERFBOARD_HEIGHT,

    pitch = PERFBOARD_PITCH,
    hole_diameter = PERFBOARD_HOLE_DIAMETER,
    offset = 0
) {
    e = .05821;

    difference() {
        cube([width, length, height]);

        for (ix = [0 : ceil(width / pitch)]) {
            translate([(ix + offset) * pitch, 0, 0]) {
                render() {
                    for (iy = [0 : ceil(length / pitch)]) {
                        translate([0, (iy + offset) * pitch, -e]) {
                            cylinder(
                                d = hole_diameter,
                                h = height + e * 2,
                                $fn = 4
                            );
                        }
                    }
                }
            }
        }
    }
}

* perfboard();
