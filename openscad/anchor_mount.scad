include <flat_top_rectangular_pyramid.scad>;
include <nuts_and_bolts.scad>;
include <supportless_screw_cavity.scad>;

// TODO: DFM. maybe square anchor w/ ramped walls up

ANCHOR_MOUNT_MIN_DISTANCE = max(SCREW_HEAD_DIAMETER, NUT_DIAMETER) / 2;

module anchor_mount(
    width = undef,
    hole_diameter = SCREW_DIAMETER,
    height = 2,
    extension = 0,
    tolerance = 0,

    // TODO: rename/obviate to make obvious this is to center of nut/screw
    min_distance = ANCHOR_MOUNT_MIN_DISTANCE,
    max_distance = ANCHOR_MOUNT_MIN_DISTANCE,

    nut_distance = ANCHOR_MOUNT_MIN_DISTANCE,

    include_ramp_walls = true,
    ramp_wall_width = .8,

    debug = false
) {
    e = .02519;

    width = width != undef
        ? width
        : max(SCREW_HEAD_DIAMETER, NUT_DIAMETER) + tolerance * 2;
    total_length = max_distance + width / 2 + extension;

    nut_distance = nut_distance != undef
        ? nut_distance
        : (max_distance - min_distance) / 2;

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
        // TODO: DFM
        translate([hole_diameter / -2, hole_diameter / 2, -e]) {
            cube([
                hole_diameter,
                hole_diameter + (max_distance - min_distance),
                height + e * 2
            ]);
        }
    }

    difference() {
        _base();
        _screw_cavity();
    }

    if (include_ramp_walls) {
        _ramp_walls();
    }

    if (debug) {
        translate([0, nut_distance, height - e]) {
            % # nut();
        }
    }
}
