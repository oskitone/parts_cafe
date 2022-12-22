include <breakaway_support.scad>;
include <flat_top_rectangular_pyramid.scad>;
include <nuts_and_bolts.scad>;
include <supportless_screw_cavity.scad>;

ANCHOR_MOUNT_MIN_NUT_DISTANCE = max(SCREW_HEAD_DIAMETER, NUT_DIAMETER) / 2;

module anchor_mount(
    width = undef,
    hole_diameter = SCREW_DIAMETER,
    height = 2,
    extension = 0,
    tolerance = 0,

    // By default, nut is flush to outer wall with no give.
    // Use _max_ to provide "wiggle room"
    nut_distance = ANCHOR_MOUNT_MIN_NUT_DISTANCE,
    nut_min_distance = ANCHOR_MOUNT_MIN_NUT_DISTANCE,
    nut_max_distance = ANCHOR_MOUNT_MIN_NUT_DISTANCE,

    include_ramp_walls = true,
    ramp_wall_width = .8,

    show_dfm = true,
    dfm_layer_height = DEFAULT_DFM_LAYER_HEIGHT,

    show_nut = false
) {
    e = .02519;

    width = width != undef
        ? width
        : max(SCREW_HEAD_DIAMETER, NUT_DIAMETER) + tolerance * 2;
    total_length = nut_max_distance + width / 2 + extension;

    nut_distance = nut_distance != undef
        ? nut_distance
        : (nut_max_distance - nut_min_distance) / 2;

    module _base() {
        total_width = width + ramp_wall_width * 2;

        translate([total_width / -2, -extension, 0]) {
            cube([total_width, total_length, height]);
        }
    }

    module _ramp_walls() {
        for (x = [ramp_wall_width, -width + e]) {
            translate([width / -2 - x, -extension, height - e]) {
                flat_top_rectangular_pyramid(
                    top_width = ramp_wall_width + e,
                    top_length = 0,
                    bottom_width = ramp_wall_width + e,
                    bottom_length = total_length,
                    height = width + e,
                    top_weight_y = 0
                );
            }
        }
    }

    module _screw_cavity() {
        y = hole_diameter / 2;
        length = hole_diameter + (nut_max_distance - nut_min_distance);

        translate([hole_diameter / -2, y, -e]) {
            cube([hole_diameter, length, height + e * 2]);
        }

        if (show_dfm) {
            translate([width / -2, y, height - dfm_layer_height]) {
                cube([width, length, dfm_layer_height + e]);
            }
        }
    }

    difference() {
        _base();
        _screw_cavity();
    }

    if (include_ramp_walls) {
        _ramp_walls();
    }

    if (show_nut) {
        translate([0, nut_distance, height - e]) {
            % # nut();
        }
    }
}
