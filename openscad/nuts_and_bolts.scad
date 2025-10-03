SCREW_DIAMETER = 3.2; // TODO: confirm and standardize against PCB_HOLE_DIAMETER
SCREW_HEAD_DIAMETER = 6;
SCREW_HEAD_HEIGHT = 2.1;
NUT_DIAMETER = 6.4;
NUT_HEIGHT = 2.4;

FLATHEAD_SCREWDRIVER_POINT = .8;

module nut(
    diameter = NUT_DIAMETER,
    height = NUT_HEIGHT,
    hole_diameter = SCREW_DIAMETER
) {
    e = .0852;

    difference() {
        translate([diameter / -2, diameter / -2, 0]) {
            cube([diameter, diameter, height]);
        }

        translate([0, 0, -e]) {
            cylinder(
                d = hole_diameter,
                h = height + 2 * 2
            );
        }
    }
}

module nuts(
    pcb_position = [],
    positions = [],
    y = 0,
    z = 0,
    diameter = NUT_DIAMETER,
    height = NUT_HEIGHT,
    rotation = 0
) {
    for (xy = positions) {
        translate([pcb_position.x + xy.x, y + pcb_position.y + xy.y, z]) {
            rotate([0, 0, rotation]) {
                translate([diameter / -2, diameter / -2, 0]) {
                    cube([diameter, diameter, height]);
                }
            }
        }
    }
}

module screw(
    diameter = SCREW_DIAMETER,
    length = 3/4 * 25.4,
    head_on_bottom = true
) {
    e = .03;

    translate([0, 0, head_on_bottom ? 0 : length]) {
        cylinder(
            d = SCREW_HEAD_DIAMETER,
            h = SCREW_HEAD_HEIGHT
        );
    }

    translate([0, 0, head_on_bottom ? SCREW_HEAD_HEIGHT - e : 0]) {
        cylinder(
            d = diameter,
            h = length + e
        );
    }
}

module screws(
    positions = PCB_HOLE_POSITIONS,
    pcb_position = [],
    diameter = SCREW_DIAMETER,
    length = 3/4 * 25.4,
    head_on_bottom = true,
    z = 0
) {
    for (xy = positions) {
        translate([
            pcb_position.x + xy.x,
            pcb_position.y + xy.y,
            z
        ]) {
            screw(diameter, length, head_on_bottom);
        }
    }
}
