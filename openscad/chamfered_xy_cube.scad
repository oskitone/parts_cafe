module chamfered_xy_cube(dimensions, radius = 0, debug = false) {
    e = .01;

    radius = min(
        dimensions.x / 2,
        dimensions.y / 2,
        dimensions.z / 2,
        radius
    );

    positions = [
        // Bottom
        [0, radius, 0],
        [radius, 0, 0],
        [dimensions.x - radius - e, 0, 0],
        [dimensions.x - e, radius, 0],
        [dimensions.x - e, dimensions.y - radius - e, 0],
        [dimensions.x - radius - e, dimensions.y - e, 0],
        [radius, dimensions.y - e, 0],
        [0, dimensions.y - radius - e, 0],

        // Top
        [0, radius, dimensions.z - e],
        [radius, 0, dimensions.z - e],
        [dimensions.x - radius - e, 0, dimensions.z - e],
        [dimensions.x - e, radius, dimensions.z - e],
        [dimensions.x - e, dimensions.y - radius - e, dimensions.z - e],
        [dimensions.x - radius - e, dimensions.y - e, dimensions.z - e],
        [radius, dimensions.y - e, dimensions.z - e],
        [0, dimensions.y - radius - e, dimensions.z - e],
    ];

    if (debug) {
        % translate([e, e, e]) {
            cube([dimensions.x - e * 2, dimensions.y - e * 2, dimensions.z - e * 2]);
        }
    }

    if (radius > 0) {
        hull() {
            for (position = positions) {
                translate(position) cube([e, e, e]);
            }
        }
    } else {
        cube(dimensions);
    }
}

* chamfered_xy_cube([30, 20, 15], abs($t - .5) * 2 * 8, debug = true);