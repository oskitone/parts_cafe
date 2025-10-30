include <engraving.scad>;
include <flat_top_rectangular_pyramid.scad>;

ENCLOSURE_ENGRAVING_DEPTH = 1.2;
OSKITONE_LENGTH_WIDTH_RATIO = 4.6 / 28;
SIDE_ENGRAVING_DEFAULT_WIDTH = 15;

ENCLOSURE_ENGRAVING_TEXT_SIZE = 3.2;
ENCLOSURE_ENGRAVING_LENGTH = 5;
ENCLOSURE_ENGRAVING_GUTTER = (
    ENCLOSURE_ENGRAVING_LENGTH
    - ENCLOSURE_ENGRAVING_TEXT_SIZE
) / 2;

ENCLOSURE_ENGRAVING_BLEED = -.1;
ENCLOSURE_ENGRAVING_CHAMFER = .4;

BRANDING_SVG = "../../parts_cafe/images/branding.svg";

function get_branding_model_length(
    gutter = 0,
    make_to_model_ratio = .5,
    available_length = 10
) = (
    (available_length - gutter) * (1 - make_to_model_ratio)
);
function get_branding_make_width(
    gutter = 0,
    make_to_model_ratio = .5,
    available_length = 10
) = (
    get_branding_make_length(gutter, make_to_model_ratio, available_length)
    / OSKITONE_LENGTH_WIDTH_RATIO
);
function get_branding_make_length(
    gutter = 0,
    make_to_model_ratio = .5,
    available_length = 10
) = (
    (available_length - gutter) * make_to_model_ratio
);

module enclosure_engraving_placard(
    dimensions = [0,0],
    depth = ENCLOSURE_ENGRAVING_DEPTH,
    chamfer_top = false,
    chamfer = ENCLOSURE_ENGRAVING_CHAMFER
) {
    e = .0678;

    module _section(top_dimensions = dimensions, _depth = depth) {
        flat_top_rectangular_pyramid(
            top_width = top_dimensions.x,
            top_length = chamfer_top
                ? top_dimensions.y + dimensions.z / 2
                : top_dimensions.y,
            bottom_width = dimensions.x,
            bottom_length = chamfer_top
                ? dimensions.y - dimensions.z / 2
                : dimensions.y,
            height = _depth + e,
            top_weight_y = chamfer_top ? 0 : .5
        );
    }

    _section();

    if (chamfer > 0) {
        translate([0, 0, depth - chamfer]) {
            _section(
                [
                    dimensions.x + chamfer * 2,
                    dimensions.y + chamfer * 2
                ],
                chamfer
            );
        }
    }
}

module enclosure_engraving(
    string,
    svg = BRANDING_SVG, svg_rotation = 0,
    resize = undef,
    size = ENCLOSURE_ENGRAVING_TEXT_SIZE,
    bleed = ENCLOSURE_ENGRAVING_BLEED,
    chamfer = ENCLOSURE_ENGRAVING_CHAMFER,
    center = true,
    position = [0, 0],
    font = ENGRAVING_FONT,
    depth = ENCLOSURE_ENGRAVING_DEPTH,

    placard = undef,

    // Chamfers the top of the placard's engraving.
    // Use to prevent drooping when printing vertically!
    chamfer_placard_top = false,

    include_wordmark = false,
    wordmark_gutter = [ENCLOSURE_ENGRAVING_GUTTER * 2, ENCLOSURE_ENGRAVING_GUTTER * 2],

    rotation = 0,

    bottom = false,

    quick_preview = true,
    enclosure_height = 1
) {
    e = .0135;

    wordmark_length = placard
        ? (placard.x - wordmark_gutter.x * 2) * OSKITONE_LENGTH_WIDTH_RATIO
        : size;

    inner_length = include_wordmark
        ? wordmark_length + wordmark_gutter.y + size
        : 0;

    module _engraving(_string, _size) {
        resize = _string
            ? undef
            : svg == BRANDING_SVG
                ? [_size / OSKITONE_LENGTH_WIDTH_RATIO, _size]
                : resize;

        engraving(
            string = _string,
            svg = svg, svg_rotation = svg_rotation,
            font = font,
            size = _string ? size : undef,
            resize = resize,
            bleed = quick_preview ? 0 : bleed,
            height = placard ? depth + e * 3 : depth + e,
            center = center,
            chamfer =  quick_preview ? 0 : (placard ? 0 : chamfer)
        );
    }

    translate([
        position.x,
        position.y,
        bottom ? depth : enclosure_height - depth
    ]) {
        rotate([0, bottom ? 180 : 0, rotation]) {
            difference() {
                if (placard) {
                    translate([
                        placard.x / (center ? -2 : 1),
                        placard.y / (center ? -2 : 1)
                    ]) {
                        enclosure_engraving_placard(
                            placard,
                            depth,
                            chamfer_placard_top,
                            quick_preview ? 0 : chamfer
                        );
                    }
                }

                union() {
                    if (include_wordmark) {
                        translate([
                            0,
                            inner_length / 2 - wordmark_length / 2,
                            placard ? -e : 0
                        ]) {
                            _engraving(undef, wordmark_length);
                        }
                    }

                    translate([
                        0,
                        include_wordmark ? inner_length / -2 + size / 2: 0,
                        placard ? -e : 0
                    ]) {
                        _engraving(string ? string : undef, size);
                    }
                }
            }
        }
    }
}

// All of these are fine but -.1 bleed and .4 chamfer seems to look best
// .2 chamfer could also be fine if .4 isn't defined enough
/* bleeds = [-.1];
chamfers = [.2, .3, .4, .6];

bottom_engraving_length = 8;

gutter = 1;
plot_width = 50;
plot_length = 9;

difference() {
    cube([
        plot_width * len(bleeds) + gutter * 2,
        plot_length * len(chamfers) + gutter * 2,
        2
    ]);

    for (i = [0 : len(bleeds) - 1]) {
        for (ii = [0 : len(chamfers) - 1]) {
            translate([0, 0, -.01]) {
                enclosure_engraving(
                    size = bottom_engraving_length,
                    bleed = bleeds[i],
                    chamfer = chamfers[ii],
                    center = true,
                    position = [
                        gutter + plot_width * i + plot_width / 2,
                        gutter + plot_length * ii + plot_length / 2
                    ],
                    bottom = true,
                    enclosure_height = 2,
                    quick_preview = false // $preview
                );
            }
        }
    }
} */
