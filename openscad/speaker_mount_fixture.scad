include <enclosure.scad>;
include <nuts_and_bolts.scad>;
include <nuts_and_bolts.scad>;
include <pcb_mount_post.scad>;

SPEAKER_MOUNT_FIXTURE_DEFAULT_DIMENSIONS = [
    41 + ENCLOSURE_INNER_WALL * 2,
    71 + ENCLOSURE_INNER_WALL * 2,
    NUT_HEIGHT + PCB_MOUNT_POST_CEILING
];

module speaker_mount_fixture(
    dimensions = SPEAKER_MOUNT_FIXTURE_DEFAULT_DIMENSIONS,
    height = undef, // if specified, replaces dimensions.z
    nut_z = PCB_MOUNT_POST_CEILING,
    nut_z_clearance = PCB_MOUNT_NUT_Z_CLEARANCE,
    hole_diameter = SCREW_DIAMETER,

    speaker_diameter = SPEAKER_DIAMETER,
	speaker_length = SPEAKER_LENGTH,
	speaker_plate_hole_positions = SPEAKER_PLATE_HOLE_POSITIONS,
	speaker_plate_hole_xy = SPEAKER_PLATE_HOLE_XY,
	speaker_rim_depth = SPEAKER_RIM_DEPTH,
	speaker_rim_height = SPEAKER_RIM_HEIGHT,

    include_sacrificial_bridge = true,
    bridge_height = .3,

    tolerance = 0,

    debug = false
) {
    nut_z_clearance = include_sacrificial_bridge
        ? nut_z_clearance + bridge_height
        : nut_z_clearance;
    screw_cavity_diameter = hole_diameter + tolerance * 2;

    e = .0234;

    nut_z = nut_z - nut_z_clearance;

    dimensions = [
        dimensions.x,
        dimensions.y,
        height != undef ? height : dimensions.z
    ];

    nut_lock_dimensions = [
        NUT_DIAMETER + speaker_diameter * 2, // arbitrarily big
        NUT_DIAMETER + tolerance * 2,
        NUT_HEIGHT + nut_z_clearance + e
    ];

    bridge_depth = max(
        (dimensions.x - speaker_diameter) / 2,
        (dimensions.y - speaker_length) / 2
    ) + speaker_plate_hole_xy - screw_cavity_diameter / 2;

    difference() {
        translate([dimensions.x / -2, dimensions.y / -2, 0]) {
            cube(dimensions);
        }

        _speaker_face(
            diameter = speaker_diameter + tolerance * 2,
            height = speaker_rim_height + e,
            z = -e
        );

        translate([0, 0, -e]) {
            _speaker_face(
                diameter = speaker_diameter - speaker_rim_depth,
                height = dimensions.z + e * 2
            );
        }

        intersection() {
            for (i = [0 : len(speaker_plate_hole_positions) - 1]) {
                xy = speaker_plate_hole_positions[i];

                translate([
                    xy.x - speaker_diameter / 2,
                    xy.y - speaker_length / 2,
                    0
                ]) {
                    difference() {
                        translate([0, 0, -e]) {
                            cylinder(
                                d = screw_cavity_diameter,
                                h = dimensions.z + e * 2,
                                $fn = 12
                            );
                        }

                        if (include_sacrificial_bridge) {
                            translate([0, 0, nut_z - bridge_height + e]) {
                                cylinder(
                                    d = screw_cavity_diameter + e * 2,
                                    h = bridge_height + e,
                                    $fn = 12
                                );
                            }
                        }
                    }

                    rotate([0, 0, (i == 0 || i == 3) ? -45 : 45]) {
                        if (debug) {
                            z = nut_z + (include_sacrificial_bridge ? bridge_height : 0);

                            translate([0, 0, z]) {
                                % nut();
                            }
                        }

                        translate([
                            nut_lock_dimensions.x / -2,
                            nut_lock_dimensions.y / -2,
                            nut_z
                        ]) {
                            cube(nut_lock_dimensions);
                        }
                    }
                }
            }

            if (include_sacrificial_bridge) {
                union() {
                    translate([
                        dimensions.x / -2 - e,
                        dimensions.y / -2 - e,
                        nut_z + bridge_height
                    ]) {
                        cube([
                            dimensions.x + e * 2,
                            dimensions.y + e * 2,
                            dimensions.z + e * 2
                        ]);
                    }

                    translate([
                        bridge_depth - dimensions.x / 2,
                        bridge_depth - dimensions.y / 2,
                        -e
                    ]) {
                        cube([
                            dimensions.x - bridge_depth * 2,
                            dimensions.y - bridge_depth * 2,
                            dimensions.z + e * 2
                        ]);
                    }
                }
            }
        }
    }
}

// include <speaker-sc700208.scad>;
// translate([
//     SPEAKER_MOUNT_FIXTURE_DEFAULT_DIMENSIONS.x / 2,
//     SPEAKER_MOUNT_FIXTURE_DEFAULT_DIMENSIONS.y / 2
// ]) {
//     speaker_mount_fixture(
//         dimensions = [50, 100, 20], nut_z = 20 - NUT_HEIGHT,
//         include_sacrificial_bridge = round($t),
//         debug = true,
//         tolerance = .1
//     );
//     % translate([0,0,-SPEAKER_HEIGHT + SPEAKER_RIM_HEIGHT]) speaker();
// }