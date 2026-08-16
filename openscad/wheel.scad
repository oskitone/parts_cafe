include <cylinder_grip.scad>;
include <donut.scad>;
include <pot.scad>;
include <rib_cavities.scad>;
include <ring.scad>;

module wheel(
    diameter = 20,
    height = 10,

    fillet = 4,

    ceiling = 1.8, // ENCLOSURE_FLOOR_CEILING

    brodie_knob_diameter = 4,
    brodie_knob_stilt = 0,
    brodie_knob_count = 1,
    brodie_knob_angle_offset = 0,

    dimple_count = 0,
    dimple_depth = 1,
    dimple_y = undef,
    dimple_diameter = undef,

    line_marker_count = 0,
    line_marker_depth = 1,
    line_marker_width = 2,

    spokes_hub_diameter = PTV09A_POT_ACTUATOR_DIAMETER + 1.2 * 2, // ENCLOSURE_INNER_WALL
    spokes_count = 6,
    spokes_width = 2,
    spokes_height = 5,

    chamfer = 1.2 - .5, // ENCLOSURE_INNER_WALL - BREAKAWAY_SUPPORT_DEPTH
    shim_size = .6,
    shim_count = 5,

    round_bottom = true,

    brim_diameter = 0,
    brim_height = 0,

    shaft_type = POT_SHAFT_TYPE_DEFAULT,

    grip_count = undef,

    test_fit = false,

    color = undef,
    cavity_color = undef,

    debug = false,

    tolerance = 0
) {
    e = 0.043;

    has_brim = brim_diameter > 0 && brim_height > 0;
    flat_bottom = !round_bottom;

    dimple_diameter = dimple_diameter != undef
        ? dimple_diameter
        : diameter / 3;
    dimple_y = dimple_y != undef
        ? dimple_y
        : diameter / 2 - dimple_diameter / 2 - fillet / 2;

    grip_count = grip_count != undef
        ? grip_count
        : round(
            diameter * PI / (DEFAULT_RIB_SIZE + DEFAULT_RIB_GUTTER)
        );

    module _spokes_hub() {
        if (!test_fit) {
            translate([0, 0, height - fillet / 2]) {
                hull() {
                    donut(
                        diameter = spokes_hub_diameter,
                        thickness = fillet,
                        segments = $fn != undef ? $fn : 24
                    );
                }
            }
        }

        cylinder(
            d = spokes_hub_diameter,
            h = height - fillet / 2
        );
    }

    module _tire() {
        module _ends() {
            module _end(z) {
                translate([0, 0, z]) {
                    donut(
                        diameter = diameter,
                        thickness = fillet,
                        segments = $preview ? undef : grip_count
                    );
                }
            }

            if (flat_bottom || has_brim) {
                translate([0, 0, has_brim ? e : 0]) {
                    ring(
                        diameter = diameter,
                        height = e,
                        thickness = fillet
                    );
                }
            } else {
                _end(fillet / 2);
            }

            _end(height - fillet / 2);
        }

        if (spokes_count > 0) {
            _ends();

            translate([0, 0, round_bottom ? fillet / 2 : 0]) {
                ring(
                    diameter = diameter,
                    height = round_bottom ? height - fillet : height - fillet / 2,
                    thickness = fillet
                );
            }
        } else {
            hull() {
                _ends();
            }
        }
    }

    module _outer_grip() {
        z = has_brim
            ? brim_height + e
            : -e;

        translate([0, 0, z]) {
            cylinder_grip(
                diameter = diameter,
                height = height + e * 2,
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

        module _pot_grips() {
            _height = height - ceiling;
            z = shaft_type == POT_SHAFT_TYPE_SPLINED
                ? _height - PTV09A_POT_ACTUATOR_SPLINED_SHAFT_HEIGHT
                : 0;

            translate([0, 0, z]) {
                cylinder_grip(
                    diameter = PTV09A_POT_ACTUATOR_DIAMETER + tolerance * 2,
                    height = _height - z,
                    count = shim_count,
                    rotation_offset = 180,
                    size = shim_size
                );
            }
        }

        module _pot(diameter_bleed = 0) {
            // Cavity is full available height, regardless of actual usage
            z = -(e + PTV09A_POT_BASE_HEIGHT_FROM_PCB);

            translate([0, 0, z]) {
                pot(
                    show_base = debug,
                    actuator_height = height - ceiling + e,
                    diameter_bleed = diameter_bleed,
                    shaft_type = shaft_type,
                    $fn = $preview ? undef : 120
                );
            }
        }

        _chamfer();

        if (debug) {
            # _pot();
        }

        difference() {
            _pot(tolerance);
            _pot_grips();
        }
    }

    module _spokes() {
        overlap = fillet / 2;

        x = spokes_width / -2;
        y = spokes_hub_diameter / 2 - overlap;

        length = diameter / 2 - y - fillet + overlap;

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

    module _dimple_cavities() {
        for (i = [0 : dimple_count - 1]) {
            rotate([0, 0, i * (360 / dimple_count)]) {
                translate([0, dimple_y, height - dimple_depth + e]) {
                    cylinder(
                        h = dimple_depth,
                        d = dimple_diameter,
                        $fn = $preview ? undef : grip_count
                    );
                }
            }
        }
    }

    module _line_marker_cavities() {
        for (i = [0 : line_marker_count - 1]) {
            rotate([0, 0, i * (360 / line_marker_count)]) {
                translate([
                    0,
                    0,
                    height - line_marker_depth + e
                ]) {
                    cylinder(
                        h = line_marker_depth,
                        d = line_marker_width,
                        $fn = 12
                    );

                    translate([line_marker_width / -2, 0, 0]) {
                        cube([
                            line_marker_width,
                            diameter,
                            line_marker_depth
                        ]);
                    }
                }
            }
        }
    }

    module _brim() {
        cylinder(
            d = brim_diameter,
            h = brim_height,
            $fn = $preview ? undef : grip_count
        );
    }

    difference() {
        color(color) {
            union() {
                if (spokes_count > 0) {
                    _spokes_hub();
                }

                if (has_brim) {
                    _brim();
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
            _outer_grip();

            if (dimple_count > 0) {
                _dimple_cavities();
            }

            if (line_marker_count > 0) {
                _line_marker_cavities();
            }
        }

        if (debug) {
            max_diameter = max(diameter, brim_diameter);

            translate([0, max_diameter / -2 -e, -e]) {
                cube([
                    max_diameter / 2 + e,
                    max_diameter + e * 2,
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

/* wheel(
    // brodie_knob_count = 1, spokes_count = 1,
    // dimple_count = 0,
    round_bottom = false,
    debug = false,
    $fn = 24
); */