include <nuts_and_bolts.scad>;
include <pcb_stool.scad>;

// For PCB registration/mounting on both screw and post holes

module pcb_mounting_columns(
    pcb_position = [0,0,0],

    screw_head_clearance = 0,
    wall = 1.2, // ENCLOSURE_INNER_WALL

    pcb_screw_hole_positions = [], // [0,0]
    pcb_post_hole_positions = [], // [0,0]

    tolerance = 0,

    enclosure_floor_ceiling = 1.8, // ENCLOSURE_FLOOR_CEILING
    screw_head_height = SCREW_HEAD_HEIGHT,
    screw_head_diameter = SCREW_HEAD_DIAMETER,
    pcb_hole_diameter = 3.2, // PCB_HOLE_DIAMETER

    registration_nub = true,
    registration_nub_height = 1.6, // PCB_HEIGHT

    support_web_length = undef,

    quick_preview = true
) {
    e = .0419;

    z = enclosure_floor_ceiling - e;

    head_column_height = screw_head_height + enclosure_floor_ceiling
        + screw_head_clearance;
    shaft_column_z = head_column_height - e;

    module _column(p, screw = false, post = false) {
        x = pcb_position.x + p.x;
        y = pcb_position.y + p.y;

        if (screw) {
            translate([x, y, z]) {
                cylinder(
                    h = head_column_height - z,
                    d = screw_head_diameter + tolerance * 2 + wall * 2
                );
            }

            translate([x, y, shaft_column_z]) {
                cylinder(
                    h = pcb_position.z - shaft_column_z,
                    d = pcb_hole_diameter + tolerance * 2 + wall * 2
                );
            }
        } else {
            translate([x, y, z]) {
                pcb_stool(
                    height = pcb_position.z - z,
                    support_web_length = support_web_length,
                    registration_nub = registration_nub,
                    registration_nub_height = registration_nub_height,
                    tolerance = tolerance,
                    quick_preview = quick_preview
                );
            }
        }
    }

    for (p = pcb_screw_hole_positions) {
        _column(p, screw = true);
    }

    for (p = pcb_post_hole_positions) {
        _column(p, post = true);
    }
}
