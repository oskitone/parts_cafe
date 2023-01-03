include <nuts_and_bolts.scad>;
include <ring.scad>;

MOUNTING_BAR_HOLE_DIAMETER = 7;
MOUNTING_BAR_MATERIAL_DEPTH = 2;

module mount_block(
    width = 40,
    length = 40,
    height = 40,

    through_holes_x = [20],
    through_holes_z = [40 * (.2), 40 * (1 - .2)],
    through_hole_diameter = 4,
    through_hole_fastener_depth = 8,
    through_hole_fastener_diameter = 9,

    _bottom_clamp_cavity_depth = 3,
    _bottom_clamp_cavity_diameter = 32,

    tolerance = 0
) {
    e = .0418;

    module _through_holes() {
        module _hole(rotation = [0, 0, 0], include_fastener = true) {
            rotate(rotation) {
                if (include_fastener) {
                    cylinder(
                        d = through_hole_fastener_diameter + tolerance * 2,
                        h = through_hole_fastener_depth + e
                    );
                }

                cylinder(
                    d = through_hole_diameter + tolerance * 2,
                    h = max(width, length, height) + e * 2
                );
            }
        }

        for (z = through_holes_x) {
            translate([-e, length / 2, z]) {
                _hole([0, 90, 0], false);
            }
        }

        for (z = through_holes_z) {
            translate([width / 2, -e, z]) {
                _hole([-90, 0, 0]);
            }
        }
    }

    module _bottom_clamp_cavity() {
        translate([width / 2, length / 2, -e]) {
            cylinder(
                d = _bottom_clamp_cavity_diameter,
                h = _bottom_clamp_cavity_depth + e
            );
        }
    }

    difference() {
        cube([width, length, height]);

        _through_holes();
        _bottom_clamp_cavity();
    }
}

module mount_block_washers(
    mounting_bar_washer_diameter = MOUNTING_BAR_HOLE_DIAMETER,
    mounting_bar_washer_height = MOUNTING_BAR_MATERIAL_DEPTH,

    fastener_gutter_washer_diameter = NUT_DIAMETER,
    fastener_gutter_washer_height = 4,

    inner_diameter = SCREW_DIAMETER,

    tolerance = 0,

    $fn = 24
) {
    plot = max(mounting_bar_washer_diameter, fastener_gutter_washer_diameter)
        + 1;

    for (x = [0, plot]) {
        translate([x, 0, 0]) {
            ring(
                diameter = mounting_bar_washer_diameter - tolerance * 2,
                height = mounting_bar_washer_height,
                inner_diameter = inner_diameter + tolerance * 2
            );
        }

        translate([x, plot, 0]) {
            ring(
                diameter = fastener_gutter_washer_diameter - tolerance * 2,
                height = fastener_gutter_washer_height,
                inner_diameter = inner_diameter + tolerance * 2
            );
        }
    }
}

* mount_block(
    tolerance = .1
);

mount_block_washers(
    tolerance = .1
);
