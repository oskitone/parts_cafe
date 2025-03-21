include <enclosure_engraving.scad>;
include <lightpipe.scad>;
include <nuts_and_bolts.scad>;
include <rounded_cube.scad>;

// TODO/try:
// * a big metal washer vs knife
// * size test foxhole

module lightpipe_jig(
    lightpipe_length = LIGHTPIPE_LENGTH,
    lightpipe_length_string = LIGHTPIPE_LENGTH_STRING,
    lightpipe_diameter = LIGHTPIPE_DIAMETER,

    dimensions = [
        MINI_HOT_GLUE_STICK_LENGTH / 4 + 4,
        15,
        15
    ],

    material_length = MINI_HOT_GLUE_STICK_LENGTH / 4,

    pushout_diameter = SCREW_DIAMETER,

    blade_width = .6,
    blade_top_registration = 2,
    blade_well = 1,

    tolerance = 0
) {
    e = .014;

    endstop = dimensions.x - material_length;
    cavity_diameter = lightpipe_diameter + tolerance * 2;

    material_position = [
        endstop - tolerance,
        dimensions.y / 2,
        dimensions.z - lightpipe_diameter / 2
            - blade_top_registration
    ];

    module _blade_cavities() {
        blade_cavity_width = blade_width + tolerance * 2;

         for (x = [
            lightpipe_length
            : lightpipe_length
            : material_length - lightpipe_length
        ]) {
            translate([
                material_position.x + x - blade_cavity_width / 2,
                -e,
                material_position.z - cavity_diameter / 2
                    - blade_well
            ]) {
                cube([
                    blade_cavity_width,
                    dimensions.y + e * 2,
                    dimensions.z
                ]);
            }
        }
    }

    module _material_cavity() {
        cavity_length = dimensions.x - endstop + tolerance + e * 2;

        translate(material_position) {
            rotate([0, 90, 0]) {
                cylinder(
                    d = cavity_diameter,
                    h = cavity_length
                );
            }
        }

        translate([
            material_position.x,
            material_position.y - cavity_diameter / 2,
            material_position.z
        ]) {
            cube([
                dimensions.x - material_position.x + e,
                cavity_diameter,
                dimensions.z - material_position.z + e
            ]);
        }
    }

    module _pushout_cavity() {
        diameter = pushout_diameter + tolerance * 2;

        translate([
            -e,
            material_position.y,
            material_position.z
        ]) {
            rotate([0, 90, 0]) {
                cylinder(
                    d = diameter,
                    h = endstop + e * 2
                );
            }

            translate([0, diameter / -2, 0]) {
                cube([
                    endstop + e * 2,
                    diameter,
                    dimensions.z
                ]);
            }
        }
    }

    module _label() {
        enclosure_engraving(
            lightpipe_length_string,
            position = [dimensions.x / 2, dimensions.y / 2],
            bottom = true,
            quick_preview = $preview
        );
    }

    difference() {
        rounded_cube(dimensions, radius = 1, $fn = 12);

        _material_cavity();
        _blade_cavities();
        _pushout_cavity();
        _label();
    }

    % translate(material_position) {
        for (x = [
            0 :
            lightpipe_length :
            material_length - lightpipe_length
        ]) {
            translate([x, 0, 0]) {
                rotate([0, 90, 0]) {
                    cylinder(
                        d = lightpipe_diameter,
                        h = lightpipe_length
                    );
                }
            }
        }
    }
}

lightpipe_jig(tolerance = .1, $fn = 24);