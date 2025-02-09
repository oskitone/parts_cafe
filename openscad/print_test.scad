include <../../parts_cafe/openscad/diagonal_grill.scad>;
include <../../parts_cafe/openscad/enclosure_engraving.scad>;
include <../../parts_cafe/openscad/enclosure.scad>;

module print_test(
    dimensions = [
        25.4 * 3,
        25.4 * 2.5,
        ENCLOSURE_FLOOR_CEILING
    ],
    depth = ENCLOSURE_ENGRAVING_DEPTH,

    outer_gutter = 5,
    label_gutter = 2,
    inner_gutter = 3.4,

    // NOTE: eyeballed against width
    label_text_size = 7.2,
    label_text = "PRINT TEST",

    placard_length = ENCLOSURE_ENGRAVING_LENGTH * 1.5,
    placard_text_size = ENCLOSURE_ENGRAVING_TEXT_SIZE,
    placard_text = "ABCDEFGHI 123 !@#$%&",

    quick_preview = true,

    color = "#fff",
    cavity_color = "#ccc"
) {
    e = 1.0151;

    available_width = dimensions.x - outer_gutter * 2;
    available_length = dimensions.y - outer_gutter * 2;

    oskitone_length = available_width * OSKITONE_LENGTH_WIDTH_RATIO;
    label_length = label_text_size;
    grill_length = available_length
        - oskitone_length - label_length - placard_length
        - inner_gutter - label_gutter * 2;

    module _text_engraving() {
        enclosure_engraving(
            size = oskitone_length,
            position = [
                outer_gutter,
                dimensions.y  - outer_gutter - oskitone_length
            ],
            center = false,
            quick_preview = quick_preview,
            enclosure_height = dimensions.z
        );

        enclosure_engraving(
            string = label_text,
            size = label_text_size,
            position = [
                dimensions.x / 2,
                dimensions.y  - outer_gutter - oskitone_length
                    - label_gutter - label_length / 2
            ],
            center = true,
            quick_preview = quick_preview,
            enclosure_height = dimensions.z
        );

        enclosure_engraving(
            string = placard_text,
            size = placard_text_size,
            position = [
                outer_gutter + available_width / 2,
                outer_gutter + grill_length
                    + inner_gutter + placard_length / 2
            ],
            placard = [available_width, placard_length],
            center = true,
            quick_preview = quick_preview,
            enclosure_height = dimensions.z
        );
    }

    difference() {
        color(color) {
            cube(dimensions);
        }

        color(cavity_color) {
            translate([
                outer_gutter,
                outer_gutter,
                dimensions.z - depth
            ]) {
                diagonal_grill(
                    available_width,
                    grill_length,
                    depth + e
                );
            }

            _text_engraving();
        }
    }
}