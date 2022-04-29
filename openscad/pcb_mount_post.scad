include <flat_top_rectangular_pyramid.scad>;

NUT_DIAMETER = 6.4;
NUT_HEIGHT = 2.4;

module pcb_mount_post(
    width = NUT_DIAMETER + 4,
    length = NUT_DIAMETER,
    height = 10,

    ceiling = 2,

    stalactite = false,

    screw_diameter = 3.2, // PCB_MOUNT_HOLE_DIAMETER

    layer_height = .2,

    tolerance = 0,

    quick_preview = true
) {
    e = .0253;

    nut_lock_dimensions = [
        NUT_DIAMETER + tolerance * 2 + e,
        NUT_DIAMETER + tolerance * 2 + e,
        NUT_HEIGHT + tolerance * 2
    ];

    hole_diameter = screw_diameter + tolerance * 2;

    access_on_y = length < width;
    bridge_dimensions = [
        access_on_y ? nut_lock_dimensions.x : hole_diameter + layer_height * 2,
        access_on_y ? hole_diameter + layer_height * 2 : nut_lock_dimensions.x,
        layer_height
    ];

    nut_lock_z = height - ceiling - nut_lock_dimensions.z;
    bridge_z = stalactite
        ? nut_lock_z + e
        : nut_lock_z + nut_lock_dimensions.z - e;

    if (nut_lock_dimensions.x <= width && nut_lock_dimensions.y <= length) {
        echo("WARNING: pcb_mount_post nut lock is inaccesible");
    }

    module _center(xyz = [0, 0, 0], z = 0) {
        translate([(width - xyz.x) / 2, (length - xyz.y) / 2, z]) {
            children();
        }
    }

    translate([width / -2, length / -2, 0]) {
        difference() {
            cube([width, length, height]);

            _center(z = -e) {
                cylinder(
                    d = hole_diameter,
                    h = height + e * 2,
                    $fn = quick_preview ? undef : 24
                );
            }

            _center(nut_lock_dimensions, nut_lock_z) {
                cube(nut_lock_dimensions);
            }

            _center(bridge_dimensions, bridge_z) {
                mirror([0, 0, 1]) {
                    flat_top_rectangular_pyramid(
                        top_width = access_on_y
                            ? bridge_dimensions.x - layer_height * 2
                            : hole_diameter,
                        top_length = access_on_y
                            ? hole_diameter
                            : bridge_dimensions.y - layer_height * 2,

                        bottom_width = bridge_dimensions.x,
                        bottom_length = bridge_dimensions.y,

                        height = layer_height + e
                    );
                }
            }
        }
    }
}

* rotate([0, 0, $t >= .5 ? 90 : 0]) pcb_mount_post(
    width = NUT_DIAMETER + ($t >= .5 ? 4 : 0),
    length = NUT_DIAMETER + ($t >= .5 ? 0 : 4),
    quick_preview = false
);
