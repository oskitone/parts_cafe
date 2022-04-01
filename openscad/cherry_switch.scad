// https://cdn.sparkfun.com/datasheets/Components/Switches/MX%20Series.pdf
// https://www.cherrymx.de/en/dev.html

CHERRY_SWITCH_BASE_WIDTH = 15.6;
CHERRY_SWITCH_BASE_LENGTH = 15.6;
CHERRY_SWITCH_BASE_HEIGHT = 11.6;

CHERRY_SWITCH_ACTUATOR_PLATE_WIDTH = 7; // TODO: measure
CHERRY_SWITCH_ACTUATOR_PLATE_LENGTH = 5; // TODO: measure

CHERRY_SWITCH_STEM_HORIZONTAL_WEB_DEPTH = 1.17 - .07 * 2; // TODO: measure
CHERRY_SWITCH_STEM_VERTICAL_WEB_DEPTH = 1.17; // TODO: measure
CHERRY_SWITCH_RADIUS = .3; // TODO: use

CHERRY_SWITCH_STEM_WIDTH = 4.1; // TODO: measure
CHERRY_SWITCH_STEM_LENGTH = 5.1; // TODO: measure
CHERRY_SWITCH_STEM_HEIGHT = 3.6;

CHERRY_SWITCH_BASE_PLUNGE = 5;

CHERRY_SWITCH_PINS_CLEARANCE = 3.3;

CHERRY_SWITCH_TRAVEL = CHERRY_SWITCH_STEM_HEIGHT;

CHERRY_SWITCH_ORIGIN = [-10.25, -12.85];

module cherry_switch(
    base_width = CHERRY_SWITCH_BASE_WIDTH,
    base_length = CHERRY_SWITCH_BASE_LENGTH,
    base_height = CHERRY_SWITCH_BASE_HEIGHT,

    actuator_plate_width = CHERRY_SWITCH_ACTUATOR_PLATE_WIDTH,
    actuator_plate_length = CHERRY_SWITCH_ACTUATOR_PLATE_LENGTH,

    stem_horizontal_web_depth = CHERRY_SWITCH_STEM_HORIZONTAL_WEB_DEPTH,
    stem_vertical_web_depth = CHERRY_SWITCH_STEM_VERTICAL_WEB_DEPTH,
    radius = CHERRY_SWITCH_RADIUS,

    stem_width = CHERRY_SWITCH_STEM_WIDTH,
    stem_length = CHERRY_SWITCH_STEM_LENGTH,
    stem_height = CHERRY_SWITCH_STEM_HEIGHT,

    base_plunge = CHERRY_SWITCH_BASE_PLUNGE,

    pins_clearance = CHERRY_SWITCH_PINS_CLEARANCE,

    travel = CHERRY_SWITCH_TRAVEL,

    show_base = true,
    show_stem = true,

    center = false,

    position = 0
) {
    e = .01;

    module _stem_web(rotation, depth, size, height) {
        translate([stem_width / 2, stem_length / 2, 0]) {
            rotate([0, 0, rotation]) {
                translate([depth / -2, size / -2, 0]) {
                    cube([depth, size, height]);
                }
            }
        }
    }

    module _base() {
        difference() {
            cube([base_width, base_length, base_height]);

            translate([
                (base_width - actuator_plate_width) / 2,
                (base_length - actuator_plate_length) / 2,
                base_height - travel
            ]) {
                cube([
                    actuator_plate_width,
                    actuator_plate_length,
                    travel + e
                ]);
            }
        }
    }

    module _stem() {
        translate([
            (base_width - stem_width) / 2,
            (base_length - stem_length) / 2,
            base_height - position * travel - travel
        ]) {
            _stem_web(
                0,
                stem_horizontal_web_depth,
                stem_width,
                travel + stem_height - e
            );
            _stem_web(
                90,
                stem_vertical_web_depth,
                stem_length,
                travel + stem_height - e
            );
        }
    }

    function get_xy(value) = (center ? value / -2 : 0);

    translate([get_xy(base_width), get_xy(base_length), 0]) {
        if (show_base) {
            _base();
        }

        if (show_stem) {
            _stem();
        }
    }
}
