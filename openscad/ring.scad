module ring(
    diameter,
    height,
    thickness, inner_diameter = 0
) {
    e = 0.034;
    thickness = thickness != undef
        ? thickness
        : (diameter - inner_diameter) / 2;

    difference() {
        cylinder(d = diameter, h = height);

        translate([0, 0, -e]) {
            cylinder(d = diameter - thickness * 2, h = height + e * 2);
        }
    }
}
