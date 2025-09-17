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

module enclosure_engraving(
    string,
    size = ENCLOSURE_ENGRAVING_TEXT_SIZE,
    bleed = ENCLOSURE_ENGRAVING_BLEED,
    chamfer = ENCLOSURE_ENGRAVING_CHAMFER,
    center = true, // TODO: is this working as expected?
    position = [0, 0],
    font = ENGRAVING_FONT,
    depth = ENCLOSURE_ENGRAVING_DEPTH,

    placard = undef,

    // Chamfers the top of the placard's engraving.
    // Use to prevent drooping when printing vertically!
    chamfer_placard_top = false,

    rotation = 0,

    bottom = false,

    quick_preview = true,
    enclosure_height = 1
) {
    e = .0135;

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
                        flat_top_rectangular_pyramid(
                            top_width = placard.x,
                            top_length = chamfer_placard_top
                                ? placard.y + depth / 2
                                : placard.y,
                            bottom_width = placard.x,
                            bottom_length = chamfer_placard_top
                                ? placard.y - depth / 2
                                : placard.y,
                            height = depth + e,
                            top_weight_y = 0
                        );
                    }
                }

                translate(placard ? [0, 0, -e] : [0, 0, 0]) {
                    engraving(
                        string = string ? string : undef,
                        svg = string ? undef : "../../parts_cafe/images/branding.svg",
                        font = font,
                        size = string ? size : undef,
                        resize = string
                            ? undef
                            : [size / OSKITONE_LENGTH_WIDTH_RATIO, size],
                        bleed = quick_preview ? 0 : bleed,
                        height = placard ? depth + e * 3 : depth + e,
                        center = center,
                        chamfer =  quick_preview ? 0 : (placard ? 0 : chamfer)
                    );
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
