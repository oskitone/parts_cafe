include <cap_blank.scad>;
include <enclosure_engraving.scad>;
include <rounded_xy_cube.scad>;
include <spst.scad>;

STOCK_SPST_CAP_DIMENSIONS = [18, 18, 10];
SPST_CAP_Z_CLEARANCE = .2 +
    (SPST_ACTUATOR_GENEROUS_HEIGHT_OFF_PCB - SPST_ACTUATOR_HEIGHT_OFF_PCB);

module spst_cap(
    dimensions = STOCK_SPST_CAP_DIMENSIONS,

    exposed_height = 5,

    contact_width = 14,
    contact_length = 14,

    fillet = 1,

    xy_clearance = .2,
    z_clearance = SPST_CAP_Z_CLEARANCE,

    spst_base_dimensions = SPST_BASE_DIMENSIONS,
    spst_actuator_diameter = SPST_ACTUATOR_DIAMETER,
    spst_actuator_height_including_base = SPST_ACTUATOR_HEIGHT_OFF_PCB,
    spst_travel = SPST_CONSERVATIVE_TRAVEL,
    spst_position = 0,

    brim_dimensions = [0,0,0],
    extend_towards_pcb = true,

    engraving = undef,
    engraving_size = ENCLOSURE_ENGRAVING_TEXT_SIZE,

    outer_color = undef,
    cavity_color = undef,

    tolerance = 0,

    quick_preview = true,

    debug = false
) {
    e = .0418;

    brim_dimensions = [
        max(brim_dimensions.x, dimensions.x),
        max(brim_dimensions.y, dimensions.y),
        brim_dimensions.z,
    ];

    bottom_height_extension = extend_towards_pcb
        ? spst_base_dimensions.z - spst_travel - z_clearance
        : 0;

    module _outer_hull() {
        extension_position = brim_dimensions.z > 0
            ? [
                (brim_dimensions.x - dimensions.x) / -2
                    + bottom_height_extension,
                (brim_dimensions.y - dimensions.y) / -2
                    + bottom_height_extension,
                -bottom_height_extension
            ]
            : [
                bottom_height_extension,
                bottom_height_extension,
                -bottom_height_extension
            ];

        cap_blank(
            dimensions = dimensions,
            contact_dimensions = [contact_width, contact_length, exposed_height],
            fillet = fillet,
            brim_dimensions = brim_dimensions
        );

        if (bottom_height_extension > 0) {
            hull() {
                translate([
                    (brim_dimensions.x - dimensions.x) / -2,
                    (brim_dimensions.y - dimensions.y) / -2,
                    0
                ]) {
                    rounded_xy_cube([
                        brim_dimensions.x,
                        brim_dimensions.y,
                        e
                    ], brim_dimensions.z > 0 ? 0 : fillet);
                }

                translate(extension_position) {
                    rounded_xy_cube([
                        max(dimensions.x, brim_dimensions.x)
                            - bottom_height_extension * 2,
                        max(dimensions.y, brim_dimensions.y)
                            - bottom_height_extension * 2,
                        e
                    ], fillet);
                }
            }
        }
    }

    module _cavity() {
        cavity_dimensions = [
            spst_base_dimensions.x
                + (xy_clearance + tolerance) * 2,
            spst_base_dimensions.y
                + (xy_clearance + tolerance) * 2,
            spst_actuator_height_including_base - spst_travel + e
        ];

        translate([
            (dimensions.x - cavity_dimensions.x) / 2,
            (dimensions.y - cavity_dimensions.y) / 2,
            -(spst_base_dimensions.z - spst_travel) - e
        ]) {
            cube(cavity_dimensions);
        }
    }

    translate([0, 0, spst_position * -spst_travel]) {
        difference() {
            color(outer_color) {
                _outer_hull();
            }

            color(cavity_color) {
                if (engraving) {
                    enclosure_engraving(
                        engraving,
                        size = engraving_size,
                        position = [dimensions.x / 2, dimensions.y / 2],
                        bottom = false,
                        quick_preview = quick_preview,
                        enclosure_height = dimensions.z
                    );
                }

                _cavity();

                if (debug) {
                    cutoff_dimensions = [
                        max(dimensions.x, brim_dimensions.x),
                        max(dimensions.y, brim_dimensions.y),
                        dimensions.z + bottom_height_extension
                            + 100 // haha
                    ];

                    translate([
                        dimensions.x / 2,
                        (cutoff_dimensions.y - dimensions.y) / -2 - e,
                        -(bottom_height_extension + e)
                    ]) {
                        cube([
                            cutoff_dimensions.x / 2 + e,
                            cutoff_dimensions.y + e * 2,
                            cutoff_dimensions.z + e * 2
                        ]);
                    }
                }
            }
        }
    }

    if (debug) {
        translate([
            dimensions.x / 2,
            dimensions.y / 2,
            -spst_base_dimensions.z
        ]) {
            % spst(
                base_dimensions = spst_base_dimensions,
                actuator_diameter = spst_actuator_diameter,
                actuator_height_including_base = spst_actuator_height_including_base,
                travel = spst_travel,
                position = spst_position
            );
        }
    }
}

// module __clearance_goldilocks_spst_cap(
//     clearances = [0, .2, .4, .6],

//     dimensions = [20, 20, 5],
//     exposed_height = 4,
//     overlap = 2,
//     fillet = 1
// ) {
//     for (i = [0 : len(clearances) - 1]) {
//         translate([(dimensions.x - overlap) * i, 0, 0]) {
//             difference() {
//                 spst_cap(
//                     dimensions = dimensions,
//                     contact_width = dimensions.x,
//                     contact_length = dimensions.y - fillet * 2,
//                     exposed_height = exposed_height,
//                     fillet = fillet,
//                     xy_clearance = clearances[i],
//                     engraving = str(clearances[i] * 10),
//                     engraving_size = 10,
//                     spst_position = 0
//                 );
//             }
//         }
//     }
// }

// __clearance_goldilocks_spst_cap();

// * translate([0, 25, 0]) spst_cap(
//     debug = 1,
//     tolerance = .1,
//     brim_dimensions = [
//         STOCK_SPST_CAP_DIMENSIONS.x + 4,
//         STOCK_SPST_CAP_DIMENSIONS.y + 4,
//         2
//     ],
//     spst_position = 0
// );