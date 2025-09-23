include <donut.scad>;
include <flat_top_rectangular_pyramid.scad>;
include <math_utilities.scad>;
include <nuts_and_bolts.scad>;
include <rounded_corner_cutoff.scad>;
include <spst.scad>;

KEY_GUTTER = 1;
KEY_DEFAULT_NATURAL_WIDTH = SPST_PLOT * 2 - KEY_GUTTER;
KEY_DEFAULT_ACCIDENTAL_WIDTH = 7.5;

KEY_CANTILEVER_LENGTH = 3;
KEY_CANTILEVER_HEIGHT = 1;
KEY_CANTILEVER_RECESSION = 3;

KEY_FRONT_FILLET = 2;
KEY_SIDES_FILLET = 1;

KEYS_MOUNT_LENGTH = NUT_DIAMETER;

SCOUT_NATURAL_KEY_LENGTH = 50;
SCOUT_NATURAL_KEY_HEIGHT = 7;
SCOUT_ACCIDENTAL_KEY_LENGTH = 30;
SCOUT_ACCIDENTAL_KEY_HEIGHT = 9;

function get_keys_total_width(
    count,
    starting_note_index = 0,
    natural_width = KEY_DEFAULT_NATURAL_WIDTH,
    gutter = KEY_GUTTER
) = (
    let(natural_key_count=get_natural_key_count(count, starting_note_index))
    natural_key_count * natural_width + max(0, natural_key_count - 1) * gutter
);

function get_starting_note_index(starting_natural_key_index) = (
    [0, 2, 4, 5,7, 9, 11][starting_natural_key_index]
);

function get_natural_key_count(
    total_key_count,
    starting_note_index = 0
) = (
    let (NATURAL_KEY_SEQUENCES = [
        [1,0,1,0,1,1,0,1,0,1,0,1,],
        [0,1,0,1,1,0,1,0,1,0,1,1,],
        [1,0,1,1,0,1,0,1,0,1,1,0,],
        [0,1,1,0,1,0,1,0,1,1,0,1,],
        [1,1,0,1,0,1,0,1,1,0,1,0,],
        [1,0,1,0,1,0,1,1,0,1,0,1,],
        [0,1,0,1,0,1,1,0,1,0,1,1,],
        [1,0,1,0,1,1,0,1,0,1,1,0,],
        [0,1,0,1,1,0,1,0,1,1,0,1,],
        [1,0,1,1,0,1,0,1,1,0,1,0,],
        [0,1,1,0,1,0,1,1,0,1,0,1,],
        [1,1,0,1,0,1,1,0,1,0,1,0,],
    ])

    floor(total_key_count / 12) * 7 +
    (
        total_key_count % 12 == 0
            ? 0
            : sum(
                slice(
                    NATURAL_KEY_SEQUENCES[starting_note_index],
                    0,
                    total_key_count % 12
                )
            )
    )
);

function get_mounted_keys_total_length(
    tolerance = 0,

    natural_length = SCOUT_NATURAL_KEY_LENGTH,

    cantilever_length = KEY_CANTILEVER_LENGTH,
    cantilever_recession = KEY_CANTILEVER_RECESSION,

    mount_length = KEYS_MOUNT_LENGTH
) = (
    natural_length
        + cantilever_length - cantilever_recession
        + tolerance * 2
        + mount_length
);

module keys(
    count = 13,
    starting_natural_key_index = 0,

    natural_width = KEY_DEFAULT_NATURAL_WIDTH,
    natural_length = SCOUT_NATURAL_KEY_LENGTH,
    natural_height = SCOUT_NATURAL_KEY_HEIGHT,

    accidental_width = KEY_DEFAULT_ACCIDENTAL_WIDTH,
    accidental_length = SCOUT_ACCIDENTAL_KEY_LENGTH,
    accidental_height = SCOUT_ACCIDENTAL_KEY_HEIGHT,

    front_fillet = KEY_FRONT_FILLET,
    sides_fillet = KEY_SIDES_FILLET,

    gutter = KEY_GUTTER,

    cantilever_width = undef,
    cantilever_length = KEY_CANTILEVER_LENGTH,
    cantilever_height = KEY_CANTILEVER_HEIGHT,
    cantilever_recession = KEY_CANTILEVER_RECESSION,
    cantilever_z = 0,

    mount_width = undef,
    mount_length = KEYS_MOUNT_LENGTH,
    mount_height = 2,
    mount_hole_xs = [],
    mount_hole_diameter = SCREW_DIAMETER,
    mount_screw_head_diameter = SCREW_HEAD_DIAMETER,

    tolerance = .1,

    include_mount = true,
    include_natural = true,
    include_accidental = true,
    include_cantilevers = true,

    accidental_color = "#444",
    natural_color = "#fff",
    natural_color_cavity = "#eee",

    quick_preview = $preview
) {
    e = 0.04567;

    index_offset = [0,2,4,5,7,9,11][starting_natural_key_index];
    cantilever_width = cantilever_width != undef
        ? cantilever_width
        : min(
            accidental_width,
            natural_width - ((accidental_width - gutter) / 2) * 2 - gutter * 2
        );
    cantilever_length = cantilever_length + tolerance * 2;

    module _mount() {
        y = natural_length + cantilever_length - cantilever_recession;

        total_width = get_keys_total_width(
            count = count,
            starting_note_index =
                get_starting_note_index(starting_natural_key_index),
            natural_width = natural_width,
            gutter = gutter
        );
        width = mount_width != undef
            ? mount_width
            : total_width;
        x = (total_width - width) / 2;

        difference() {
            translate([x, y, 0]) {
                cube([width, mount_length, mount_height]);
            }

            for (hole_x = mount_hole_xs) {
                translate([x + hole_x, y + mount_length / 2, -e]) {
                    cylinder(
                        d = mount_hole_diameter + tolerance * 2,
                        h = mount_height + e * 2,
                        $fn = quick_preview ? 12 : 24
                    );
                }
            }
        }
    }

    module _accidental_cutout(right = true) {
        // Exact size doesn't matter. Just needs to be big and defined.
        width = max(natural_width, accidental_width);

        length = accidental_length + gutter + e;

        // NOTE: This could be derived. This math is kinda arbitrary.
        front_clearance = (accidental_height - natural_height) / 2;

        translate([
            right
                ? natural_width - (accidental_width - gutter) / 2 - gutter
                : width * -1 + (accidental_width - gutter) / 2
                    + gutter,
            natural_length - accidental_length - gutter,
            -e
        ]) {
            flat_top_rectangular_pyramid(
                top_width = width,
                top_length = length + front_clearance,
                bottom_width = width,
                bottom_length = length,
                height = natural_height + (e * 2),
                top_weight_y = 1
            );
        }
    }

    module _key_block(dimensions, is_natural, cut_left, cut_right) {
        cavity_width = dimensions[0] + e * 2;

        width = dimensions[0];
        length = dimensions[1];
        height = dimensions[2];

        module _base() {
            module _points() {
                module _donut() {
                    render() donut(
                        front_fillet * 2,
                        sides_fillet,
                        segments = 12,
                        coverage = 90,
                        starting_angle = 180
                    );
                }

                // front bottom left
                translate([sides_fillet, sides_fillet, 0]) {
                    cylinder(r = sides_fillet, h = e);
                }

                // front top left
                translate([sides_fillet / 2, front_fillet, height - front_fillet]) {
                    rotate([0, 90, 0]) _donut();;
                }

                // front bottom right
                translate([width - sides_fillet, sides_fillet, 0]) {
                    cylinder(r = sides_fillet, h = e);
                }

                // front top right
                translate([width - sides_fillet / 2, front_fillet, height - front_fillet]) {
                    rotate([0, 90, 0]) _donut();;
                }

                // back bottom left
                translate([0, length - e, 0]) {
                    cube([e, e, e]);
                }

                // back bottom right
                translate([width - e, length - e, 0]) {
                    cube([e, e, e]);
                }

                // back top left
                translate([sides_fillet / 2, length, height - sides_fillet / 2]) {
                    rotate([90, 0, 0]) {
                        cylinder(r = front_fillet / 2, h = e, $fn = 12);
                    }
                }

                // back top right
                translate([width - sides_fillet / 2, length, height - sides_fillet / 2]) {
                    rotate([90, 0, 0]) {
                        cylinder(r = front_fillet / 2, h = e, $fn = 12);
                    }
                }
            }

            if (front_fillet + sides_fillet > 0) {
                hull() _points();
            } else {
                cube(dimensions);
            }
        }

        module _fillet() {
            if (front_fillet > 0) {
                translate([0, front_fillet, height - front_fillet]) {
                    rotate([0, 90, 0]) {
                        rounded_corner_cutoff(
                            height = width,
                            radius = front_fillet,
                            angle = 180
                        );
                    }
                }
            }
        }

        module _cantilever_recession_cavity() {
            x = -e;
            y = dimensions[1] - cantilever_recession;

            length = cantilever_recession + e;

            if (cantilever_recession > 0) {
                translate([x, y, -e]) {
                    cube([
                        cavity_width,
                        length,
                        cantilever_height + e
                    ]);
                }

                translate([x, y, cantilever_height - e]) {
                    flat_top_rectangular_pyramid(
                        top_width = cavity_width,
                        top_length = 0,
                        bottom_width = cavity_width,
                        bottom_length = length,
                        height = length,
                        top_weight_y = 1
                    );
                }
            }
        }

        difference() {
            _base();
            _fillet();
            _cantilever_recession_cavity();
        }

        if (include_cantilevers) {
             translate([
                 (dimensions[0] - cantilever_width) / 2,
                 dimensions[1] - cantilever_recession - e,
                 cantilever_z
             ]) {
                 linear_extrude(cantilever_height) {
                     polygon(
                         points=[
                            [0, 0],
                            [cantilever_width, 0],
                            [cantilever_width + gutter / 2, cantilever_length + e * 2],
                            [-gutter / 2, cantilever_length + e * 2]
                        ]
                     );
                 }
             }
        }
    }

    module _natural(i, x, note_in_octave_index, natural_index) {
        cut_left = (
            (note_in_octave_index != 0 && note_in_octave_index != 5) &&
            i != 0
        );
        cut_right = (
            (note_in_octave_index != 4 && note_in_octave_index != 11) &&
            i != count - 1
        );

        translate([x, 0, 0]) {
            difference() {
                _key_block(
                    [natural_width, natural_length, natural_height],
                    is_natural = true,
                    cut_left = cut_left,
                    cut_right = cut_right
                );

                if (cut_left) {
                    _accidental_cutout(right = false);
                }

                if (cut_right) {
                    _accidental_cutout(right = true);
                }
            }
        }
    }

    module _accidental(i, x, note_in_octave_index, natural_index) {
        y = natural_length - accidental_length;

        translate([x, y, 0]) {
            _key_block(
                [accidental_width, accidental_length, accidental_height],
                is_natural = false
            );
        }
    }

    for (i = [0 : count - 1]) {
        adjusted_i = (i + index_offset);
        note_in_octave_index = adjusted_i % 12;
        natural_index = round(adjusted_i * (7 / 12));
        is_natural = len(search(note_in_octave_index, [1,3,6,8,10])) == 0;
        is_accidental = !is_natural;

        if (is_natural && include_natural) {
            x = (natural_width + gutter) * (natural_index - starting_natural_key_index);

            color(natural_color) {
                _natural(i, x, note_in_octave_index, natural_index);
            }
        }

        if (is_accidental && include_accidental) {
            x = (natural_index - starting_natural_key_index) * (natural_width + gutter)
                 - (gutter / 2) - (accidental_width / 2);

            color(accidental_color) translate([0, quick_preview ? e : 0, 0]) {
                _accidental(i, x, note_in_octave_index, natural_index);
            }
        }
    }

    if (include_mount) {
        _mount();
    }
}