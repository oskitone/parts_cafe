// ex: ALPHA RA2031F-20-15DA-B100K

SLIDER_POT_BASE_DIMENSIONS = [9.5, 35, 6.5];
SLIDER_POT_ACTUATOR_DIMENSIONS = [1.8, 5, 15];
SLIDER_POT_TRAVEL = 20;

SLIDER_POT_KICAD_FOOTPRINT_ORIGIN_TO_CENTER = [
    SLIDER_POT_BASE_DIMENSIONS.x / -2,
    SLIDER_POT_BASE_DIMENSIONS.y / -2
];

function get_slider_pot_actuator_y(
    base_dimensions = SLIDER_POT_BASE_DIMENSIONS,
    actuator_dimensions = SLIDER_POT_ACTUATOR_DIMENSIONS,
    travel = SLIDER_POT_TRAVEL,

    actuator_position = 0
) = (
    (base_dimensions.y - actuator_dimensions.y) / 2
        + travel * actuator_position
        - travel / 2
);

module slider_pot(
    base_dimensions = SLIDER_POT_BASE_DIMENSIONS,
    actuator_dimensions = SLIDER_POT_ACTUATOR_DIMENSIONS,
    travel = SLIDER_POT_TRAVEL,

    actuator_position = 0
) {
    e = .025;

    cube(base_dimensions);

    translate([
        (base_dimensions.x - actuator_dimensions.x) / 2,
        get_slider_pot_actuator_y(
            base_dimensions = base_dimensions,
            actuator_dimensions = actuator_dimensions,
            travel = travel,
            actuator_position = actuator_position
        ),
        base_dimensions.z - e
    ]) {
        cube([
            actuator_dimensions.x,
            actuator_dimensions.y,
            actuator_dimensions.z + e
        ]);
    }
}

* slider_pot(actuator_position = $t);