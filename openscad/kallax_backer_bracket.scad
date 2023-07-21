module kallax_backer_bracket(
    wall = 2,

    height = 25.4,

    backer_hold_depth = 25.4,
    shelf_hold_depth = 25.4,

    backer_thickness = 5,
    shelf_thickness = 16.5,

    tolerance = .1
) {
    e = .0941;

    backer_width = backer_thickness + (wall + tolerance) * 2;

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

    _backer_hold();
    _shelf_hold();
}

kallax_backer_bracket();