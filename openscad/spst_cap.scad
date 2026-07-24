include <cap_blank.scad>;
include <enclosure_engraving.scad>;
include <rounded_xy_cube.scad>;
include <spst.scad>;

STOCK_SPST_CAP_DIMENSIONS = [18, 18, 10];

module spst_cap(
    dimensions = STOCK_SPST_CAP_DIMENSIONS,

    exposed_height = 5,

    contact_width = 14,
    contact_length = 14,

    fillet = 1,

    cavity_clearance = .4,

    base_fit_tolerance = 0, // 0 to .1 seems good!
    actuator_fit_tolerance = 0, // 0 to .1 seems good!

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

    dfm_cavity_height = .3,
    show_dfm = true,

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
        ? spst_base_dimensions.z - spst_travel
        : 0;

    module _spst(
        z = 0,
        base_bleed = [0, 0, 0],
        actuator_bleed = 0,
        show_base = true,
        show_actuator = true,
        position = 0
    ) {
        translate([
            dimensions.x / 2,
            dimensions.y / 2,
            z
        ]) {
            spst(
                base_dimensions = [
                    spst_base_dimensions.x + base_bleed.x * 2,
                    spst_base_dimensions.y + base_bleed.y * 2,
                    spst_base_dimensions.z + base_bleed.z
                ],
                actuator_diameter = spst_actuator_diameter
                    + actuator_bleed * 2,
                actuator_height_including_base = spst_actuator_height_including_base,
                travel = spst_travel,
                position = position,
                show_base = show_base,
                show_actuator = show_actuator
            );
        }
    }

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

        hull() {
            cap_blank(
                dimensions = dimensions,
                contact_dimensions = [contact_width, contact_length, exposed_height],
                fillet = fillet,
                brim_dimensions = brim_dimensions
            );

            if (bottom_height_extension > 0) {
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
        dfm_cavity_dimensions = [
            spst_base_dimensions.x
                + (cavity_clearance + base_fit_tolerance) * 2,
            spst_actuator_diameter + actuator_fit_tolerance * 2,
            dfm_cavity_height + e
        ];

        _spst(
            z = -spst_base_dimensions.z + spst_travel - e,
            base_bleed = [
                cavity_clearance + base_fit_tolerance,
                cavity_clearance + base_fit_tolerance,
                e
            ],
            show_actuator = false
        );

        _spst(
            z = -spst_base_dimensions.z,
            actuator_bleed = actuator_fit_tolerance,
            show_base = false,
            $fn = 12
        );

        if (show_dfm) {
            translate([
                (dimensions.x - dfm_cavity_dimensions.x) / 2,
                (dimensions.y - dfm_cavity_dimensions.y) / 2,
                spst_travel - e
            ]) {
                cube(dfm_cavity_dimensions);
            }
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
        % _spst(
            -spst_base_dimensions.z,
            position = spst_position
        );
    }
}

// module __tolerance_goldilocks_spst_cap(
//     tolerances = [-.1, 0, .1, .2, .3],

//     dimensions = [20, 20, 5],
//     exposed_height = 5,
//     overlap = 2,
//     fillet = 1
// ) {
//     for (i = [0 : len(tolerances) - 1]) {
//         translate([(dimensions.x - overlap) * i, 0, 0]) {
//             difference() {
//                 spst_cap(
//                     dimensions = dimensions,
//                     contact_width = dimensions.x,
//                     contact_length = dimensions.y - fillet * 2,
//                     exposed_height = exposed_height,
//                     fillet = fillet,
//                     base_fit_tolerance = tolerances[i],
//                     actuator_fit_tolerance = tolerances[i],
//                     engraving = str(tolerances[i] * 10),
//                     engraving_size = 10
//                 );
//             }
//         }
//     }
// }

// __tolerance_goldilocks_spst_cap();