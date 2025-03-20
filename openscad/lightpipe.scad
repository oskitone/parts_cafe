LIGHTPIPE_DIAMETER = 7; // standard "mini" glue stick, 1/4 thick
LIGHTPIPE_LENGTH = 25.4 / 8;

module lightpipe(
    length = LIGHTPIPE_LENGTH,
    diameter = LIGHTPIPE_DIAMETER
) {
    cylinder(
        h = length,
        d = diameter
    );
}