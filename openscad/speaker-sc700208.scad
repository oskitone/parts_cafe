include <nuts_and_bolts.scad>;
include <pcb_mount_post.scad>;
include <rounded_xy_cube.scad>;

SPEAKER_DIAMETER = 41.1;
SPEAKER_HEIGHT = 25;
SPEAKER_LENGTH = 71;
SPEAKER_PLATE_HOLE_DIAMETER = 3.6;
SPEAKER_PLATE_HOLE_XY = 4;
SPEAKER_PLATE_HEIGHT = .8;
SPEAKER_RIM_DEPTH = 3.8;
SPEAKER_RIM_HEIGHT = 1.4;
SPEAKER_CONE_DIAMETER = 38;
SPEAKER_MAGNET_DIAMETER = 22;
SPEAKER_MAGNET_HEIGHT = 7.5;

SPEAKER_PLATE_HOLE_POSITIONS = [
    [SPEAKER_PLATE_HOLE_XY, SPEAKER_PLATE_HOLE_XY],
    [SPEAKER_DIAMETER - SPEAKER_PLATE_HOLE_XY, SPEAKER_PLATE_HOLE_XY],
    [SPEAKER_PLATE_HOLE_XY, SPEAKER_LENGTH - SPEAKER_PLATE_HOLE_XY],
    [SPEAKER_DIAMETER - SPEAKER_PLATE_HOLE_XY, SPEAKER_LENGTH - SPEAKER_PLATE_HOLE_XY],
];

module _speaker_face(
    diameter = SPEAKER_DIAMETER,
    d1, d2,
    height,
    z = 0
) {
    d1 = d1 != undef ? d1 : diameter;
    d2 = d2 != undef ? d2 : diameter;

    hull() {
        for (y = [
            SPEAKER_LENGTH / 2 - SPEAKER_DIAMETER / 2,
            SPEAKER_LENGTH / -2 + SPEAKER_DIAMETER / 2,
        ]) {
            translate([0, y, z]) {
                cylinder(d1 = d1, d2 = d2, h = height);
            }
        }
    }
}

module speaker_inner_rim_cavity(height = SPEAKER_RIM_HEIGHT) {
    _speaker_face(
        diameter = SPEAKER_DIAMETER - SPEAKER_RIM_DEPTH,
        height = height
    );
}

module speaker_plate_screw_cavities(
    height = SPEAKER_PLATE_HEIGHT,
    diameter = SPEAKER_PLATE_HOLE_DIAMETER,
    z = 0
) {
    for (xy = SPEAKER_PLATE_HOLE_POSITIONS) {
        translate([xy.x, xy.y, z]) {
            cylinder(
                d = diameter,
                h = height
            );
        }
    }
}

module speaker() {
    e = .01;

    module _rim() {
        z = SPEAKER_HEIGHT - SPEAKER_RIM_HEIGHT;

        translate([0, 0, -e]) difference() {
            _speaker_face(
                height = SPEAKER_RIM_HEIGHT,
                z = z
            );

            translate([0, 0, z - e]) {
                speaker_inner_rim_cavity(height = SPEAKER_RIM_HEIGHT + e * 2);
            }
        }
    }

    module _plate() {
        translate([
            SPEAKER_DIAMETER / -2,
            SPEAKER_LENGTH / -2,
            SPEAKER_HEIGHT - SPEAKER_RIM_HEIGHT - SPEAKER_PLATE_HEIGHT
        ]) {
            difference() {
                cube([SPEAKER_DIAMETER, SPEAKER_LENGTH, SPEAKER_PLATE_HEIGHT]);
                speaker_plate_screw_cavities(
                    height = SPEAKER_PLATE_HEIGHT + e * 2,
                    z = -e
                );
            }
        }
    }

    module _cone() {
        hull() {
            _speaker_face(
                d1 = SPEAKER_CONE_DIAMETER,
                d2 = SPEAKER_DIAMETER,
                height = e,
                z = SPEAKER_HEIGHT - SPEAKER_RIM_HEIGHT - SPEAKER_PLATE_HEIGHT
            );

            translate([0, 0, SPEAKER_MAGNET_HEIGHT]) {
                cylinder(d = SPEAKER_CONE_DIAMETER, h = e);
            }
        }
    }

    module _magnet() {
        cylinder(
            d = SPEAKER_MAGNET_DIAMETER,
            h = SPEAKER_MAGNET_HEIGHT
        );
    }

    _rim();
    % _plate();
    _cone();
    _magnet();
}

module speaker_mount_fixture(
    dimensions = [
        SPEAKER_DIAMETER,
        SPEAKER_LENGTH,
        NUT_HEIGHT + PCB_MOUNT_POST_CEILING
    ],
    height = undef, // if specified, replaces dimensions.z
    nut_z = PCB_MOUNT_POST_CEILING,
    nut_z_clearance = PCB_MOUNT_NUT_Z_CLEARANCE,
    hole_diameter = SCREW_DIAMETER,

    include_sacrificial_bridge = true,
    bridge_height = .3,

    tolerance = 0,

    debug = false
) {
    screw_cavity_diameter = hole_diameter + tolerance * 2;

    e = .0234;

    nut_z = nut_z - nut_z_clearance;

    dimensions = [
        dimensions.x,
        dimensions.y,
        height != undef ? height : dimensions.z
    ];

    nut_lock_dimensions = [
        NUT_DIAMETER + SPEAKER_DIAMETER / 2,
        NUT_DIAMETER + tolerance * 2,
        NUT_HEIGHT + nut_z_clearance + e
    ];

    difference() {
        translate([dimensions.x / -2, dimensions.y / -2, 0]) {
            rounded_xy_cube(
                dimensions,
                radius = SPEAKER_PLATE_HOLE_XY,
                $fn = 4
            );
        }

        _speaker_face(
            diameter = SPEAKER_DIAMETER + tolerance * 2,
            height = SPEAKER_RIM_HEIGHT + e,
            z = -e
        );

        translate([0, 0, -e]) {
            _speaker_face(
                diameter = SPEAKER_DIAMETER - SPEAKER_RIM_DEPTH,
                height = dimensions.z + e * 2
            );
        }

        for (i = [0 : len(SPEAKER_PLATE_HOLE_POSITIONS) - 1]) {
            xy = SPEAKER_PLATE_HOLE_POSITIONS[i];

            translate([
                xy.x - SPEAKER_DIAMETER / 2,
                xy.y - SPEAKER_LENGTH / 2,
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
                        rotate([0, 0, (i == 0 || i == 3) ? 45 : -45]) {
                            translate([
                                screw_cavity_diameter / -2,
                                nut_lock_dimensions.y / -2,
                                nut_z - bridge_height + e
                            ]) {
                                cube([
                                    screw_cavity_diameter,
                                    nut_lock_dimensions.y,
                                    bridge_height + e
                                ]);
                            }
                        }
                    }
                }

                rotate([0, 0, (i == 0 || i == 3) ? 45 : -45]) {
                    if (debug) {
                        translate([0, 0, nut_z]) {
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
    }
}

// speaker_mount_fixture(
//     dimensions = [50, 100, 20], nut_z = 20 - NUT_HEIGHT,
//     include_sacrificial_bridge = true,
//     debug = true,
//     tolerance = .1
// );
// translate([0,0,-SPEAKER_HEIGHT + SPEAKER_RIM_HEIGHT]) speaker();