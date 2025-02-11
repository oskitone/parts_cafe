include <diagonal_grill.scad>;
include <enclosure_engraving.scad>;
include <enclosure.scad>;
include <rounded_xy_cube.scad>;

module print_test(
    dimensions = [
        25.4 * 2,
        25.4 * 1,
        ENCLOSURE_FLOOR_CEILING
    ],
    depth = ENCLOSURE_ENGRAVING_DEPTH,
    radius = ENCLOSURE_FILLET,

    outer_gutter = 4,
    inner_gutter = 2,

    hole_diameter = 4,

    // NOTE: eyeballed against width
    label_text_size = 6.4,
    label_text = "ABCD",

    placard_text_size = ENCLOSURE_ENGRAVING_TEXT_SIZE,
    placard_text = "1 2 3 4 5",

    quick_preview = true,

    color = "#fff",
    cavity_color = "#ccc"
) {
    e = 1.0151;

    available_length = dimensions.y - outer_gutter * 2;
    grill_width = (dimensions.x - outer_gutter * 2 - inner_gutter * 2)
        / 3;
    available_width = dimensions.x - outer_gutter * 2
        - grill_width - inner_gutter;

    label_length = label_text_size;

    placard_length = available_length - label_length - inner_gutter;

    hole_position = [
        outer_gutter + hole_diameter / 2,
        dimensions.y - outer_gutter - hole_diameter / 2,
        -e
    ];

    module _base() {
        rounded_xy_cube(
            dimensions,
            radius = radius,
            $fn = 12
        );
    }

    module _hole() {
        translate(hole_position) {
            cylinder(
                h = dimensions.z + e * 2,
                d = hole_diameter,
                $fn = 12
            );
        }
    }

    module _grill() {
        difference() {
            translate([
                outer_gutter,
                outer_gutter,
                dimensions.z - depth
            ]) {
                diagonal_grill(
                    grill_width,
                    available_length,
                    depth + e
                );
            }

            translate(hole_position) {
                cylinder(
                    h = dimensions.z + e * 2,
                    d = hole_diameter + inner_gutter * 2,
                    $fn = 12
                );
            }
        }
    }

    module _text_engraving() {
        enclosure_engraving(
            string = label_text,
            size = label_text_size,
            position = [
                outer_gutter + grill_width + inner_gutter
                    + available_width / 2,
                dimensions.y  - outer_gutter - label_length / 2
            ],
            center = true,
            quick_preview = quick_preview,
            enclosure_height = dimensions.z
        );

        enclosure_engraving(
            string = placard_text,
            size = placard_text_size,
            position = [
                outer_gutter + grill_width + inner_gutter
                    + available_width / 2,
                outer_gutter + placard_length / 2
            ],
            placard = [available_width, placard_length],
            center = true,
            quick_preview = quick_preview,
            enclosure_height = dimensions.z
        );
    }

    difference() {
        color(color) {
            _base();
        }

        color(cavity_color) {
            _grill();
            _text_engraving();
            _hole();
        }
    }
}

* print_test(quick_preview = $preview);
