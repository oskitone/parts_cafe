include <rounded_xy_cube.scad>;

module cap_blank(
    dimensions = [12, 12, 12],
    contact_dimensions = [8, 8, 2],
    brim_dimensions = [16, 16, 1],
    stilt_dimensions = [8, 8, 0],

    fillet = 1,

    chamfer_stilt_to_brim = true
) {
    e = .0418;

    brim_dimensions = [
        max(brim_dimensions.x, dimensions.x),
        max(brim_dimensions.y, dimensions.y),
        brim_dimensions.z,
    ];

    stilt_to_brim_chamfer = (stilt_dimensions.z > 0 && chamfer_stilt_to_brim)
        ? max(
            (brim_dimensions.x - stilt_dimensions.x) / 2,
            (brim_dimensions.y - stilt_dimensions.y) / 2
        )
        : 0;

    if (stilt_to_brim_chamfer > stilt_dimensions.z) {
        echo("WARNING (cap_blank): stilt_to_brim_chamfer > stilt_dimensions.z");
    }

    // TODO: extract
    module _contact() {
        base_height = dimensions.z - contact_dimensions.z;

        module _layer(
            width = dimensions.x,
            length = dimensions.y,
            z = 0,
            flat = false
        ) {
            if (fillet > 0) {
                for (
                    x = [fillet, width - fillet],
                    y = [fillet, length - fillet]
                ) {
                    translate([
                        x + (dimensions.x - width) / 2,
                        y + (dimensions.y - length) / 2,
                        z
                    ]) {
                        if (flat) {
                            cylinder(
                                r = fillet,
                                h = e
                            );
                        } else {
                            sphere(r = fillet);
                        }
                    }
                }
            } else {
                translate([
                    (dimensions.x - width) / 2,
                    (dimensions.y - length) / 2,
                    z
                ]) {
                    rounded_xy_cube([width, length, e], fillet);
                }
            }
        }

        hull() {
            _layer(flat = true, z = brim_dimensions.z + stilt_dimensions.z - e);
            _layer(z = base_height);

            _layer(
                width = contact_dimensions.x,
                length = contact_dimensions.y,
                z = dimensions.z - fillet
            );
        }
    }

    if (stilt_dimensions.z > 0) {
        translate([
            (stilt_dimensions.x - dimensions.x) / -2,
            (stilt_dimensions.y - dimensions.y) / -2,
            0
        ]) {
            rounded_xy_cube([
                stilt_dimensions.x,
                stilt_dimensions.y,
                stilt_dimensions.z - stilt_to_brim_chamfer + e
            ], fillet);
        }
    }

    if (brim_dimensions.z > 0) {
        hull() {
            if (stilt_to_brim_chamfer > 0) {
                translate([
                    (stilt_dimensions.x - dimensions.x) / -2,
                    (stilt_dimensions.y - dimensions.y) / -2,
                    stilt_dimensions.z - stilt_to_brim_chamfer
                ]) {
                    rounded_xy_cube([
                        stilt_dimensions.x,
                        stilt_dimensions.y,
                        e
                    ], fillet);
                }
            }

            translate([
                (brim_dimensions.x - dimensions.x) / -2,
                (brim_dimensions.y - dimensions.y) / -2,
                stilt_dimensions.z
            ]) {
                rounded_xy_cube(brim_dimensions, fillet);
            }
        }
    }

    _contact();
}