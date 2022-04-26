/* https://www.ckswitches.com/media/1428/os.pdf */

SWITCH_BASE_WIDTH = 4.4;
SWITCH_BASE_LENGTH = 8.7;
SWITCH_BASE_HEIGHT = 4.7; // measured from PCB

SWITCH_ACTUATOR_WIDTH = 2;
SWITCH_ACTUATOR_LENGTH = 2.1;
SWITCH_ACTUATOR_HEIGHT = 3.8;
SWITCH_ACTUATOR_TRAVEL = 1.5;

SWITCH_ORIGIN = [SWITCH_BASE_WIDTH / -2, -6.36, 0];

module switch(
    position = 0,

    base_width = SWITCH_BASE_WIDTH,
    base_length = SWITCH_BASE_LENGTH,
    base_height = SWITCH_BASE_HEIGHT,

    actuator_width = SWITCH_ACTUATOR_WIDTH,
    actuator_length = SWITCH_ACTUATOR_LENGTH,
    actuator_height = SWITCH_ACTUATOR_HEIGHT,
    actuator_travel = SWITCH_ACTUATOR_TRAVEL,

    origin = SWITCH_ORIGIN
) {
    e = .05234;

    translate([origin.x, origin.y, origin.z]) {
        cube([base_width, base_length, base_height]);

        if (actuator_height > 0) {
            translate([
                (base_width - actuator_width) / 2,
                (base_length - actuator_length) / 2
                    - actuator_travel / 2
                    + actuator_travel * position,
                base_height - e
            ]) {
                cube([actuator_width, actuator_length, actuator_height + e]);
            }
        }
    }
}
