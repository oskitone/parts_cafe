module chamfered_cube(dimensions, radius = 0, debug = false) {
    e = .01;

    radius = min(
        dimensions.x / 2,
        dimensions.y / 2,
        dimensions.z / 2,
        radius
    );

    positions = [
        // Bottom bottom
        [radius, radius, 0],
        [dimensions.x - radius - e, radius, 0],
        [radius, dimensions.y - radius - e, 0],
        [dimensions.x - radius - e, dimensions.y - radius - e, 0],

        // Bottom top
        [0, radius, radius],
        [radius, 0, radius],
        [dimensions.x - radius - e, 0, radius],
        [dimensions.x - e, radius, radius],
        [dimensions.x - e, dimensions.y - radius - e, radius],
        [dimensions.x - radius - e, dimensions.y - e, radius],
        [radius, dimensions.y - e, radius],
        [0, dimensions.y - radius - e, radius],

        // Top bottom
        [0, radius, dimensions.z - radius - e],
        [radius, 0, dimensions.z - radius - e],
        [dimensions.x - radius - e, 0, dimensions.z - radius - e],
        [dimensions.x - e, radius, dimensions.z - radius - e],
        [dimensions.x - e, dimensions.y - radius - e, dimensions.z - radius - e],
        [dimensions.x - radius - e, dimensions.y - e, dimensions.z - radius - e],
        [radius, dimensions.y - e, dimensions.z - radius - e],
        [0, dimensions.y - radius - e, dimensions.z - radius - e],

        // Top top
        [radius, radius, dimensions.z - e],
        [dimensions.x - radius - e, radius, dimensions.z - e],
        [radius, dimensions.y - radius - e, dimensions.z - e],
        [dimensions.x - radius - e, dimensions.y - radius - e, dimensions.z - e],
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

* chamfered_cube([30, 20, 15], abs($t - .5) * 2 * 8, debug = true);