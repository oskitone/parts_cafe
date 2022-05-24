module supportless_screw_cavity(
    height = undef,
    span = 10,
    angle = 0,
    diameter = 3.2, // PCB_MOUNT_HOLE_DIAMETER
    $fn = 24,

    // Conservatively larger than needed to ensure layers aren't skipped
    bridge_height = .2 * 1.5 // SACRIFICIAL_BRIDGE_HEIGHT
) {
    e = .0321;

    if (height != undef) {
        cylinder(
            d = diameter,
            h = height
        );
    }

    rotate([0, 0, angle]) {
        translate([span / -2, diameter / -2, 0]) {
            cube([span, diameter, bridge_height + e]);
        }

        translate([diameter / -2, diameter / -2, bridge_height]) {
            cube([diameter, diameter, bridge_height]);
        }
    }
}
