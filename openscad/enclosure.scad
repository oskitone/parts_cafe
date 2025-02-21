include <flat_top_rectangular_pyramid.scad>;
include <nuts_and_bolts.scad>;
include <rounded_cube.scad>;
include <chamfered_cube.scad>;
include <chamfered_xy_cube.scad>;
include <rounded_xy_cube.scad>;

ENCLOSURE_WALL = 2.4;
ENCLOSURE_FLOOR_CEILING = 1.8;
ENCLOSURE_INNER_WALL = 1.2;
ENCLOSURE_LIP_HEIGHT = 3;
ENCLOSURE_ENGRAVING_DEPTH = 1.2;
ENCLOSURE_FILLET = 2;
ENCLOSURE_INNER_CHAMFER = 1.2;

// [back, right, front, left],
ENCLOSURE_TONGUE_AND_GROOVE_SNAP = [.5, .8, .5, .8];

// Max is around .3 but it's hard to get back open
ENCLOSURE_TONGUE_AND_GROOVE_PULL = .1;

module enclosure_half(
    width, length, height,

    wall = ENCLOSURE_WALL,
    floor_ceiling = ENCLOSURE_FLOOR_CEILING,

    add_lip = false,
    remove_lip = false,

    lip_depth = undef,
    lip_height = ENCLOSURE_LIP_HEIGHT,

    fillet = ENCLOSURE_FILLET,
    inner_chamfer = ENCLOSURE_INNER_CHAMFER,

    // Increase to .2 for looser fit, will need separate fixture
    tolerance = .1,

    include_tongue_and_groove = false,
    tongue_and_groove_end_length = undef,
    tongue_and_groove_snap = ENCLOSURE_TONGUE_AND_GROOVE_SNAP,
    tongue_and_groove_pull = ENCLOSURE_TONGUE_AND_GROOVE_PULL,

    include_disassembly_dimples = false,
    include_disassembly_wedges = false,

    outer_color,
    cavity_color
) {
    e = 0.01234;

    groove_depth = wall / 3;
    groove_height = lip_height * .67;

    lip_depth = lip_depth != undef ? lip_depth : (wall - groove_depth) / 2;

    module _grooves(z, bleed = 0) {
        support_depth = groove_depth - tolerance;

        x = wall - lip_depth + tolerance - groove_depth - bleed;
        y = tongue_and_groove_snap ? x : wall;
        z = z - tongue_and_groove_pull / 2;

        bottom_x = x + support_depth;
        bottom_y = tongue_and_groove_snap ? y + support_depth : y;

        groove_width = width - x * 2;
        groove_length = include_tongue_and_groove
            ? tongue_and_groove_snap ? length - x * 2 : length - wall - x
            : length - wall * 2;

        module _hull() {
            hull() {
                translate([bottom_x, bottom_y, z]) {
                    flat_top_rectangular_pyramid(
                        top_width = groove_width,
                        top_length = groove_length,
                        bottom_width = groove_width - support_depth * 2,
                        bottom_length = groove_length - support_depth
                            * (tongue_and_groove_snap ? 2 : 1),
                        height = support_depth,
                        top_weight_y = tongue_and_groove_snap ? .5 : 0
                    );
                }

                translate([x, y, z + groove_height - support_depth]) {
                    flat_top_rectangular_pyramid(
                        top_width = groove_width - support_depth * 2,
                        top_length = groove_length - support_depth
                            * (tongue_and_groove_snap ? 2 : 1),
                        bottom_width = groove_width,
                        bottom_length = groove_length,
                        height = support_depth,
                        top_weight_y = tongue_and_groove_snap ? .5 : 0
                    );
                }
            }
        }

        module _intersection() {
            size = wall + e * 2;

            BACK = "back";
            RIGHT = "right";
            FRONT = "front";
            LEFT = "left";

            module _side(
                side = FRONT,
                _width = size,
                _length = size,
                x = -e,
                y = -e,
                z = add_lip ? height - e : height - lip_height -e
            ) {
                translate([
                    _width == size ? x : (width - _width) / 2,
                    _length == size ? y : (length - _length) / 2,
                    z
                ]) {
                    cube([_width, _length, lip_height + e * 2]);
                }
            }

            if (tongue_and_groove_end_length) {
                y = length - wall - tongue_and_groove_end_length - bleed;
                z = add_lip ? height : height - lip_height;

                translate([-e, y, z - e]) {
                    cube([
                        width + e * 2,
                        tongue_and_groove_end_length + wall + bleed,
                        lip_height + e * 2
                    ]);
                }
            } else if (tongue_and_groove_snap) {
                _tolerance = tolerance * (add_lip ? -1 : 1);
                _snap = tongue_and_groove_snap;

                end_offset = wall - lip_depth + inner_chamfer + tolerance;
                exposed_width = width - end_offset * 2;
                exposed_length = length - end_offset * 2;

                // BACK
                if (_snap[0] > 0) {
                    _side(
                        _width = _snap[0] * exposed_width + _tolerance,
                        y = length - size + e
                    );
                }

                // RIGHT
                if (_snap[1] > 0) {
                    _side(
                        _length = _snap[1] * exposed_length + _tolerance,
                        x = width - size + e
                    );
                }

                // FRONT
                if (_snap[2] > 0) {
                    _side(_width = _snap[2] * exposed_width + _tolerance);
                }

                // LEFT
                if (_snap[3] > 0) {
                    _side(_length = _snap[3] * exposed_length + _tolerance);
                }
            }
        }

        if (include_tongue_and_groove) {
            if (tongue_and_groove_end_length || tongue_and_groove_snap) {
                intersection() {
                    _hull();
                    _intersection();
                }
            } else {
                _hull();
            }
        }
    }

    module _outer_wall() {
        difference() {
            rounded_cube(
                [
                    width,
                    length,
                    (add_lip && include_tongue_and_groove)
                        ? height + lip_height + fillet
                        : height + fillet
                ],
                fillet
            );

            if (add_lip && include_tongue_and_groove) {
                translate([
                    -e,
                    tongue_and_groove_snap ? -e : wall,
                    height
                ]) {
                    cube([
                        width + e * 2,
                        tongue_and_groove_snap
                            ? length + e * 2
                            : length - wall + e,
                        lip_height * 2 + e
                    ]);
                }
            }

            translate([
                -e,
                -e,
                (add_lip && include_tongue_and_groove)
                    ? height + lip_height
                    : height
            ]) {
                cube([
                    width + e * 2,
                    length + e * 2,
                    fillet + e
                ]);
            }
        }

        if (add_lip) {
            x = wall - lip_depth + tolerance;
            y = include_tongue_and_groove && !tongue_and_groove_snap
                ? wall
                : x;
            length = include_tongue_and_groove
                ? length - y - x
                : length - y * 2;

            translate([x, y, height - e]) {
                chamfered_xy_cube(
                    [width - x * 2, length, lip_height + e],
                    inner_chamfer
                );
            }

            _grooves(
                z = height + lip_height - groove_height,
                bleed = -tolerance
            );
        }
    }

    module _inner_cutout() {
        translate([wall, wall, floor_ceiling]) {
            chamfered_cube(
                [
                    width - wall * 2,
                    length - wall * 2,
                    height * 2 // NOTE: arbitrary
                ],
                inner_chamfer
            );
        }

        if (remove_lip) {
            x = wall - lip_depth - tolerance;
            y = (include_tongue_and_groove && !tongue_and_groove_snap)
                ? wall
                : x;
            z = height - lip_height;

            width = width - x * 2;
            length = include_tongue_and_groove
                ? length - y - x
                : length - y * 2;

            translate([x, y, z]) {
                chamfered_xy_cube(
                    [width, length, lip_height * 2 + e],
                    inner_chamfer
                );
            }

            _grooves(
                z = height - lip_height,
                bleed = tolerance
            );
        }
    }

    module _groove_exposure() {
        if (
            include_tongue_and_groove
            && !tongue_and_groove_snap
            && remove_lip
        ) {
            translate([0, -e, height - lip_height]) {
                cube([width, wall + tolerance * 4 + e * 2, lip_height + e]);
            }
        }
    }

    module _disassembly_cavities(
        include_dimple = false,
        dimple_diameter = 10,
        dimple_depth = ENCLOSURE_ENGRAVING_DEPTH,

        include_wedges = false,
        wedge_width = 10,
        wedge_height = FLATHEAD_SCREWDRIVER_POINT
    ) {
        if (include_dimple) {
            difference() {
                for (x = [-e, width - dimple_depth]) {
                    translate([x, length / 2, height]) {
                        rotate([0, 90, 0]) {
                            cylinder(
                                d = dimple_diameter,
                                h = dimple_depth + e,
                                $fn = 24
                            );
                        }
                    }
                }

                translate([
                    -e,
                    (length - dimple_diameter) / 2,
                    height + e
                ]) {
                    cube([
                        width,
                        dimple_diameter + e * 2,
                        lip_height + e
                    ]);
                }
            }
        }

        if (include_wedges) {
            x = (width - wedge_width) / 2;
            ys = [-e, length - ENCLOSURE_WALL - e];

            for (y = ys) {
                translate([x, y, height - wedge_height]) {
                    cube([wedge_width, ENCLOSURE_WALL + e * 2, wedge_height + e]);
                }
            }
        }
    }

    difference() {
        color(outer_color) {
            _outer_wall();
        }

        color(cavity_color) {
            _inner_cutout();
            _groove_exposure();

            _disassembly_cavities(
                include_dimple = include_disassembly_dimples && add_lip,
                include_wedges = include_disassembly_wedges && remove_lip
            );
        }
    }
}


module enclosure_fit_check(
    width, length, bottom_height, top_height,

    fillet = ENCLOSURE_FILLET,
    inner_chamfer = ENCLOSURE_INNER_CHAMFER,

    tongue_and_groove_snap = ENCLOSURE_TONGUE_AND_GROOVE_SNAP,
    tongue_and_groove_pull = ENCLOSURE_TONGUE_AND_GROOVE_PULL,

    bottom_color,
    top_color
) {
    module _half(height, lip, color = undef) {
        enclosure_half(
            width, length, height,

            add_lip = lip,
            remove_lip = !lip,

            fillet = fillet,
            inner_chamfer = inner_chamfer,

            include_tongue_and_groove = true,
            tongue_and_groove_snap = tongue_and_groove_snap,
            tongue_and_groove_pull = tongue_and_groove_pull,

            outer_color = color,
            cavity_color = color
        );
    }

    _half(bottom_height, true, bottom_color);

    e = .031;
    intersection_height = e * 2 + (2 + ENCLOSURE_LIP_HEIGHT - e * 3) * (abs($t - .5) * 2);

    color(top_color) translate([e, -e, 0]) intersection() {
        translate([0, 0, bottom_height + top_height]) {
            mirror([0, 0, 1]) {
                _half(top_height, false);
            }
        }

        translate([-e, -e, bottom_height - e]) {
            cube([width + e * 2, length + e * 2, intersection_height]);
        }
    }
}

* difference() {
enclosure_fit_check(
    50, 50, 20, 20,

    // fillet = 0,
    // inner_chamfer = 0,

    tongue_and_groove_snap = [.5, .8, .5, .8],
    tongue_and_groove_pull = .1,

    bottom_color = "#FF69B4",
    top_color = "#fff",

    $fn = 24
);
color("#fff") translate([50 / 2, -1, -1]) cube([100, 100, 100]);
}