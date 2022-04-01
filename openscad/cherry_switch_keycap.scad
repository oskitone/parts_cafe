include <cherry_switch.scad>;
include <enclosure_engraving.scad>;

STOCK_CHERRY_SWITCH_KEYCAP_DIMENSIONS = [18, 18, 10];

module cherry_switch_keycap(
    dimensions = STOCK_CHERRY_SWITCH_KEYCAP_DIMENSIONS,

    exposed_height = 5,

    contact_width = 14,
    contact_length = 14,

    fillet = 1,

    cavity_clearance = .4,

    switch_position = 0,

    tolerance = 0, // 0 to .1 seems good!
    stem_fit_tolerance = 0, // 0 to .1 seems good!

    cherry_switch_base_width = CHERRY_SWITCH_BASE_WIDTH,
    cherry_switch_base_length = CHERRY_SWITCH_BASE_LENGTH,
    cherry_switch_base_height = CHERRY_SWITCH_BASE_HEIGHT,

    cherry_switch_actuator_plate_width = CHERRY_SWITCH_ACTUATOR_PLATE_WIDTH,
    cherry_switch_actuator_plate_length = CHERRY_SWITCH_ACTUATOR_PLATE_LENGTH,

    cherry_switch_stem_horizontal_web_depth = CHERRY_SWITCH_STEM_HORIZONTAL_WEB_DEPTH,
    cherry_switch_stem_vertical_web_depth = CHERRY_SWITCH_STEM_VERTICAL_WEB_DEPTH,

    cherry_switch_travel = CHERRY_SWITCH_TRAVEL,

    debug = false
) {
    e = .0418;

    module _cherry_switch(
        z = 0,
        base_bleed = 0,
        plate_bleed = 0,
        stem_bleed = 0,
        show_base = true,
        show_stem = true,
        position = 0
    ) {
        translate([
            dimensions.x / 2,
            dimensions.y / 2,
            z
        ]) {
            cherry_switch(
                base_width = cherry_switch_base_width + base_bleed * 2,
                base_length = cherry_switch_base_length + base_bleed * 2,

                actuator_plate_width = cherry_switch_actuator_plate_width
                    + plate_bleed * 2,
                actuator_plate_length = cherry_switch_actuator_plate_length
                    + plate_bleed * 2,

                position = position,

                stem_horizontal_web_depth =
                    cherry_switch_stem_horizontal_web_depth + stem_bleed * 2,
                stem_vertical_web_depth =
                    cherry_switch_stem_vertical_web_depth + stem_bleed * 2,

                show_base = show_base,
                show_stem = show_stem,

                center = true
            );
        }
    }

    module _outer() {
        base_height = dimensions.z - exposed_height;

        module _layer(
            width = dimensions.x,
            length = dimensions.y,
            z = 0,
            flat = false
        ) {
            for (
                x = [fillet, width - fillet],
                y = [fillet, length - fillet]
            ) {
                translate([
                    x + (dimensions.x - width) / 2,
                    y + (dimensions.y - length) / 2,
                    z
                ]) {
                    if (flat) {
                        cylinder(
                            r = fillet,
                            h = e
                        );
                    } else {
                        sphere(r = fillet);
                    }
                }
            }
        }

        hull() {
            _layer(flat = true);
            _layer(z = base_height);

            _layer(
                width = contact_width,
                length = contact_length,
                z = dimensions.z - fillet
            );
        }
    }

    module _cavity() {
        _cherry_switch(
            z = -cherry_switch_base_height + cherry_switch_travel,
            base_bleed = cavity_clearance + tolerance,
            plate_bleed = -(cavity_clearance + tolerance),
            show_stem = false
        );

        // TODO: DFM chamfer
        _cherry_switch(
            z = -cherry_switch_base_height,
            stem_bleed = stem_fit_tolerance,
            show_base = false
        );
    }

    translate([0, 0, switch_position * -cherry_switch_travel]) {
        difference() {
            _outer();

            _cavity();

            if (debug) {
                translate([dimensions.x / 2, -e, -e]) {
                    cube([
                        dimensions.x / 2 + e,
                        dimensions.y + e * 2,
                        dimensions.z + e * 2
                    ]);
                }
            }
        }
    }

    if (debug) {
        % _cherry_switch(
            -cherry_switch_base_height,
            position = switch_position
        );
    }
}

/* module __tolerance_goldilocks_cherry_switch_keycap(
    tolerances = [-.1, 0, .1, .2],

    dimensions = [20, 20, 6],
    exposed_height = 5,
    overlap = 1,
    fillet = .1
) {
    for (i = [0 : len(tolerances) - 1]) {
        translate([(dimensions.x - overlap) * i, 0, 0]) {
            difference() {
                cherry_switch_keycap(
                    dimensions = dimensions,
                    contact_width = dimensions.x,
                    contact_length = dimensions.y,
                    exposed_height = exposed_height,
                    fillet = fillet,
                    tolerance = tolerances[i]
                );

                enclosure_engraving(
                    string = str(tolerances[i] * 10),
                    size = 7,
                    position = [dimensions.x / 2, dimensions.y / 2],
                    quick_preview = true,
                    enclosure_height = dimensions.z
                );
            }
        }
    }
}

__tolerance_goldilocks_cherry_switch_keycap(); */
