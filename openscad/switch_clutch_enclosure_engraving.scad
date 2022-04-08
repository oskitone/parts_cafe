include <../../openscad-animation/animation.scad>;
include <enclosure_engraving.scad>;
include <engraving.scad>;
include <switch_clutch.scad>;

SWITCH_CLUTCH_CLEARANCE = .4;

SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_PRIMARY_TEXT_SIZE =
    ENCLOSURE_ENGRAVING_TEXT_SIZE;
SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_SECONDARY_TEXT_SIZE =
    ENCLOSURE_ENGRAVING_TEXT_SIZE * .75; // TODO: test

function get_switch_clutch_window_position(
    engraving_width = 0,
    engraving_length = 0,

    actuator_window_dimensions = [0, 0],

    wall_gutter = 0,
    outer_gutter = ENCLOSURE_ENGRAVING_GUTTER,

    z = 0
) = ([
    wall_gutter + outer_gutter,
    wall_gutter - outer_gutter + engraving_length - actuator_window_dimensions.y,
    z
]);

function get_switch_clutch_switch_position(
    engraving_width = 0,
    engraving_length = 0,

    actuator_window_dimensions = [0, 0],

    wall_gutter = 0,
    outer_gutter = ENCLOSURE_ENGRAVING_GUTTER,

    e = .01
) = (
    let(window_position = get_switch_clutch_window_position(
        engraving_width = engraving_width,
        engraving_length = engraving_length,
        actuator_window_dimensions = actuator_window_dimensions,
        wall_gutter = wall_gutter,
        outer_gutter = outer_gutter
    ))

    [
        window_position.x
            - SWITCH_ORIGIN.x
            - (SWITCH_BASE_WIDTH - actuator_window_dimensions.x) / 2,
        window_position.y
            - SWITCH_ORIGIN.y
            - (SWITCH_BASE_LENGTH - actuator_window_dimensions.y) / 2,
        - SWITCH_CLUTCH_MIN_BASE_HEIGHT - e
    ]
);

function get_actuator_window_dimensions(
    width = 6,

    engraving_length = 0,

    primary_text_size = SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_PRIMARY_TEXT_SIZE,
    secondary_text_size = SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_SECONDARY_TEXT_SIZE,
    label_gutter = ENCLOSURE_ENGRAVING_GUTTER,

    outer_gutter = ENCLOSURE_ENGRAVING_GUTTER,

    control_clearance = SWITCH_CLUTCH_CLEARANCE
) = (
    let(length_based_on_engraving_length = engraving_length -
        primary_text_size - label_gutter - outer_gutter * 2)
    let(length_based_on_text = secondary_text_size * 2 + label_gutter)

    [
        width + control_clearance * 2,
        engraving_length > 0
            ? length_based_on_engraving_length
            : length_based_on_text + control_clearance * 2,
    ]
);

// TODO: be intentional about which comes first, the window and its clearance
// or ideal text alignment. The other should derive from it.
function get_switch_clutch_enclosure_engraving_length(
    actuator_window_length = 0,

    primary_text_size = SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_PRIMARY_TEXT_SIZE,
    label_gutter = ENCLOSURE_ENGRAVING_GUTTER,
    outer_gutter = ENCLOSURE_ENGRAVING_GUTTER
) = (
    primary_text_size
    + actuator_window_length
    + outer_gutter * 2
    + label_gutter
);

module actuator_window(
    dimensions = [0,0],
    depth = 2,
    tolerance = 0
) {
    e = .041;

    translate([-tolerance, -tolerance, 0]) {
        cube([
            dimensions.x + tolerance * 2,
            dimensions.y + tolerance * 2,
            depth + e * 3
        ]);
    }
}


module switch_clutch_enclosure_engraving(
    primary_label = "",
    secondary_labels = ["", ""],

    width = 28,
    length = get_switch_clutch_enclosure_engraving_length(),
    depth = ENCLOSURE_ENGRAVING_DEPTH,

    label_gutter = ENCLOSURE_ENGRAVING_GUTTER,
    outer_gutter = ENCLOSURE_ENGRAVING_GUTTER,

    primary_text_size = SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_PRIMARY_TEXT_SIZE,
    secondary_text_size = SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_SECONDARY_TEXT_SIZE,

    actuator_window_dimensions = [0, 0],

    control_clearance = 0,
    tolerance = 0,

    quick_preview = true,

    show_window = false, // TODO: window_brim

    position = [0, 0],
    enclosure_height = 1
) {
    e = .0931;

    control_gutter = control_clearance + tolerance;

    window_position = get_switch_clutch_window_position(
        engraving_width = width,
        engraving_length = length,
        actuator_window_dimensions = actuator_window_dimensions,
        outer_gutter = outer_gutter,
        z = -e
    );

    module _labels() {
        module _engraving(
            string,
            is_primary = false,
            secondary_i = 0
        ) {
            half_length = actuator_window_dimensions.y / 2;
            secondary_text_ys = [
                (half_length - secondary_text_size) / 2,
                (half_length - secondary_text_size) / 2 + half_length
            ];

            x = is_primary
                ? width / 2
                : window_position.x + actuator_window_dimensions.x
                    + label_gutter;
            y = is_primary
                ? outer_gutter + primary_text_size / 2
                : window_position.y + secondary_text_ys[secondary_i];

            translate([x, y, 0]) {
                engraving(
                    string = string,
                    size = is_primary ? primary_text_size : secondary_text_size,
                    bleed = quick_preview ? 0 : ENCLOSURE_ENGRAVING_BLEED,
                    height = depth + e * 3,
                    center = is_primary,
                    chamfer =  quick_preview ? 0 : ENCLOSURE_ENGRAVING_CHAMFER
                );
            }
        }

        _engraving(primary_label, is_primary = true);
        _engraving(secondary_labels[0], secondary_i = 0);
        _engraving(secondary_labels[1], secondary_i = 1);
    }

    translate([position.x, position.y, enclosure_height - depth]) {
        difference() {
            cube([width, length, depth + e]);

            translate(window_position) {
                if (show_window) {
                    actuator_window(
                        dimensions = actuator_window_dimensions,
                        depth = depth,
                        tolerance = tolerance
                    );
                }
            }

            _labels();
        }
    }
}

module __demo_switch_clutch_enclosure_engraving(
    wall_gutter = 2,
    engraving_width = 13.7,
    engraving_length = 12.4, // TODO: derive and extract

    actuator_length = undef,
    switch_position = 0,

    depth = ENCLOSURE_ENGRAVING_DEPTH,

    label_gutter = ENCLOSURE_ENGRAVING_GUTTER,
    outer_gutter = ENCLOSURE_ENGRAVING_GUTTER,

    primary_text_size = SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_PRIMARY_TEXT_SIZE,
    secondary_text_size = SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_SECONDARY_TEXT_SIZE,

    control_clearance = .4,
    tolerance = .1,

    quick_preview = true,

    enclosure_height = 2
) {
    e = .0382;

    actuator_window_dimensions = get_actuator_window_dimensions(
        width = SWITCH_CLUTCH_MIN_BASE_WIDTH,
        engraving_length = engraving_length,
        primary_text_size = primary_text_size,
        secondary_text_size = secondary_text_size,
        label_gutter = label_gutter,
        outer_gutter = outer_gutter,
        control_clearance = control_clearance
    );

    min_length = get_switch_clutch_enclosure_engraving_length(
        actuator_window_length = actuator_window_dimensions.y,
        primary_text_size = primary_text_size,
        label_gutter = label_gutter,
        outer_gutter = outer_gutter
    );

    // TODO: extract
    if (engraving_length < min_length - e) {
        echo(str(
            "WARNING: length of ", engraving_length,
            " is more than min_length of ",
            min_length
        ));
    }

    max_actuator_length = get_max_switch_clutch_actuator_length(
        actuator_window_length = actuator_window_dimensions.y,
        control_clearance = control_clearance,
        tolerance = tolerance
    );
    actuator_length = actuator_length != undef
        ? actuator_length
        : max_actuator_length;

    // TODO: extract
    if (actuator_length > max_actuator_length) {
        echo(str(
            "WARNING: actuator_length of ", actuator_length,
            " is more than max_actuator_length of ",
            max_actuator_length
        ));
    }

    switch_clutch_switch_position = get_switch_clutch_switch_position(
        engraving_width = engraving_width,
        engraving_length = engraving_length,
        actuator_window_dimensions = actuator_window_dimensions,
        wall_gutter = wall_gutter,
        outer_gutter = outer_gutter
    );

    switch_clutch_window_position = get_switch_clutch_window_position(
        engraving_width = engraving_width,
        engraving_length = engraving_length,

        actuator_window_dimensions = actuator_window_dimensions,

        wall_gutter = wall_gutter,
        outer_gutter = outer_gutter,

        z = -e
    );

    translate(switch_clutch_switch_position) {
        switch(position = switch_position);

        translate([0,0,-e]) {
            switch_clutch(
                base_width = 10,
                base_length = actuator_window_dimensions.y
                    + tolerance * 2
                    + SWITCH_ACTUATOR_TRAVEL + e * 2,
                actuator_length = actuator_length,
                position = switch_position,
                fillet = 1, $fn = 12
            );
        }
    }

    difference() {
        cube([
            engraving_width + wall_gutter * 2,
            engraving_length + wall_gutter * 2,
            enclosure_height
        ]);

        translate(switch_clutch_window_position) {
            actuator_window(
                actuator_window_dimensions,
                depth = enclosure_height + e * 2,
                tolerance = tolerance
            );
        }

        switch_clutch_enclosure_engraving(
            "POW",
            ["0", "1"],

            width = engraving_width,
            length = engraving_length,
            depth = depth,

            label_gutter = label_gutter,
            outer_gutter = outer_gutter,

            primary_text_size = primary_text_size,
            secondary_text_size = secondary_text_size,

            actuator_window_dimensions = actuator_window_dimensions,

            control_clearance = control_clearance,
            tolerance = tolerance,

            quick_preview = quick_preview,

            position = [wall_gutter, wall_gutter],
            enclosure_height = enclosure_height
        );
    }
}
* __demo_switch_clutch_enclosure_engraving(
    wall_gutter = 2,
    /* engraving_width = 15, */
    /* engraving_length = 20, */
    switch_position = (abs($t - 1 / 2) * 2)
);
