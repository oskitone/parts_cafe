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