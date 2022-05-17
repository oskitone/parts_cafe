/* SJ1-3525NG */

HEADPHONE_JACK_WIDTH = 12;
HEADPHONE_JACK_LENGTH = 11;
HEADPHONE_JACK_HEIGHT = 5;

HEADPHONE_JACK_BRIM_WIDTH = 9;
HEADPHONE_JACK_BRIM_LENGTH = 1;

HEADPHONE_JACK_BARREL_LENGTH = 3;
HEADPHONE_JACK_BARREL_DIAMETER = 6;

HEADPHONE_JACK_BARREL_Z = HEADPHONE_JACK_HEIGHT / 2;

module headphone_jack(
    width = HEADPHONE_JACK_WIDTH,
    length = HEADPHONE_JACK_LENGTH,
    height = HEADPHONE_JACK_HEIGHT,

    brim_width = HEADPHONE_JACK_BRIM_WIDTH,
    brim_length = HEADPHONE_JACK_BRIM_LENGTH,

    barrel_length = HEADPHONE_JACK_BARREL_LENGTH,
    barrel_diameter = HEADPHONE_JACK_BARREL_DIAMETER,

    barrel_z = HEADPHONE_JACK_BARREL_Z,
) {
    e = .0341;

    cube([width, length, height]);

    translate([(width - brim_width) / 2, length - e, 0]) {
        cube([brim_width, brim_length + e, height]);
    }

    translate([width / 2, length - e, barrel_z]) {
        rotate([-90, 0, 0]) {
            cylinder(d = barrel_diameter, h = barrel_length + e);
        }
    }
}
