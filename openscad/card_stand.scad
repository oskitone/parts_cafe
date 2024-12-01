include <flat_top_rectangular_pyramid.scad>;

US_QUARTER_DIAMETER = 24.26;

module card_stand(
    grip_diameter = 10,
    grip_gap = 1.6,
    grip_wall = 2,

    base_diameter = US_QUARTER_DIAMETER,
    base_height = 2,

    tolerance = -.05,

    $fn = 60
) {
    e = .031;

    module _base() {
        cylinder(
            d = base_diameter,
            h = base_height
        );
    }

    module _grip() {
        intersection() {
            for (x = [
                -grip_wall - grip_gap / 2 - tolerance,
                grip_gap / 2 + tolerance
            ]) {
                translate([x, 0, base_height]) {
                    rotate([0, 90, 0]) {
                        cylinder(
                            d = grip_diameter,
                            h = grip_wall
                        );
                    }
                }
            }

            translate([0, 0, base_height - e]) {
                cylinder(
                    d = base_diameter,
                    h = grip_diameter / 2 + e
                );
            }
        }
    }

    module _braces() {
        width = grip_diameter / 2;
        height = width * (2/3);

        xs = [
            -width - grip_gap / 2 - grip_wall - tolerance + e,
            grip_gap / 2 + grip_wall + tolerance - e
        ];

        for (i = [0, 1]) {
            translate([xs[i], grip_wall / -2, base_height - e]) {
                flat_top_rectangular_pyramid(
                    top_width = 0,
                    top_length = grip_wall,

                    bottom_width = width,
                    bottom_length = grip_wall,

                    height = height + e,

                    top_weight_x = i == 0 ? 1 : 0
                );
            }
        }
    }

    _base();
   _grip();
   _braces();
}

card_stand();