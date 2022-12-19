include <flat_top_rectangular_pyramid.scad>;
include <nuts_and_bolts.scad>;
include <supportless_screw_cavity.scad>;

// TODO: DFM. maybe square anchor w/ ramped walls up

ANCHOR_MOUNT_MIN_DISTANCE = max(SCREW_HEAD_DIAMETER, NUT_DIAMETER) / 2;

module anchor_mount(
    width = undef,
    hole_diameter = SCREW_DIAMETER,
    distance = ANCHOR_MOUNT_MIN_DISTANCE,
    height = 2,
    extension = 0,
    tolerance = 0,

    include_ramp_walls = true,
    ramp_wall_width = .8,

    debug = false
) {
    e = .02519;

    width = width != undef
        ? width
        : max(SCREW_HEAD_DIAMETER, NUT_DIAMETER) + tolerance * 2;
    total_length = distance + width / 2 + extension;

    y = -(distance + extension);

    module _base() {
        if (include_ramp_walls) {
            total_width = width + ramp_wall_width * 2;

            translate([total_width / -2, y, 0]) {
                cube([total_width, total_length, height]);
            }
        } else {
            hull() {
                cylinder(
                    d = width,
                    h = height
                );

                translate([
                    width / -2,
                    width / -2 - distance + width / 2 - extension,
                    0
                ]) {
                    cube([width, e, height]);
                }
            }
        }
    }

    module _ramp_walls() {
        for (x = [ramp_wall_width, -width + e]) {
            translate([width / -2 - x, y, height - e]) {
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

    translate([0, distance, 0]) {
        difference() {
            _base();

            translate([0, 0, height + e]) mirror([0, 0, 1]) {
                supportless_screw_cavity(
                    height = height + e * 2,
                    span = width,
                    diameter = hole_diameter
                );
            }
        }

        if (include_ramp_walls) {
            _ramp_walls();
        }

        if (debug) {
            translate([0, 0, height - e]) {
                % cylinder(
                    d = NUT_DIAMETER,
                    h = NUT_HEIGHT
                );
            }
        }
    }
}
