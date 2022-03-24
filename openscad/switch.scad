/* https://www.ckswitches.com/media/1428/os.pdf */
SWITCH_BASE_WIDTH = 4.4;
SWITCH_BASE_LENGTH = 8.7;
SWITCH_BASE_HEIGHT = 4.5;
SWITCH_ACTUATOR_WIDTH = 2;
SWITCH_ACTUATOR_LENGTH = 2.1;
SWITCH_ACTUATOR_HEIGHT = 3.8;
SWITCH_ACTUATOR_TRAVEL = 1.5;
SWITCH_ORIGIN = [SWITCH_BASE_WIDTH / 2, 6.36];

module switch(position = 0) {
    e = .05234;

    translate([-SWITCH_ORIGIN.x, -SWITCH_ORIGIN.y, 0]) {
        cube([
            SWITCH_BASE_WIDTH,
            SWITCH_BASE_LENGTH,
            SWITCH_BASE_HEIGHT
        ]);

        translate([
            (SWITCH_BASE_WIDTH - SWITCH_ACTUATOR_WIDTH) / 2,
            (SWITCH_BASE_LENGTH - SWITCH_ACTUATOR_LENGTH) / 2
                - SWITCH_ACTUATOR_TRAVEL / 2
                + SWITCH_ACTUATOR_TRAVEL * position,
            SWITCH_BASE_HEIGHT - e
        ]) {
            cube([
                SWITCH_ACTUATOR_WIDTH,
                SWITCH_ACTUATOR_LENGTH,
                SWITCH_ACTUATOR_HEIGHT + e
            ]);
        }
    }
}
