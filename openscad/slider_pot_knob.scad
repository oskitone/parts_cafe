include <enclosure.scad>;
include <flat_top_rectangular_pyramid.scad>;
include <rib_cavities.scad>;
include <rounded_cube.scad>;
include <slider_pot.scad>;

module slider_pot_knob(
    dimensions = [
        SLIDER_POT_BASE_DIMENSIONS.x,
        SLIDER_POT_ACTUATOR_DIMENSIONS.y + ENCLOSURE_WALL * 2,
        SLIDER_POT_ACTUATOR_DIMENSIONS.z + ENCLOSURE_FLOOR_CEILING
    ],

    fillet = 1,

    xy_clearance = .2,
    z_clearance = 0,

    slider_pot_base_dimensions = SLIDER_POT_BASE_DIMENSIONS,
    slider_pot_actuator_dimensions = SLIDER_POT_ACTUATOR_DIMENSIONS,
    slider_pot_travel = SLIDER_POT_TRAVEL,
    slider_pot_actuator_position = 0,

    outer_color = undef,
    cavity_color = undef,

    tolerance = 0,

    debug = false,
    center = true
) {
    e = .0235;

    actuator_cavity_dimensions = [
        slider_pot_actuator_dimensions.x + (tolerance + xy_clearance) * 2,
        slider_pot_actuator_dimensions.y + (tolerance + xy_clearance) * 2,
        slider_pot_actuator_dimensions.z + z_clearance + e
    ];

    module _output() {
        difference() {
            color(outer_color) {
                rounded_cube(dimensions, fillet);
            }

            color(cavity_color) {
                rib_cavities(
                    width = dimensions.x,
                    length = dimensions.y,
                    depth = DEFAULT_RIB_SIZE,
                    rib_length = DEFAULT_RIB_SIZE,
                    gutter = DEFAULT_RIB_GUTTER,
                    z = dimensions.z - DEFAULT_RIB_SIZE
                );

                translate([
                    (dimensions.x - actuator_cavity_dimensions.x) / 2,
                    (dimensions.y - actuator_cavity_dimensions.y) / 2,
                    -e
                ]) {
                    cube(actuator_cavity_dimensions);
                }

                if (debug) {
                    translate([
                        dimensions.x / 2,
                        -e,
                        -e
                    ]) {
                        cube([
                            dimensions.x / 2 + e,
                            dimensions.y + e * 2,
                            dimensions.z + e * 2,
                        ]);
                    }
                }
            }
        }

        if (debug) {
            translate([
                (dimensions.x - slider_pot_base_dimensions.x) / 2,
                (dimensions.y - slider_pot_actuator_dimensions.y) / 2
                    - get_slider_pot_actuator_y(
                        base_dimensions = slider_pot_base_dimensions,
                        actuator_dimensions = slider_pot_actuator_dimensions,
                        travel = slider_pot_travel,
                        actuator_position = slider_pot_actuator_position
                    ),
                -slider_pot_base_dimensions.z
            ]) {
                % slider_pot(
                    base_dimensions = slider_pot_base_dimensions,
                    actuator_dimensions = slider_pot_actuator_dimensions,
                    travel = slider_pot_travel,
                    actuator_position = slider_pot_actuator_position
                );
            }
        }
    }

    translate(
        center
            ? [
                dimensions.x / -2,
                dimensions.y / -2,
                -e
            ]
            : [0,0,0]
    ) {
        _output();
    }
}

* slider_pot_knob(
    slider_pot_actuator_position = abs(($t - 1/2) * 2),
    debug = 1,
    tolerance = .1
);