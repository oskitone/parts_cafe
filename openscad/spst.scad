SPST_BASE_DIMENSIONS = [6,6,3.45];

SPST_ACTUATOR_DIAMETER = 3.5;
SPST_ACTUATOR_HEIGHT_OFF_PCB = 6;

SPST_MAX_TRAVEL = .5;
SPST_CONSERVATIVE_TRAVEL = 1;

SPST_PLOT = 2.54 * 3;

module spst(
    base_dimensions = SPST_BASE_DIMENSIONS,
    actuator_diameter = SPST_ACTUATOR_DIAMETER,
    actuator_height_including_base = SPST_ACTUATOR_HEIGHT_OFF_PCB
) {
    e = .01491;

    translate([base_dimensions.x / -2, base_dimensions.y / -2, 0]) {
        cube(base_dimensions);
    }

    translate([0, 0, base_dimensions.z - e]) {
        cylinder(
            d = actuator_diameter,
            h = actuator_height_including_base - base_dimensions.z + e
        );
    }
}