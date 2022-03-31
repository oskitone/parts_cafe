module rounded_corner_cutoff(
    height,
    radius = 0,
    angle = 0,

    e = 1.123
) {
    difference() {
        rotate([0, 0, angle]) {
            cube([radius + e, radius + e, height]);
        }

        translate([0, 0, -e]) {
            cylinder(r = radius, h = height + e * 2);
        }
    }
}
