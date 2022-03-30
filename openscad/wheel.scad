// TODO: extract parts to common repo
use <../../poly555/openscad/lib/basic_shapes.scad>;

include <pot.scad>;
include <rib_cavities.scad>;

module wheel(
    diameter = 20,
    height = 10,
    ring = 4,

    hub_ceiling = 1.8, // ENCLOSURE_FLOOR_CEILING
    hub_diameter = PTV09A_POT_ACTUATOR_DIAMETER + 1.2 * 2, // ENCLOSURE_INNER_WALL

    brodie_knob_diameter = 4,
    brodie_knob_stilt = 0,
    brodie_knob_count = 1,
    brodie_knob_angle_offset = 0,

    dimple_count = 0,
    dimple_depth = 1,
    dimple_y = undef,

    spokes_count = 6,
    spokes_width = 2,
    spokes_height = 5,

    chamfer = 1.2 - .5, // ENCLOSURE_INNER_WALL - BREAKAWAY_SUPPORT_DEPTH
    shim_size = .6,
    shim_count = 5,

    shaft_type = POT_SHAFT_TYPE_DEFAULT,

    grip_count = undef,

    test_fit = false,

    color = undef,
    cavity_color = undef,

    debug = false,

    tolerance = 0
) {
    e = 0.043;

    grip_count = grip_count != undef
        ? grip_count
        : round(
            diameter * PI / (DEFAULT_RIB_SIZE + DEFAULT_RIB_GUTTER)
        );

    module _hub() {
        if (!test_fit) {
            translate([0, 0, height - ring / 2]) {
                hull() {
                    donut(
                        diameter = hub_diameter,
                        thickness = ring,
                        segments = $preview ? 24 : 36
                    );
                }
            }
        }

        cylinder(
            d = hub_diameter,
            h = height - ring / 2
        );
    }

    module _tire() {
        module _donuts() {
            for (z = [ring / 2, height - ring / 2]) {
                translate([0, 0, z]) {
                    donut(
                        diameter = diameter,
                        thickness = ring,
                        segments = $preview ? 24 : 36
                    );
                }
            }
        }

        difference() {
            union() {
                if (spokes_count > 0) {
                    _donuts();
                } else {
                    hull() {
                        _donuts();
                    }
                }

                translate([0, 0, ring / 2]) {
                    ring(
                        diameter = diameter,
                        height = height - ring,
                        thickness = ring
                    );
                }
            }

            cylinder_grip(
                diameter = diameter,
                height = height,
                count = grip_count,
                size = .8,
                $fn = 6
            );
        }
    }

    module _pot_cavity() {
        module _chamfer() {
            translate([0, 0, -e]) {
                cylinder(
                    d1 = PTV09A_POT_ACTUATOR_DIAMETER + tolerance * 2
                        + chamfer * 2,
                    d2 = PTV09A_POT_ACTUATOR_DIAMETER + tolerance * 2
                        - PTV09A_POT_ACTUATOR_D_SHAFT_DEPTH * 2,
                    h = chamfer + PTV09A_POT_ACTUATOR_D_SHAFT_DEPTH + e
                );
            }
        }

        module _grips() {
            cylinder_grip(
                diameter = PTV09A_POT_ACTUATOR_DIAMETER + tolerance * 2,
                height = height - hub_ceiling,
                count = shim_count,
                rotation_offset = 180,
                size = shim_size
            );
        }

        module _pot() {
            // Cavity is full available height, regardless of actual usage
            z = -(e + PTV09A_POT_BASE_HEIGHT);

            translate([0, 0, z]) {
                pot(
                    show_base = debug,
                    actuator_height = height - hub_ceiling + e,
                    diameter_bleed = tolerance,
                    shaft_type = shaft_type,
                    $fn = $preview ? undef : 120
                );
            }
        }

        _chamfer();

        difference() {
            if (debug) { # _pot(); } else { _pot(); }
            _grips();
        }
    }

    module _spokes() {
        overlap = ring / 2;

        x = spokes_width / -2;
        y = hub_diameter / 2 - overlap;

        length = diameter / 2 - y - ring + overlap;

        for (i = [0 : spokes_count - 1]) {
            rotate([0, 0, (i / spokes_count) * 360]) {
                translate([x, y, 0]) {
                    cube([spokes_width, length, spokes_height]);
                }
            }
        }
    }

    module _brodie_knobs() {
        for (i = [0 : brodie_knob_count - 1]) {
            rotation = brodie_knob_angle_offset + i * (360 / brodie_knob_count);

            rotate([0, 0, rotation]) {
                translate([0, diameter / 2 - brodie_knob_diameter / 2, 0]) {
                    cylinder(
                        h = height + brodie_knob_stilt,
                        d1 = 0,
                        d2 = brodie_knob_diameter
                    );

                    translate([0, 0, height + brodie_knob_stilt]) {
                        sphere(
                            d = brodie_knob_diameter
                        );
                    }
                }
            }
        }
    }

    module _dimple_cavities(dimple_diameter = diameter / 3) {
        assert(
            brodie_knob_count == 0,
            "Dimples and brodie knobs can't be used together. Set brodie_knob_count to 0."
        );

        assert(
            spokes_count == 0,
            "Dimples and spokes can't be used together. Set spokes_count to 0."
        );

        for (i = [0 : dimple_count - 1]) {
            y = dimple_y != undef
                ? dimple_y
                : diameter / 2 - dimple_diameter / 2 - ring / 2;
            rotation = i * (360 / dimple_count);

            rotate([0, 0, rotation]) {
                translate([0, y, height - dimple_depth]) {
                    cylinder(
                        h = dimple_depth + e,
                        d = dimple_diameter
                    );
                }
            }
        }
    }

    difference() {
        color(color) {
            union() {
                if (spokes_count > 0) {
                    _hub();
                }

                if (!test_fit) {
                    _tire();

                    if (spokes_count > 0) {
                        _spokes();
                    }

                    if (brodie_knob_count > 0) {
                        _brodie_knobs();
                    }
                }
            }
        }

        color(cavity_color) {
            _pot_cavity();

            if (dimple_count > 0) {
                _dimple_cavities();
            }
        }

        if (debug) {
            translate([0, diameter / -2 -e, -e]) {
                cube([
                    diameter / 2 + e,
                    diameter + e * 2,
                    height + brodie_knob_diameter / 2 + e * 2
                ]);
            }
        }
    }
}

// shim .5 * 3 is still good
// .6 * 3 could be good w/ bigger chamfer
// .6 * 4 feels even better
// 5 shims is whatever and 6 is too many
// .8 is too big, regardless

// all of these work
/* shim_sizes = [.5, .6];
shim_counts = [3, 5];

plot = 7.8;

for (i = [0 : len(shim_sizes) - 1]) {
    for (ii = [0 : len(shim_counts) - 1]) {
        shim_size = shim_sizes[i];
        shim_count = shim_counts[ii];

        is_needle = shim_size == .5 && shim_count == 3;

        translate([i * plot, ii * plot, 0]) {
            color(is_needle ? "red" : undef) {
                wheel(
                    height = 8,
                    shim_size = shim_size,
                    shim_count = shim_count,
                    test_fit = true,
                    shaft_type = POT_SHAFT_TYPE_SPLINED,
                    chamfer = .8
                );
            }
        }
    }
} */

/* wheel(debug = true); */
