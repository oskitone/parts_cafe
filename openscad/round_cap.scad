module round_cap(
    inner_diameter = 31.1,
    inner_depth = 2,
    outer_diameter = 31.1 + 2 * 2,
    outer_depth = 2 + 2,

    tolerance = 0
) {
    e = .014;

    difference() {
        cylinder(
            d = outer_diameter,
            h = outer_depth
        );

        translate([0, 0, outer_depth - inner_depth]) {
            cylinder(
                d = inner_diameter + tolerance * 2,
                h = inner_depth + e
            );
        }
    }
}

round_cap($fn = 120, tolerance = .1);