function get_rounded_cube_corner_positions(
    dimensions, radius = 0, z = undef
) = (
    let (z = z != undef ? z : radius)

    [
        [radius, radius, z],
        [dimensions.x - radius, radius, z],
        [dimensions.x - radius, dimensions.y - radius, z],
        [radius, dimensions.y - radius, z],
    ]
);

module rounded_cube_corners(
    dimensions, radius = 0, z = undef,
    flat = false,
    center = false
) {
    positions = get_rounded_cube_corner_positions(dimensions, radius, z);

    for (position = positions) {
        translate([
            center ? dimensions.x / -2 : 0,
            center ? dimensions.y / -2 : 0,
            0
        ]) {
            translate(position) {
                if (flat) {
                    cylinder(r = radius);
                } else {
                    sphere(r = radius);
                };
            }
        }
    }
}

module rounded_cube(dimensions, radius = 0, center = false) {
    translate([
        center ? dimensions.x / -2 : 0,
        center ? dimensions.y / -2 : 0,
        0
    ]) {
        if (radius > 0) {
            hull() {
                rounded_cube_corners(dimensions, radius);
                rounded_cube_corners(dimensions, radius, dimensions.z - radius);
            }
        } else {
            cube(dimensions);
        }
    }
}

module rounded_top_cube(dimensions, radius = 0, center = false) {
    if (radius > 0) {
        hull() {
            rounded_cube_corners(dimensions, radius, 0, flat = true, center);
            rounded_cube_corners(dimensions, radius, dimensions.z - radius, center);
        }
    } else {
        cube(dimensions);
    }
}