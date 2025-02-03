include <nuts_and_bolts.scad>;

// For securely mounting a PCB with nuts and bolts

// TODO: fix this being too tight even with standard .1 tolerance

PCB_MOUNT_POST_CEILING = 2;
PCB_MOUNT_NUT_Z_CLEARANCE = .2;

function get_pcb_mount_post_hole_diameter(
    screw_diameter = SCREW_DIAMETER,
    tolerance = 0
) = (screw_diameter + tolerance * 2);

function get_pcb_mount_post_min_height(
    ceiling = PCB_MOUNT_POST_CEILING,
    nut_z_clearance = PCB_MOUNT_NUT_Z_CLEARANCE,
    min_pcb_bottom_clearance = MIN_PCB_BOTTOM_CLEARANCE
) = (
    NUT_HEIGHT + nut_z_clearance * 2
    + ceiling + min_pcb_bottom_clearance
);

module pcb_mount_post(
    width = NUT_DIAMETER + 4,
    length = NUT_DIAMETER,
    height = 10,

    ceiling = PCB_MOUNT_POST_CEILING,

    screw_diameter = SCREW_DIAMETER,

    nut_z_clearance = PCB_MOUNT_NUT_Z_CLEARANCE,

    tolerance = 0,

    // Conservatively larger than needed to ensure layers aren't skipped
    bridge_height = .4,
    include_sacrificial_bridge = true,

    quick_preview = true
) {
    e = .0253;

    nut_lock_dimensions = [
        NUT_DIAMETER + tolerance * 2 + e,
        NUT_DIAMETER + tolerance * 2 + e,
        NUT_HEIGHT + nut_z_clearance * 2
    ];

    hole_diameter = get_pcb_mount_post_hole_diameter(
        tolerance = tolerance
    );

    nut_lock_z = height - ceiling - nut_lock_dimensions.z;

    if (nut_lock_dimensions.x <= width && nut_lock_dimensions.y <= length) {
        echo("WARNING: pcb_mount_post nut lock is inaccesible");
    }

    module _recenter(xyz = [0, 0, 0], z = 0) {
        translate([(width - xyz.x) / 2, (length - xyz.y) / 2, z]) {
            children();
        }
    }

    module _sacrificial_bridge() {
        z = nut_lock_z + nut_lock_dimensions.z - e;

        translate([e, e, z]) {
            cube([width - e * 2, length - e * 2, bridge_height]);
        }
    }

    translate([width / -2, length / -2, 0]) {
        difference() {
            cube([width, length, height]);

            _recenter(z = -e) {
                cylinder(
                    d = hole_diameter,
                    h = height + e * 2,
                    $fn = quick_preview ? undef : 24
                );
            }

            _recenter(nut_lock_dimensions, nut_lock_z) {
                cube(nut_lock_dimensions);
            }
        }

        if (include_sacrificial_bridge) {
            _sacrificial_bridge();
        }
    }
}

* rotate([0, 0, $t >= .5 ? 90 : 0]) pcb_mount_post(
    width = NUT_DIAMETER + ($t >= .5 ? 4 : 0),
    length = NUT_DIAMETER + ($t >= .5 ? 0 : 4),
    quick_preview = false
);
