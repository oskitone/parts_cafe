module cylinder_grip(
    diameter,
    height,
    count,
    rotation_offset = 0,
    size = 1,
    $fn = $fn
) {
    if (size > 0) {
        count = count != undef
            ? count
            : floor((diameter * PI) / size / 2);

        for (i = [0 : count - 1]) {
            rotate([0, 0, rotation_offset + 360 * i / count]) {
                translate([0, diameter / 2, 0]) {
                    cylinder(d = size, h = height);
                }
            }
        }
    }
}
