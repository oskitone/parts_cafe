MINI_HOT_GLUE_STICK_DIAMETER = 7; // aka 1/4"
MINI_HOT_GLUE_STICK_LENGTH = 25.4 * 4;

LIGHTPIPE_DIAMETER = MINI_HOT_GLUE_STICK_DIAMETER;
LIGHTPIPE_LENGTH = 25.4 / 8;
LIGHTPIPE_LENGTH_STRING = "1/8\"";

module lightpipe(
    length = LIGHTPIPE_LENGTH,
    diameter = LIGHTPIPE_DIAMETER
) {
    cylinder(
        h = length,
        d = diameter
    );
}

module lightpipe_fixture(
    height = LIGHTPIPE_LENGTH,
    wall = ENCLOSURE_INNER_WALL,
    shim_width = 1,
    shim_length = .2,
    shim_count = 3,
) {
    inner_diameter =  LIGHTPIPE_DIAMETER + shim_length * 2;
    outer_diameter = inner_diameter + wall * 2;

    ring(
        diameter = outer_diameter,
        height = height,
        inner_diameter = inner_diameter
    );

    for (i = [0 : shim_count - 1]) {
        rotate([0, 0, (360 / shim_count) * i]) {
            translate([
                shim_width / -2,
                inner_diameter / 2 - shim_length,
                0
            ]) {
                cube([
                    shim_width,
                    shim_length,
                    height
                ]);
            }
        }
    }
}