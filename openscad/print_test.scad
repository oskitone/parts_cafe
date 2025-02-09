include <../../parts_cafe/openscad/diagonal_grill.scad>;
include <../../parts_cafe/openscad/enclosure_engraving.scad>;
include <../../parts_cafe/openscad/enclosure.scad>;

module print_test(
    dimensions = [
        25.4 * 2,
        25.4 * 1.5,
        ENCLOSURE_FLOOR_CEILING
    ],
    depth = ENCLOSURE_ENGRAVING_DEPTH,

    outer_gutter = 5,
    label_gutter = 1,
    inner_gutter = 3.4,

    // NOTE: eyeballed against width
    label_text_size = 4.35,
    label_text = "REDUCED",

    placard_length = ENCLOSURE_ENGRAVING_LENGTH,
    placard_text_size = ENCLOSURE_ENGRAVING_TEXT_SIZE,
    placard_text = "PRINT TEST",

    quick_preview = true,

    color = "#fff",
    cavity_color = "#ccc"
) {
    e = 1.0151;

    available_length = dimensions.y - outer_gutter * 2;
    sidebar_width = available_length * OSKITONE_LENGTH_WIDTH_RATIO;
    available_width = dimensions.x - outer_gutter * 2
        - sidebar_width - inner_gutter;

    label_length = label_text_size;
    grill_length = available_length
        - label_length - placard_length
        - inner_gutter - label_gutter;

    module _text_engraving() {
        enclosure_engraving(
            size = sidebar_width,
            position = [
                outer_gutter + sidebar_width,
                outer_gutter
            ],
            center = false,
            rotation = 90,
            quick_preview = quick_preview,
            enclosure_height = dimensions.z
        );

        enclosure_engraving(
            string = label_text,
            size = label_text_size,
            position = [
                outer_gutter + sidebar_width + inner_gutter
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
                outer_gutter + sidebar_width + inner_gutter
                    + available_width / 2,
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
                outer_gutter + sidebar_width + inner_gutter,
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

* print_test(quick_preview = $preview);
