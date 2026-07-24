SPST_BASE_DIMENSIONS = [6,6,3.45];

SPST_ACTUATOR_DIAMETER = 3.5;
SPST_ACTUATOR_HEIGHT_OFF_PCB = 6;
SPST_ACTUATOR_GENEROUS_HEIGHT_OFF_PCB = 6.2;
SPST_ACTUATOR_HEIGHT = SPST_ACTUATOR_HEIGHT_OFF_PCB - SPST_BASE_DIMENSIONS.z;

SPST_MAX_TRAVEL = .5;
SPST_CONSERVATIVE_TRAVEL = 1;

SPST_PLOT = 2.54 * 3;

// Distance from pin 1 to actuator center
SPST_ORIGIN = [4.5 / 2, 6 / 2];
SPST_KICAD_FOOTPRINT_ORIGIN_TO_CENTER = [3.25, 2.25];

module spst(
    base_dimensions = SPST_BASE_DIMENSIONS,
    actuator_diameter = SPST_ACTUATOR_DIAMETER,
    actuator_height_including_base = SPST_ACTUATOR_HEIGHT_OFF_PCB,

    travel = SPST_CONSERVATIVE_TRAVEL,
    position = 0,

    show_base = true,
    show_actuator = true
) {
    e = .01491;

    if (show_base) {
        translate([base_dimensions.x / -2, base_dimensions.y / -2, 0]) {
            cube(base_dimensions);
        }
    }

    if (show_actuator) {
        translate([0, 0, base_dimensions.z - e]) {
            cylinder(
                d = actuator_diameter,
                h = actuator_height_including_base
                    - base_dimensions.z + e - position * travel
            );
        }
    }
}