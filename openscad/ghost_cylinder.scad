include <ring.scad>;

module ghost_cylinder(
    diameter = 0,
    height = 0,
    size = .1,
    $fn = 12
) {
    fragment_length = sin(180 / $fn) * diameter;

    for (i = [0 : $fn]) {
        rotate([0, 0, i * 360/$fn]) {
            translate([size / -2, diameter / 2 - size, 0]) {
                cube([size, size, height]);
            }


            for (z = [0, height - size]) {
                translate([0, diameter / 2, z]) {
                    rotate([0, 0, -180 / $fn]) {
                        translate([0, -size, 0]) {
                            cube([fragment_length, size, size]);
                        }
                    }
                }
            }
        }
    }
}

* ghost_cylinder(
    diameter = 10,
    height = 10
);