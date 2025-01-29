include <pcb.scad>;
include <pcb_mount_post.scad>;

PCB_BASE_BASE_HEIGHT = 2.5;

function get_pcb_base_pcb_bottom_clearance(
    min_clearance = 10,
    nut_z_clearance = PCB_MOUNT_NUT_Z_CLEARANCE,
    screw_length = 25.4 / 4,
    pcb_height = PCB_HEIGHT,
    pcb_mount_post_ceiling = PCB_MOUNT_POST_CEILING
) = (
    max(
        min_clearance,
        get_pcb_mount_post_min_height(pcb_mount_post_ceiling, nut_z_clearance),
        screw_length - pcb_height
    )
);

function get_pcb_base_total_height(
    min_clearance = 10,
    nut_z_clearance = PCB_MOUNT_NUT_Z_CLEARANCE,
    screw_length = 25.4 / 4,
    pcb_height = PCB_HEIGHT,
    pcb_mount_post_ceiling = PCB_MOUNT_POST_CEILING,

    base_height = PCB_BASE_BASE_HEIGHT
) = (
    let (pcb_bottom_clearance = get_pcb_base_pcb_bottom_clearance(
        min_clearance = min_clearance,
        nut_z_clearance = nut_z_clearance,
        screw_length = screw_length,
        pcb_height = pcb_height,
        pcb_mount_post_ceiling = pcb_mount_post_ceiling
    ))

    base_height + pcb_bottom_clearance
);

module pcb_base(
    width, length, base_height = PCB_BASE_BASE_HEIGHT,

    pcb_bottom_clearance = undef,
    min_pcb_bottom_clearance = MIN_PCB_BOTTOM_CLEARANCE,
    pcb_mount_post_ceiling = PCB_MOUNT_POST_CEILING,

    screw_positions = [],

    tolerance = 0,

    show_dfm = true,
    quick_preview = false
) {
    e = .0123;

    pcb_bottom_clearance = pcb_bottom_clearance != undef
        ? pcb_bottom_clearance
        : get_pcb_base_pcb_bottom_clearance(
            min_clearance = min_pcb_bottom_clearance,
            pcb_mount_post_ceiling = pcb_mount_post_ceiling
        );

    module _screw_exits() {
        for (p = screw_positions) {
            translate([p.x, p.y, -e]) {
                cylinder(
                    d = get_pcb_mount_post_hole_diameter(tolerance = tolerance),
                    h = base_height + e * 2,
                    $fn = quick_preview ? undef : 24
                );
            }
        }
    }

    module _mount_posts() {
        for (p = screw_positions) {
            translate([p.x, p.y, base_height - e]) {
                pcb_mount_post(
                    height = pcb_bottom_clearance + e,
                    ceiling = 2,
                    tolerance = tolerance,
                    include_sacrificial_bridge = show_dfm,
                    quick_preview = quick_preview
                );
            }
        }
    }

    difference() {
        cube([width, length, base_height]);
        _screw_exits();
    }
    _mount_posts();
}