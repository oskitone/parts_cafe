ENCLOSURE_LIP_HEIGHT = 3;

module enclosure_half(
    width, length, height,

    wall = 2.5,
    floor_ceiling = undef,

    add_lip = false,
    remove_lip = false,

    lip_depth = undef,
    lip_height = ENCLOSURE_LIP_HEIGHT,

    fillet = 0,

    // Increase to .2 for looser fit, will need separate fixture
    tolerance = .1,

    include_tongue_and_groove = false,
    tongue_and_groove_end_length = undef,
    tongue_and_groove_snap = undef, // ex: .5, [.25, .75]
    tongue_and_groove_pull = 0,

    outer_color,
    cavity_color
) {
    e = 0.01234;

    groove_depth = wall / 3;
    groove_height = lip_height * .67;

    lip_depth = lip_depth != undef ? lip_depth : (wall - groove_depth) / 2;

    floor_ceiling = floor_ceiling ? floor_ceiling : wall;

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
                _snap = !!tongue_and_groove_snap.y
                    ? tongue_and_groove_snap
                    : [tongue_and_groove_snap, tongue_and_groove_snap];

                snap_width = _snap.x * width + _tolerance;
                snap_length = _snap.y * length + _tolerance;

                z = add_lip ? height - e : height - lip_height -e ;

                translate([(width - snap_width) / 2, -e, z]) {
                    cube([snap_width, length + e * 2, lip_height + e * 2]);
                }

                translate([-e, (length - snap_length) / 2, z]) {
                    cube([width + e * 2, snap_length, lip_height + e * 2]);
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
                cube([width - x * 2, length, lip_height + e]);
            }

            _grooves(
                z = height + lip_height - groove_height,
                bleed = -tolerance
            );
        }
    }

    module _inner_cutout() {
        translate([wall, wall, floor_ceiling]) {
            cube([
                width - wall * 2,
                length - wall * 2,
                height + lip_height + e
            ]);
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
                cube([width, length, lip_height + e]);
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

    difference() {
        color(outer_color) {
            _outer_wall();
        }

        color(cavity_color) {
            _inner_cutout();
            _groove_exposure();
        }
    }
}
