include <pcb_mount_post.scad>;

module pcb_base(
    width, length,
    height = 2.5, // enclosure_half wall

    battery_holder_height = 12,

    min_clearance = 3,
    screw_length = 25.4 / 4,
    perfboard_height = 1,

    pcb_mount_post_ceiling = 2,

    screw_positions = [],

    tolerance = .1,

    quick_preview = false
) {
    e = .123;

    pcb_clearance = max(
        get_pcb_mount_post_min_height(pcb_mount_post_ceiling, tolerance),
        min_clearance,
        screw_length - perfboard_height,
        battery_holder_height
    );

    module _screw_exits() {
        for (p = screw_positions) {
            translate([p.x, p.y, -e]) {
                cylinder(
                    d = get_pcb_mount_post_hole_diameter(tolerance = tolerance),
                    h = height + e * pcb_mount_post_ceiling,
                    $fn = quick_preview ? undef : 24
                );
            }
        }
    }

    module _mount_posts() {
        for (p = screw_positions) {
            translate([p.x, p.y, height - e]) {
                pcb_mount_post(
                    height = pcb_clearance + e,
                    ceiling = 2,
                    tolerance = tolerance,
                    quick_preview = quick_preview
                );
            }
        }
    }

    difference() {
        cube([width, length, height]);
        _screw_exits();
    }
    _mount_posts();
}

pcb_base(
    width = 2.54 * 51,
    length = 2.54 * 24,
    screw_positions = [
        [2.54 * 3, 2.54 * (24 - 3)],
        [2.54 * (24 - 3), 2.54 * 3],

        [2.54 * (51 - 3), 2.54 * 3],
        [2.54 * (51 - 3), 2.54 * (24 - 3)],
    ]
);