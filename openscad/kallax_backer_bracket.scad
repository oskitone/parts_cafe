module kallax_backer_bracket(
    wall = 2,

    height = 25.4,

    backer_hold_depth = 25.4,
    shelf_hold_depth = 25.4,

    backer_thickness = 5,
    shelf_thickness = 16,

    tolerance = .1
) {
    e = .0941;

    backer_width = backer_thickness + (wall + tolerance) * 2;
    stress_point_x = backer_width;

    function get_xys(thickness) = [0, wall + thickness + tolerance * 2];

    module _backer_hold() {
        for (x = get_xys(backer_thickness)) {
            translate([x, 0, 0]) {
                cube([wall, backer_hold_depth + wall, height]);
            }
        }

        cube([backer_width, wall, height]);
    }

    module _shelf_hold() {
        for (y = get_xys(shelf_thickness)) {
            translate([backer_width - e, y, 0]) {
                cube([shelf_hold_depth + wall + e, wall, height]);
            }
        }
    }

    module _stress_relief() {
        cutout_size = (stress_point_x + e) * 2;

        difference() {
            translate([stress_point_x, 0, 0]) {
                cylinder(
                    r = stress_point_x,
                    h = height
                );
            }

            translate([-e, e, -e]) {
                cube([cutout_size, cutout_size, height + e * 2]);
            }

            translate([stress_point_x, 0, -e]) {
                cylinder(
                    r = stress_point_x - wall,
                    h = height + e * 2
                );
            }
        }
    }

    _backer_hold();
    _shelf_hold();
    _stress_relief();
}

kallax_backer_bracket();