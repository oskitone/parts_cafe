module cap_blank(
    dimensions = [12, 12, 8],

    // Usage: exposure beyond enclosure after travel
    contact_dimensions = [8, 8, 2],

    fillet = 1,

    brim_dimensions = [16, 16, 1]
) {
    e = .0418;

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
                cube([width, length, e]);
            }
        }
    }

    if (brim_dimensions.z > 0) {
        translate([
            (brim_dimensions.x - dimensions.x) / -2,
            (brim_dimensions.y - dimensions.y) / -2,
            0
        ]) {
            cube(brim_dimensions);
        }
    }

    hull() {
        _layer(flat = true, z = brim_dimensions.z - e);
        _layer(z = base_height);

        _layer(
            width = contact_dimensions.x,
            length = contact_dimensions.y,
            z = dimensions.z - fillet
        );
    }
}