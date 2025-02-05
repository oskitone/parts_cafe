// TODO: legion
// - Ditch wall_xy and floor position stuff
//   Everything should start at [0,0,0]
// - Relatedly, positioning against batteries should be obvious
// - Make battery_contact_fixture's floor_cavity_height less confusing
//   Sometimes it's a fixture, sometimes a cavity. decouple?
// - Fix sibling battery_contact_fixture obstruction
//   Very probably caused assembly tightness problem

include <batteries-aaa.scad>;
include <battery_contacts.scad>;
include <enclosure.scad>;
include <enclosure_engraving.scad>;

BATTERY_HOLDER_NUB_FIXTURE_WIDTH = 10;
BATTERY_HOLDER_NUB_FIXTURE_DEPTH = .6;
BATTERY_HOLDER_NUB_FIXTURE_HEIGHT = 1;
BATTERY_HOLDER_NUB_FIXTURE_Z = AAA_BATTERY_DIAMETER;

BATTERY_HOLDER_DEFAULT_FLOOR = 1;
BATTERY_HOLDER_DEFAULT_WALL = 1.2; // ENCLOSURE_INNER_WALL
BATTERY_HOLDER_FILLET = 1.25; // ENCLOSURE_INNER_FILLET

RIBBON_CABLE_WIDTH = 2.6;
RIBBON_CABLE_HEIGHT = 1;

function get_battery_holder_cavity_width(
    tolerance = 0
) = (
    AAA_BATTERY_TOTAL_LENGTH
        + KEYSTONE_181_SPRING_COMPRESSED_LENGTH
        + KEYSTONE_181_BUTTON_LENGTH
        + tolerance * 2
);

function get_battery_holder_width(
    tolerance = 0,
    wall = BATTERY_HOLDER_DEFAULT_WALL
) = (
    get_battery_holder_cavity_width(tolerance)
    + wall * 2
);

function get_battery_holder_cavity_length(
    count,
    tolerance,
    gutter = KEYSTONE_181_GUTTER
) = (
    AAA_BATTERY_DIAMETER * count
        + gutter * (count - 1)
        + tolerance * 2
);

function get_battery_holder_length(
    count,
    tolerance = 0,
    wall = BATTERY_HOLDER_DEFAULT_WALL
) = (
    get_battery_holder_cavity_length(count, tolerance)
    + wall * 2
);

function get_battery_holder_dimensions(
    count,
    tolerance = 0,
    wall = BATTERY_HOLDER_DEFAULT_WALL,
    floor = BATTERY_HOLDER_DEFAULT_FLOOR,
    wall_height_extension = 0
) = [
    get_battery_holder_width(tolerance, wall),
    get_battery_holder_length(count, tolerance, wall),
    AAA_BATTERY_DIAMETER + floor + wall_height_extension
];

module battery_contact_fixture(
    height = KEYSTONE_181_HEIGHT,
    tolerance = 0,
    contact_z = undef,

    flip = false,
    floor_cavity_height,

    diameter = KEYSTONE_181_HEIGHT,
    depth = max(KEYSTONE_5204_5226_FULL_LENGTH, KEYSTONE_181_DIAMETER),
    back_shunt = 0,

    wall = 2,
    contact_wall = .8,

    include_wire_contact_fins = false
) {
    e = .048;

    contact_z = contact_z != undef
        ? contact_z
        : height - AAA_BATTERY_DIAMETER / 2;
    cavity_z = contact_z - KEYSTONE_181_HEIGHT / 2 - e;

    cavity_width = diameter + tolerance * 2;
    cavity_depth = depth + tolerance;
    cavity_height = height - cavity_z + e;

    exposure_width = cavity_width - contact_wall * 2;
    exposure_height = cavity_height - contact_wall;
    exposure_z = cavity_z + contact_wall;

    outer_width = cavity_width + wall * 2;
    outer_length = cavity_depth + contact_wall;

    y = -(tolerance + wall);

    module _wire_contact_fin(_length = outer_length, clearance = 1) {
        _width = KEYSTONE_181_CADENCE - KEYSTONE_181_CONTACT_X - clearance * 2;
        _height = KEYSTONE_181_HEIGHT / 2 - KEYSTONE_181_DIAMETER;

        translate([outer_width/ 2, outer_length - _length, contact_z]) {
            flat_top_rectangular_pyramid(
                top_width = _width,
                top_length = _length + e,
                bottom_width = 0,
                bottom_length = _length + e,
                height = _height
            );
        }
    }

    module _floor_cavity() {
        translate([wall, contact_wall, -floor_cavity_height]) {
            cube([cavity_width, cavity_depth + e, floor_cavity_height + e]);
        }
    }

    module _output() {
        difference() {
            cube([outer_width, outer_length, height]);

            translate([wall, contact_wall, cavity_z]) {
                cube([
                    cavity_width,
                    cavity_depth - back_shunt + e,
                    cavity_height
                ]);
            }

            translate([wall + contact_wall, -e, exposure_z]) {
                cube([exposure_width, contact_wall + e * 2, exposure_height]);
            }
        }

        if (include_wire_contact_fins) {
            _wire_contact_fin();
        }
    }

    translate(flip ? [outer_length, y, 0] : [-outer_length, y + outer_width, 0]) {
        rotate(flip ? [0, 0, 90] : [0, 0, -90]) {
            if (floor_cavity_height) {
                _floor_cavity();
            } else {
                _output();
            }
        }
    }
}

module battery_direction_engravings(
    tolerance = 0,
    z = 0,
    gutter = KEYSTONE_181_GUTTER,
    height = AAA_BATTERY_DIAMETER,
    count = 3,
    quick_preview = true
) {
    e = .0351;

    function get_label(battery_i, contact_i) = (
        battery_i % 2
            ? contact_i ? "-" : "+"
            : contact_i ? "+" : "-"
    );

    for (battery_i = [0 : count - 1]) {
        for (contact_i = [0 : 1]) {
            x = get_battery_holder_cavity_width(tolerance) / 2 - tolerance
                + AAA_BATTERY_LENGTH * .25 * (contact_i ? -1 : 1);
            y = battery_i * (AAA_BATTERY_DIAMETER + gutter) - tolerance
                + AAA_BATTERY_DIAMETER / 2;

            translate([x, y, -(z + e)]) {
                enclosure_engraving(
                    string = get_label(battery_i, contact_i),
                    size = AAA_BATTERY_DIAMETER * .75,
                    bottom = true,
                    enclosure_height = z,
                    quick_preview = quick_preview
                );
            }
        }
    }
}

module battery_contact_fixtures(
    tolerance = 0,
    gutter = KEYSTONE_181_GUTTER,
    height = AAA_BATTERY_DIAMETER,
    floor_cavity_height,
    start_on_right = false,
    count = 3
) {
    e = .091;

    end_on_right = count % 2 == 0 ? !start_on_right : start_on_right;

    cavity_width = get_battery_holder_cavity_width(tolerance);
    tab_contact_fixture_wall = AAA_BATTERY_DIAMETER - KEYSTONE_5204_5226_WIDTH;

    function get_y(contact_width, i, is_dual = false) = (
        (AAA_BATTERY_DIAMETER + gutter) * i
        + (AAA_BATTERY_DIAMETER * (is_dual ? 2 : 1) - contact_width) / 2
    );

    if (floor(count) > 1) {
        for (i = [0 : floor(count)]) {
            is_even = i % 2 == 0;

            left_x = -e - tolerance;
            right_x = cavity_width - tolerance + e;

            if (i <= count - 2 && !floor_cavity_height) {
                x = is_even
                    ? start_on_right ? right_x : left_x
                    : start_on_right ? left_x : right_x;

                translate([x, get_y(KEYSTONE_181_WIDTH, i, true), 0]) {
                    battery_contact_fixture(
                        flip = start_on_right ? !is_even : is_even,
                        diameter = KEYSTONE_181_WIDTH,
                        back_shunt = KEYSTONE_5204_5226_FULL_LENGTH
                            - KEYSTONE_181_DIAMETER,
                        tolerance = tolerance,
                        height = height - e,
                        include_wire_contact_fins = true
                    );
                }
            }

            if (i == 0) {
                x = start_on_right ? left_x : right_x;

                translate([x, get_y(KEYSTONE_5204_5226_WIDTH, i), 0]) {
                    battery_contact_fixture(
                        flip = start_on_right,
                        floor_cavity_height = floor_cavity_height,
                        diameter = KEYSTONE_5204_5226_WIDTH,
                        wall = tab_contact_fixture_wall,
                        tolerance = tolerance * 2, // intentionally loose
                        contact_z = 0,
                        height = height - e
                    );
                }
            } else if (i == count - 1) {
                x = end_on_right ? right_x : left_x;

                translate([x, get_y(KEYSTONE_5204_5226_WIDTH, i), 0]) {
                    battery_contact_fixture(
                        flip = !end_on_right,
                        floor_cavity_height = floor_cavity_height,
                        diameter = KEYSTONE_5204_5226_WIDTH,
                        wall = tab_contact_fixture_wall,
                        tolerance = tolerance * 2, // intentionally loose
                        contact_z = 0,
                        height = height - e
                    );
                }
            }
        }
    }
}

module battery_holder(
    wall = BATTERY_HOLDER_DEFAULT_WALL,
    wall_height_extension = 0,
    floor = BATTERY_HOLDER_DEFAULT_FLOOR,
    tolerance = 0,
    count = 3,

    fillet = BATTERY_HOLDER_FILLET,
    gutter = KEYSTONE_181_GUTTER,
    contact_tab_width = KEYSTONE_5204_5226_TAB_WIDTH,
    contact_tab_cavity_length =
        KEYSTONE_5204_5226_LENGTH + KEYSTONE_5204_5226_DIMPLE_LENGTH,
    end_terminal_bottom_right = true,

    include_wire_relief_hitches = true,
    include_nub_fixture_cavities = true,
    include_wire_channel = true,
    use_wire_channel_as_relief = false,
    wire_channel_diameter = max(RIBBON_CABLE_HEIGHT, RIBBON_CABLE_WIDTH),

    outer_color = undef,
    cavity_color = undef,

    quick_preview = true
) {
    e = .0837;

    cavity_width = get_battery_holder_cavity_width(tolerance);
    cavity_length = get_battery_holder_cavity_length(count, tolerance, gutter);

    width = get_battery_holder_width(tolerance, wall);
    length = cavity_length + wall * 2;
    height = AAA_BATTERY_DIAMETER + floor + wall_height_extension;

    wall_xy = -(wall + tolerance);

    center_z = height / 2 - floor;

    _wire_channel_diameter = wire_channel_diameter + tolerance * 2;

    module _alignment_rails(
        _width = AAA_BATTERY_LENGTH * .33,
        top_length = 1,
        bottom_length = _wire_channel_diameter + BATTERY_HOLDER_DEFAULT_WALL * 2,
        _height = AAA_BATTERY_DIAMETER * .25
    ) {
        x = (cavity_width - _width) / 2 - tolerance;

        for (i = [1 : count - 1]) {
            y = i * (AAA_BATTERY_DIAMETER + gutter) - bottom_length / 2;

            translate([x, y, -e]) {
                flat_top_rectangular_pyramid(
                    top_width = _width,
                    top_length = top_length,
                    bottom_width = _width,
                    bottom_length = bottom_length,
                    height = _height + e
                );
            }
        }
    }

    module _contact_tab_cavities(start_on_right = end_terminal_bottom_right) {
        x = -(wall + tolerance);

        _width = wall + contact_tab_cavity_length;
        _length = contact_tab_width + tolerance * 2;
        _height = floor + height * .25;

        left_x = -(wall + tolerance) - e;
        right_x = width - _width + x + e;

        end_on_right = count % 2 == 0 ? !start_on_right : start_on_right;

        for (xy = [
            [
                end_on_right ? left_x : right_x,
                (AAA_BATTERY_DIAMETER + gutter) * (count - 1)
                    + AAA_BATTERY_DIAMETER / 2
            ],
            [
                start_on_right ? right_x : left_x,
                AAA_BATTERY_DIAMETER / 2
            ]
        ]) {
            translate([xy.x, xy.y - _length / 2, -(e + floor)]) {
                cube([_width, _length, _height]);
            }
        }
    }

    module _nub_fixture_cavities(clearance = .1) {
        _width = BATTERY_HOLDER_NUB_FIXTURE_WIDTH + (clearance + tolerance) * 2;
        _length = wall + e * 2;
        _height = BATTERY_HOLDER_NUB_FIXTURE_HEIGHT
            + (clearance + tolerance) * 2;

        x = wall_xy + (width - _width) / 2;

        for (
            y = [wall_xy - e, wall_xy + length - _length],
            z = [
                -floor - e,
                BATTERY_HOLDER_NUB_FIXTURE_Z - (clearance + tolerance) - floor
            ]
        ) {
            translate([x, y, z]) {
                cube([_width, _length + e, _height + e]);
            }
        }
    }

    module _wire_relief_hitches(
        hole_diameter = RIBBON_CABLE_WIDTH + tolerance * 2,
        wall = BATTERY_HOLDER_DEFAULT_WALL,
        _length = AAA_BATTERY_DIAMETER - _wire_channel_diameter
    ) {
        _width = wall + hole_diameter;

        module _hitch(x, flip_horizontally = true) {
            y = wall_xy + (length - _length) / 2;

            cylinder_x = wall + hole_diameter / 2;
            cylinder_z = floor + center_z;

            connection_x = flip_horizontally ? 0 : wall_xy - x + e;

            translate([x, y, -floor]) {
                difference() {
                    hull($fn = quick_preview ? undef : 24) {
                        translate([cylinder_x, 0, cylinder_z]) {
                            rotate([-90, 0, 0]) {
                                cylinder(
                                    d = hole_diameter + wall * 2,
                                    h = _length
                                );
                            }
                        }

                        translate([connection_x, 0, fillet]) {
                            cube([e, _length, height - floor - fillet]);
                        }
                    }

                    translate([cylinder_x, -e, cylinder_z]) {
                        rotate([-90, 0, 0]) {
                            cylinder(
                                d = hole_diameter,
                                h = _length + e * 2,
                                $fn = quick_preview ? undef : 12
                            );
                        }
                    }
                }
            }
        }

        _hitch(wall_xy - _width, flip_horizontally = false);
        _hitch(wall_xy + width - wall, flip_horizontally = true);
    }

    module _wire_channel(
        _length = RIBBON_CABLE_HEIGHT,
        _height = RIBBON_CABLE_WIDTH,

        _block_width = 5,
        _block_distance_from_end = width / 6,

        diameter = _wire_channel_diameter
    ) {
        x = wall_xy;
        y = AAA_BATTERY_DIAMETER;

        // HACK: it's very unintuitive to derive these values,
        // so they are eyeballed.
        dfm_chamfer = [(2 - tolerance), diameter - e * 2, diameter - .5];
        dfm_x = end_terminal_bottom_right
            ? wall_xy + width - wall - dfm_chamfer.x - e
            : wall_xy + wall + e;

        difference() {
            union() {
                translate([x - e, y, 0]) {
                    rotate([0, 90, 0]) {
                        cylinder(
                            d = diameter,
                            h = width + e * 2,
                            $fn = 12
                        );
                    }
                }

                translate([x - e, y + diameter / -2, -floor - e]) {
                    cube([width + e * 2, diameter, floor]);
                }

                render() translate([dfm_x, y + diameter / -2 + e, -floor - e]) {
                    cube([dfm_chamfer.x, dfm_chamfer.y, dfm_chamfer.z + e]);

                    translate([0, 0, dfm_chamfer.z]) {
                        flat_top_rectangular_pyramid(
                            top_width = 0,
                            top_length = dfm_chamfer.y,
                            bottom_width = dfm_chamfer.x,
                            bottom_length = dfm_chamfer.y,
                            height = dfm_chamfer.x,
                            top_weight_x = end_terminal_bottom_right ? 0 : 1
                        );
                    }
                }
            }

            if (use_wire_channel_as_relief) {
                _x = end_terminal_bottom_right
                    ? cavity_width - _block_distance_from_end - _block_width
                    : _block_distance_from_end;

                translate([_x, y + diameter / -2, - floor - e]) {
                    cube([_block_width, diameter, floor + e * 2]);
                }
            }
        }
    }

    difference() {
        color(outer_color) {
            union() {
                battery_contact_fixtures(
                    tolerance = tolerance,
                    gutter = gutter,
                    height = height - floor,
                    start_on_right = !end_terminal_bottom_right,
                    count = count
                );

                difference() {
                    translate([wall_xy, wall_xy, -floor]) {
                        rounded_cube(
                            [width, length, height],
                            radius = fillet,
                            $fn = quick_preview ? undef : 24
                        );
                    }

                    translate([-tolerance, -tolerance, 0]) {
                        cube([
                            cavity_width,
                            cavity_length,
                            AAA_BATTERY_DIAMETER + wall_height_extension + e * 2
                        ]);
                    }
                }

                _alignment_rails();

                if (include_wire_relief_hitches) {
                    _wire_relief_hitches();
                }
            }
        }

        color(cavity_color) {
            if (floor > 0) {
                battery_contact_fixtures(
                    tolerance = tolerance,
                    gutter = gutter,
                    floor_cavity_height = KEYSTONE_5204_5226_CONTACT_Z
                        - (AAA_BATTERY_DIAMETER / 2),
                    start_on_right = !end_terminal_bottom_right,
                    count = count
                );

                _contact_tab_cavities();

                battery_direction_engravings(
                    tolerance = tolerance,
                    z = floor,
                    quick_preview = quick_preview
                );
            }

            if (include_nub_fixture_cavities) {
                _nub_fixture_cavities();
            }

            if (include_wire_channel) {
                _wire_channel();
            }
        }
    }
}

* difference() {
translate([0, -40, 0]) {
    # % battery_array();
    battery_holder(wall = 3, tolerance = .3, floor = 4, end_terminal_bottom_right = 1, quick_preview = $preview);
    % battery_contacts(tolerance = .3, end_terminal_bottom_right = 1);
}
translate([-10, -50, -10]) cube([20, 50, 30]);
}
