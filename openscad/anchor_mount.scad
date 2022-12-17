include <nuts_and_bolts.scad>;

// TODO: DFM. maybe square anchor w/ ramped walls up

ANCHOR_MOUNT_MIN_DISTANCE = max(SCREW_HEAD_DIAMETER, NUT_DIAMETER) / 2;

module anchor_mount(
    width = undef,
    hole_diameter = SCREW_DIAMETER,
    distance = ANCHOR_MOUNT_MIN_DISTANCE,
    height = 2,
    extension = 0,
    tolerance = 0,

    debug = false
) {
    e = .02519;

    width = width != undef
        ? width
        : max(SCREW_HEAD_DIAMETER, NUT_DIAMETER);

    translate([0, distance, 0]) {
        difference() {
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

            translate([0, 0, -e]) {
                cylinder(
                    d = hole_diameter + tolerance * 2,
                    h = height + e * 2
                );
            }
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
