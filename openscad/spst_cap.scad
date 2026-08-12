include <cap_blank.scad>;
include <enclosure_engraving.scad>;
include <rounded_xy_cube.scad>;
include <spst.scad>;

STOCK_SPST_CAP_DIMENSIONS = [12, 12, 16];
SPST_CAP_MIN_PCB_CONTACT_DIMENSIONS = [
    SPST_BASE_DIMENSIONS.x + 4,
    SPST_BASE_DIMENSIONS.y + 4
];

SPST_CAP_Z_FROM_PCB = .2 + SPST_MAX_TRAVEL
    + (SPST_ACTUATOR_GENEROUS_HEIGHT_OFF_PCB - SPST_ACTUATOR_HEIGHT_OFF_PCB);

module spst_cap(
    dimensions = STOCK_SPST_CAP_DIMENSIONS,
    contact_dimensions = [10, 10, 2],
    brim_dimensions = [14, 14, 1],
    stilt_dimensions = [
        SPST_CAP_MIN_PCB_CONTACT_DIMENSIONS.x,
        SPST_CAP_MIN_PCB_CONTACT_DIMENSIONS.y,
        0
    ],

    fillet = 1,

    xy_clearance = .2,
    z_clearance = SPST_CAP_Z_FROM_PCB,

    spst_base_dimensions = SPST_BASE_DIMENSIONS,
    spst_actuator_diameter = SPST_ACTUATOR_DIAMETER,
    spst_actuator_height_including_base = SPST_ACTUATOR_HEIGHT_OFF_PCB,
    spst_travel = SPST_MAX_TRAVEL,
    spst_position = 0,

    engraving = undef,
    engraving_size = ENCLOSURE_ENGRAVING_TEXT_SIZE,

    outer_color = undef,
    cavity_color = undef,

    tolerance = 0,

    quick_preview = true,

    debug = false
) {
    e = .0418;

    module _cavity() {
        cavity_dimensions = [
            spst_base_dimensions.x
                + (xy_clearance + tolerance) * 2,
            spst_base_dimensions.y
                + (xy_clearance + tolerance) * 2,
            spst_actuator_height_including_base - z_clearance + e
        ];

        translate([
            (dimensions.x - cavity_dimensions.x) / 2,
            (dimensions.y - cavity_dimensions.y) / 2,
            -e
        ]) {
            cube(cavity_dimensions);
        }
    }

    translate([0, 0, spst_position * -spst_travel]) {
        difference() {
            color(outer_color) {
                cap_blank(
                    dimensions = dimensions,
                    contact_dimensions = contact_dimensions,
                    brim_dimensions = brim_dimensions,
                    stilt_dimensions = stilt_dimensions,
                    fillet = fillet
                );
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
                        max(dimensions.x, brim_dimensions.x) / 2 + e,
                        max(dimensions.y, brim_dimensions.y) + e * 2,
                        dimensions.z + e
                    ];

                    translate([
                        dimensions.x / 2,
                        (cutoff_dimensions.y - dimensions.y) / -2 - e,
                        -e
                    ]) {
                        cube(cutoff_dimensions);
                    }
                }
            }
        }
    }

    if (debug) {
        translate([
            dimensions.x / 2,
            dimensions.y / 2,
            -z_clearance
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

// translate([0, 25, SPST_CAP_Z_FROM_PCB]) spst_cap(
//     debug = 1,
//     tolerance = .1,
//     spst_position = round($t)
// );