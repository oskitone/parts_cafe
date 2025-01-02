include <ring.scad>;

module framed_cylinder(
    diameter = 0,
    height = 0,
    size = .1,
    $fn = 12
) {
    for (i = [0 : $fn]) {
        rotate([0, 0, i * 360/$fn]) {
            translate([size / -2, diameter / 2 - size, 0]) {
                cube([size, size, height]);
            }


            for (z = [0, height - size]) {
                translate([0, 0, z]) {
                    ring(
                        diameter, size,
                        thickness = size
                    );
                }
            }
        }
    }
}

* framed_cylinder(
    diameter = 10,
    height = 10
);