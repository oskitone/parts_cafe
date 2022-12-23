include <anchor_mount.scad>;
include <diagonal_grill.scad>;
include <donut.scad>;
include <nuts_and_bolts.scad>;
include <perfboard.scad>;
include <ring.scad>;
include <speaker.scad>;

function get_speaker_pocket_outer_diameter(
    speaker_diameter,
    tolerance,
    wall
) = (
    speaker_diameter + (tolerance + wall) * 2
);

module speaker_pocket(
    wall = 2,
    ceiling_depth = 1.2,
    floor_depth = .6,

    tolerance = 0,

    anchor_mount_count = 3,
    anchor_mount_nut_distance = ANCHOR_MOUNT_MIN_NUT_DISTANCE,
    anchor_mount_nut_max_distance = ANCHOR_MOUNT_MIN_NUT_DISTANCE,

    fillet = 1,

    grill_size = 2,
    grill_angle = 45,

    show_speaker = false,
    show_floor = true,

    debug = false,

    outline_gutter = undef,
    outline_depth = .6,
    outline_length = 1,

    speaker_diameter = SPEAKER_DIAMETER,
    speaker_brim_height = SPEAKER_BRIM_HEIGHT,
    speaker_brim_depth = SPEAKER_BRIM_DEPTH,
    speaker_magnet_height = SPEAKER_MAGNET_HEIGHT,
    speaker_magnet_diameter = SPEAKER_MAGNET_DIAMETER,
    speaker_total_height = SPEAKER_TOTAL_HEIGHT,
    speaker_cone_height = SPEAKER_CONE_HEIGHT,

    // Wall, fillet, and grill must have matching fragment count to avoid cracks
    $wall_fn = 60
) {
    e = .042;

    outer_diameter = get_speaker_pocket_outer_diameter(
        speaker_diameter,
        tolerance,
        wall
    );
    outer_height = floor_depth + speaker_total_height + ceiling_depth;

    inner_diameter = outer_diameter - wall * 2;
    exposure_diameter = inner_diameter - speaker_brim_depth * 2 + tolerance * 2;

    module _outer_wall(segments = $wall_fn) {
        // Fillet can't be larger than wall or there'll be weird vertical gaps
        fillet = min(wall, fillet);

        difference() {
            hull() {
                cylinder(
                    d = outer_diameter,
                    h = fillet > 0 ? e : outer_height,
                    $fn = segments
                );

                if (fillet > 0) {
                    translate([0, 0, outer_height - fillet]) {
                        donut(
                            diameter = outer_diameter,
                            thickness = fillet * 2,
                            segments = segments,
                            $fn = 12
                        );
                    }
                }
            }

            translate([0, 0, -e]) {
                cylinder(
                    d = inner_diameter,
                    h = outer_height + e * 2,
                    $fn = segments
                );
            }
        }
    }

    module _brim() {
        translate([0, 0, outer_height - ceiling_depth]) {
            ring(
                diameter = outer_diameter - wall * 2 + e * 2,
                inner_diameter = exposure_diameter,
                height = ceiling_depth,
                $fn = $wall_fn
            );
        }
    }

    module _grill_cover() {
        z = outer_height - ceiling_depth;
        diameter = exposure_diameter + e * 2;

        intersection() {
            translate([diameter / -2, diameter / -2, z]) {
                diagonal_grill(
                    diameter, diameter, ceiling_depth,
                    size = grill_size,
                    angle = grill_angle
                );
            }

            translate([0, 0, z]) {
                cylinder(
                    d = diameter,
                    h = ceiling_depth,
                    $fn = $wall_fn
                );
            }
        }
    }

    module _anchor_mounts() {
        for (i = [0 : anchor_mount_count - 1]) {
            rotate([0, 0, (360 / anchor_mount_count) * i]) {
                translate([0, outer_diameter / 2, 0]) {
                    anchor_mount(
                        extension = wall / 2,
                        nut_distance = anchor_mount_nut_distance,
                        nut_max_distance = anchor_mount_nut_max_distance,
                        tolerance = tolerance,
                        show_nut = true
                    );
                }
            }
        }
    }

    module _outline_cavity() {
        outline_gutter = outline_gutter != undef
            ? outline_gutter
            : (outer_diameter - exposure_diameter - sqrt(2 * pow(grill_size, 2))
                - outline_length * 2) / 2 + e;

        translate([0, 0, outer_height - outline_depth]) {
            ring(
                diameter = outer_diameter - outline_gutter * 2,
                thickness = outline_length,
                height = outline_depth + e,
                $fn = $wall_fn
            );
        }
    }

    module _floor() {
        cylinder(
            d = inner_diameter - tolerance * 2,
            h = floor_depth,
            $fn = $wall_fn
        );
    }

    difference() {
        union() {
            _outer_wall();
            _brim();
            _anchor_mounts();

            if (show_floor && floor_depth > 0) {
                _floor();
            }

            if (!debug) {
                _grill_cover();
            }
        }

        _outline_cavity();

        if (debug) {
            translate([0, outer_diameter / -2 - e, -e]) {
                cube([
                    outer_diameter / 2 + e,
                    outer_diameter + e * 2,
                    outer_height + e * 2
                ]);
            }
        }
    }

    if (show_speaker) {
        translate([0, 0, floor_depth]) {
            % speaker(
                speaker_diameter,
                speaker_brim_height,
                speaker_brim_depth,
                speaker_magnet_height,
                speaker_magnet_diameter,
                speaker_total_height,
                speaker_cone_height
            );
        }
    }
}

module perfboard_speaker_pocket(
    wall = 2,

    tolerance = 0,

    anchor_mount_count = 2,

    fillet = 1,

    show_speaker = false,
    show_floor = true,
    show_perfboard = false,

    debug = false,

    grid = PERFBOARD_PITCH,

    speaker_diameter = SPEAKER_DIAMETER,
    speaker_brim_height = SPEAKER_BRIM_HEIGHT,
    speaker_brim_depth = SPEAKER_BRIM_DEPTH,
    speaker_magnet_height = SPEAKER_MAGNET_HEIGHT,
    speaker_magnet_diameter = SPEAKER_MAGNET_DIAMETER,
    speaker_total_height = SPEAKER_TOTAL_HEIGHT,
    speaker_cone_height = SPEAKER_CONE_HEIGHT,
) {
    function even_up(
        n
    ) = (
        n + (n % 2)
    );

    rotated_grid = sqrt(2 * pow(grid, 2));
    outer_diameter = get_speaker_pocket_outer_diameter(
        speaker_diameter,
        tolerance,
        wall
    );
    minimum_outer_diameter = outer_diameter + ANCHOR_MOUNT_MIN_NUT_DISTANCE * 2;

    rotate([0, 0, 45]) {
        speaker_pocket(
            tolerance = tolerance,

            anchor_mount_count = anchor_mount_count,
            anchor_mount_nut_max_distance =
                // TODO: tidy/obviate
                ANCHOR_MOUNT_MIN_NUT_DISTANCE + rotated_grid - SCREW_DIAMETER / 2,

            fillet = fillet,

            show_speaker = show_speaker,
            show_floor = show_floor,

            debug = debug,

            speaker_diameter = speaker_diameter + .1,
            speaker_brim_height = speaker_brim_height,
            speaker_brim_depth = speaker_brim_depth,
            speaker_magnet_height = speaker_magnet_height,
            speaker_magnet_diameter = speaker_magnet_diameter,
            speaker_total_height = speaker_total_height,
            speaker_cone_height = speaker_cone_height
        );
    }

    if (show_perfboard) {
        size = get_pefboard_dimension(outer_diameter * 1.5);

        translate([size / -2, size / -2, -PERFBOARD_HEIGHT]) {
            % perfboard(
                width = size,
                length = size
            );
        }
    }
}

* perfboard_speaker_pocket(
    tolerance = .1,

    show_speaker = true,
    show_perfboard = true,

    debug = true
);
