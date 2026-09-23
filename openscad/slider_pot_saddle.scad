include <slider_pot.scad>;


module slider_pot_saddle(
    dimensions = [14, 40, 8],

    z_from_pcb = 0,
    actuator_clearance = .4,

    slider_pot_base_dimensions = SLIDER_POT_BASE_DIMENSIONS,
    slider_pot_actuator_dimensions = SLIDER_POT_ACTUATOR_DIMENSIONS,
    slider_pot_travel = SLIDER_POT_TRAVEL,
    slider_pot_actuator_position = 0,

    outer_color = undef,
    cavity_color = undef,

    tolerance = 0,

    debug = false
) {
    e = .0124;

    cavity_dimensions = [
        slider_pot_base_dimensions.x + tolerance * 2,
        slider_pot_base_dimensions.y + tolerance * 2,
        slider_pot_base_dimensions.z
    ];

    actuator_cavity_dimensions = [
        slider_pot_actuator_dimensions.x + (actuator_clearance + tolerance) * 2,
        slider_pot_actuator_dimensions.y + (actuator_clearance + tolerance) * 2
            + slider_pot_travel,
        dimensions.z
    ];

    module _center(_dimensions, z = -e) {
        translate([
            (dimensions.x - _dimensions.x) / 2,
            (dimensions.y - _dimensions.y) / 2,
            z
        ]) {
            children();
        }
    }

    translate([
        (slider_pot_base_dimensions.x - dimensions.x) / 2,
        (slider_pot_base_dimensions.y - dimensions.y) / 2,
        0
    ]) {
        difference() {
            color(outer_color) {
                translate([0, 0, z_from_pcb]) {
                    cube(dimensions);
                }
            }

            color(cavity_color) {
                _center(cavity_dimensions) {
                    cube([
                        cavity_dimensions.x,
                        cavity_dimensions.y,
                        cavity_dimensions.z + e * 2
                    ]);
                }

                _center(actuator_cavity_dimensions, z_from_pcb) {
                    cube([
                        actuator_cavity_dimensions.x,
                        actuator_cavity_dimensions.y,
                        actuator_cavity_dimensions.z + e * 2
                    ]);
                }

                if (debug) {
                    translate([
                        dimensions.x / 2,
                        -e,
                        z_from_pcb - e
                    ]) {
                        cube([
                            dimensions.x / 2 + e,
                            dimensions.y + e * 2,
                            dimensions.z + e * 2
                        ]);
                    }
                }
            }
        }
    }

    if (debug) {
        % # slider_pot(
            base_dimensions = slider_pot_base_dimensions,
            actuator_dimensions = slider_pot_actuator_dimensions,
            travel = slider_pot_travel,
            actuator_position = slider_pot_actuator_position
        );
    }
}

* slider_pot_saddle(
    dimensions = [20, 40, 2],
    z_from_pcb = SLIDER_POT_BASE_DIMENSIONS.z - 1,
    tolerance = .1,
    slider_pot_actuator_position = $t,
    debug = 1
);