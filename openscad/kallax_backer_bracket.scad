include <ring.scad>;

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
    shelf_length = shelf_thickness + (wall + tolerance) * 2;
    stress_point = [
        backer_width - wall,
        shelf_length - wall
    ];

    function get_xys(thickness) = [0, wall + thickness + tolerance * 2];

    module _backer_hold() {
        for (x = get_xys(backer_thickness)) {
            translate([x, shelf_length - wall, 0]) {
                cube([wall, backer_hold_depth + wall, height]);
            }
        }

        translate([0, shelf_length - wall, 0]) {
            cube([backer_width, wall, height]);
        }
    }

    module _shelf_hold() {
        for (y = get_xys(shelf_thickness)) {
            translate([backer_width - wall, y, 0]) {
                cube([shelf_hold_depth + wall, wall, height]);
            }
        }

        translate([backer_width - wall, 0, 0]) {
            cube([wall, shelf_length, height]);
        }
    }

    module _stress_relief() {
        cutout_size = (stress_point.x + e) * 2;

        intersection() {
            translate(stress_point) {
                ring(
                    diameter = stress_point.x * 2,
                    thickness = wall,
                    height = height
                );
            }

            translate([-e, e, -e]) {
                cube([stress_point.x + e * 2, stress_point.y + e * 2, height + e * 2]);
            }
        }
    }

    _backer_hold();
    _shelf_hold();
    _stress_relief();
}

kallax_backer_bracket();