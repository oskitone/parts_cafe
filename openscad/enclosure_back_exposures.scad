include <enclosure_engraving.scad>;
include <enclosure.scad>;
include <flat_top_rectangular_pyramid.scad>;
include <headphone_jack.scad>;
include <pcb.scad>;
include <uart_header.scad>;

ENCLOSURE_BACK_EXPOSURE_X_BLEED = 1;
ENCLOSURE_BACK_EXPOSURE_LABEL_MIN_WIDTH = 16;
ENCLOSURE_BACK_EXPOSURE_CAVITY_MIN_HEIGHT = 4;

ENCLOSURE_BACK_EXPOSURE_MIN_CLEARANCE_DIAMETER =
    HEADPHONE_JACK_ENCLOSURE_CLEARANCE_DIAMETER;

function get_enclosure_back_engraving_z(
    pcb_z = 0,
    label_height = ENCLOSURE_ENGRAVING_LENGTH
) = (
    pcb_z + PCB_HEIGHT + HEADPHONE_JACK_BARREL_Z
        - ENCLOSURE_BACK_EXPOSURE_MIN_CLEARANCE_DIAMETER / 2
        - ENCLOSURE_ENGRAVING_GUTTER
        - label_height / 2
);

module enclosure_back_engraving(
    string = "",
    enclosure_length = 0,
    placard = undef,
    x = 0,
    z = 0,
    label_text_size = ENCLOSURE_ENGRAVING_TEXT_SIZE,
    quick_preview = true
) {
    e = .0345;

    translate([x, enclosure_length + e, z]) {
        rotate([90, 0, 0]) {
            enclosure_engraving(
                string = string,
                size = label_text_size,
                bleed = 0,
                placard = placard != undef ? placard : undef,
                chamfer_placard_top = !quick_preview,
                chamfer =  0,
                bottom = true
            );
        }
    }
}

module enclosure_back_header_exposure(
    string = "UART",
    side_labels = ["G", "B"],

    enclosure_length = 0,
    pcb_z = 0,

    center_x = 0,
    component_width = UART_HEADER_BLOCK_DIMENSIONS.x,
    component_height = UART_HEADER_BLOCK_DIMENSIONS.z,

    clearance_chamfer = ENCLOSURE_ENGRAVING_DEPTH / 2,

    label_text_size = ENCLOSURE_ENGRAVING_TEXT_SIZE,
    label_height = ENCLOSURE_ENGRAVING_LENGTH,

    tolerance = 0,

    x_bleed = ENCLOSURE_BACK_EXPOSURE_X_BLEED,
    min_height = ENCLOSURE_BACK_EXPOSURE_CAVITY_MIN_HEIGHT,

    quick_preview = true
) {
    e = .0124;

    component_center_z = pcb_z + PCB_HEIGHT + component_height / 2;
    cavity_z = min(
        component_center_z - min_height / 2,
        get_enclosure_back_engraving_z(pcb_z, label_height)
            + label_height / 2 + ENCLOSURE_ENGRAVING_GUTTER
    );

    width = component_width + x_bleed * 2 + tolerance * 2;
    height = max(
        min_height,
        (component_center_z - cavity_z) * 2
    );

    translate([
        center_x - width / 2,
        enclosure_length - ENCLOSURE_WALL - e,
        cavity_z
    ]) {
        rotate([-90, 0, 0]) {
            translate([0, -height, 0]) {
                flat_top_rectangular_pyramid(
                    top_width = width + clearance_chamfer,
                    top_length = height + clearance_chamfer * 2,
                    bottom_width = width,
                    bottom_length = height,
                    height = ENCLOSURE_WALL + e * 2,
                    top_weight_y = .75
                );
            }
        }
    }

    enclosure_back_engraving(
        string = string,
        enclosure_length = enclosure_length,
        placard = [width, label_height],
        x = center_x,
        z = get_enclosure_back_engraving_z(pcb_z, label_height),
        label_text_size = label_text_size,
        quick_preview = quick_preview
    );

    if (len(side_labels) == 2) {
        for (i = [0 : 1]) {
            enclosure_back_engraving(
                string = side_labels[i],
                enclosure_length = enclosure_length,
                x = center_x
                    + (width + label_text_size + ENCLOSURE_ENGRAVING_GUTTER * 2) / 2
                    * (i == 0 ? 1 : -1),
                z = pcb_z + PCB_HEIGHT + component_height / 2,
                label_text_size = label_text_size,
                quick_preview = quick_preview
            );
        }
    }
}

module enclosure_back_headphone_jack_exposure(
    string = "OUT",

    enclosure_length = 0,
    pcb_z = 0,

    center_x = 0,
    component_width = HEADPHONE_JACK_WIDTH,
    component_height = HEADPHONE_JACK_HEIGHT,
    component_barrel_diameter = HEADPHONE_JACK_BARREL_DIAMETER,
    component_barrel_z = HEADPHONE_JACK_BARREL_Z,

    clearance_diameter = ENCLOSURE_BACK_EXPOSURE_MIN_CLEARANCE_DIAMETER,
    clearance_depth = ENCLOSURE_ENGRAVING_DEPTH,
    clearance_chamfer = ENCLOSURE_ENGRAVING_DEPTH / 2,

    label_text_size = ENCLOSURE_ENGRAVING_TEXT_SIZE,
    label_height = ENCLOSURE_ENGRAVING_LENGTH,

    tolerance = 0,

    x_bleed = ENCLOSURE_BACK_EXPOSURE_X_BLEED,
    min_width = ENCLOSURE_BACK_EXPOSURE_LABEL_MIN_WIDTH,
    min_height = ENCLOSURE_BACK_EXPOSURE_CAVITY_MIN_HEIGHT,

    quick_preview = true
) {
    e = .0124;

    cavity_diameter = component_barrel_diameter + x_bleed * 2 + tolerance * 2;
    label_width = max(min_width, cavity_diameter);

    translate([
        center_x,
        enclosure_length + e,
        pcb_z + PCB_HEIGHT + component_barrel_z
    ]) {
        rotate([90, 0, 0]) {
            cylinder(d = cavity_diameter, h = ENCLOSURE_WALL + e * 2);

            cylinder(
                d1 = quick_preview
                    ? clearance_diameter
                    : clearance_diameter + clearance_chamfer * 2,
                d2 = clearance_diameter,
                h = clearance_depth + e
            );
        }
    }

    enclosure_back_engraving(
        string = string,
        enclosure_length = enclosure_length,
        placard = [label_width, label_height],
        x = center_x,
        z = get_enclosure_back_engraving_z(pcb_z, label_height),
        label_text_size = label_text_size,
        quick_preview = quick_preview
    );
}

/*
enclosure_dimensions = [100,50,25];
difference() {
    cube(enclosure_dimensions);
    translate([ENCLOSURE_WALL, ENCLOSURE_WALL, -1]) {
        cube([
            enclosure_dimensions.x - ENCLOSURE_WALL * 2,
            enclosure_dimensions.y - ENCLOSURE_WALL * 2,
            enclosure_dimensions.z + 2,
        ]);
    }

    enclosure_back_header_exposure(
        enclosure_length = enclosure_dimensions.y,
        pcb_z = 10,
        center_x = 20
    );
    enclosure_back_header_exposure(
        string = "GPIO",
        side_labels = [],
        component_width = 10,
        enclosure_length = enclosure_dimensions.y,
        pcb_z = 10,
        center_x = 45,
        quick_preview = 0,
        tolerance = 2
    );

    enclosure_back_headphone_jack_exposure(
        enclosure_length = enclosure_dimensions.y,
        pcb_z = 10,
        x_bleed = 0,
        center_x = 65
    );
    enclosure_back_headphone_jack_exposure(
        string = "AUD",
        enclosure_length = enclosure_dimensions.y,
        pcb_z = 10,
        center_x = 85,
        quick_preview = 0
    );
}
*/