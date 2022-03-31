module rounded_cube(dimensions, radius = 0) {
    positions = [
        [radius, radius, radius],
        [dimensions.x - radius, radius, radius],
        [dimensions.x - radius, dimensions.y - radius, radius],
        [radius, dimensions.y - radius, radius],
        [radius, radius, dimensions.z - radius],
        [dimensions.x - radius, radius, dimensions.z - radius],
        [dimensions.x - radius, dimensions.y - radius, dimensions.z - radius],
        [radius, dimensions.y - radius, dimensions.z - radius],
    ];

    if (radius > 0) {
        hull() {
            for (position = positions) {
                translate(position) sphere(r = radius);
            }
        }
    } else {
        cube(dimensions);
    }
}
