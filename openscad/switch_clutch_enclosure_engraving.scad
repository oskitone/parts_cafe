include <../../openscad-animation/animation.scad>;
include <enclosure_engraving.scad>;
include <engraving.scad>;
include <switch_clutch.scad>;

SWITCH_CLUTCH_CLEARANCE = .4;

SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_PRIMARY_TEXT_SIZE =
    ENCLOSURE_ENGRAVING_TEXT_SIZE;
SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_SECONDARY_TEXT_SIZE =
    ENCLOSURE_ENGRAVING_TEXT_SIZE * .75; // TODO: test

function get_switch_clutch_switch_position(
    actuator_window_dimensions = [0, 0]
) = (
    [
        -SWITCH_ORIGIN.x
            - (SWITCH_BASE_WIDTH - actuator_window_dimensions.x) / 2,
        -SWITCH_ORIGIN.y
            - (SWITCH_BASE_LENGTH - actuator_window_dimensions.y) / 2,
        - SWITCH_CLUTCH_MIN_BASE_HEIGHT
    ]
);

function get_actuator_window_dimensions(
    width = SWITCH_CLUTCH_MIN_ACTUATOR_WIDTH,
    length = undef, // used if provided, otherwise derived from text + gutter

    secondary_text_size = SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_SECONDARY_TEXT_SIZE,
    label_gutter = ENCLOSURE_ENGRAVING_GUTTER,

    control_clearance = SWITCH_CLUTCH_CLEARANCE
) = (
    [
        width + control_clearance * 2,
        (length != undef ? length : secondary_text_size * 2 + label_gutter)
            + control_clearance * 2,
    ]
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
    labels = ["", ""],
    depth = ENCLOSURE_ENGRAVING_DEPTH,
    label_gutter = ENCLOSURE_ENGRAVING_GUTTER,
    secondary_text_size = SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_SECONDARY_TEXT_SIZE,
    actuator_window_dimensions = undef,
    control_clearance = 0,
    quick_preview = true,
    position = [0, 0],
    enclosure_height = 1
) {
    e = .0931;

    actuator_window_dimensions = actuator_window_dimensions != undef
        ? actuator_window_dimensions
        : get_actuator_window_dimensions(
            secondary_text_size = secondary_text_size,
            label_gutter = label_gutter,
            control_clearance = control_clearance
        );

    module _engraving(string, i = 0) {
        half_length = actuator_window_dimensions.y / 2;
        ys = [
            (half_length - secondary_text_size) / 2,
            (half_length - secondary_text_size) / 2 + half_length
        ];
        x = actuator_window_dimensions.x + label_gutter;

        enclosure_engraving(
            string = string,
            size = secondary_text_size,
            depth = depth,
            center = false,
            position = [x, ys[i]],
            quick_preview = quick_preview,
            enclosure_height = enclosure_height
        );
    }

    translate([position.x, position.y, 0]) {
        for (i = [0 : 1]) {
            _engraving(labels[i], i);
        }
    }
}

module __demo_switch_clutch_enclosure_engraving(
    wall_gutter = 2,

    actuator_length = undef,
    switch_position = 0,

    depth = ENCLOSURE_ENGRAVING_DEPTH,

    label_gutter = ENCLOSURE_ENGRAVING_GUTTER,

    primary_text_size = SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_PRIMARY_TEXT_SIZE,
    secondary_text_size = SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_SECONDARY_TEXT_SIZE,

    control_clearance = SWITCH_CLUTCH_CLEARANCE,
    tolerance = 0,

    quick_preview = true,

    enclosure_height = 2
) {
    e = .0382;

    actuator_window_dimensions = get_actuator_window_dimensions(
        width = SWITCH_CLUTCH_MIN_BASE_WIDTH,
        secondary_text_size = secondary_text_size,
        label_gutter = label_gutter,
        control_clearance = control_clearance
    );

    switch_and_clutch_position = [
        wall_gutter,
        wall_gutter + label_gutter + ENCLOSURE_ENGRAVING_LENGTH
    ];

    width = 20 + wall_gutter * 2;
    length = actuator_window_dimensions.y
        + switch_and_clutch_position.y
        + wall_gutter;

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

    # translate(switch_and_clutch_position) {
        translate(get_switch_clutch_switch_position(actuator_window_dimensions)) {
            translate([0, 0, -e]) switch(position = switch_position);

            translate([0, 0, e]) switch_clutch(
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
        cube([width, length, enclosure_height]);

        translate(switch_and_clutch_position) translate([0, 0, -e]) {
            actuator_window(
                actuator_window_dimensions,
                depth = enclosure_height + e * 2,
                tolerance = tolerance
            );
        }

        enclosure_engraving(
            "WAIT!",
            position = [
                width / 2,
                wall_gutter + ENCLOSURE_ENGRAVING_LENGTH / 2
            ],
            placard = [width - wall_gutter * 2, ENCLOSURE_ENGRAVING_LENGTH],
            quick_preview = quick_preview,
            enclosure_height = enclosure_height
        );

        switch_clutch_enclosure_engraving(
            ["NOPE", "YEP"],
            depth = depth,
            label_gutter = label_gutter,
            secondary_text_size = secondary_text_size,
            actuator_window_dimensions = actuator_window_dimensions,
            control_clearance = control_clearance,
            quick_preview = quick_preview,
            position = switch_and_clutch_position,
            enclosure_height = enclosure_height
        );
    }
}
* __demo_switch_clutch_enclosure_engraving(
    wall_gutter = 2,
    switch_position = ease_in_out_quint(abs($t - 1 / 2) * 2),
    control_clearance = SWITCH_CLUTCH_CLEARANCE,
    tolerance = .1,
    quick_preview = 1
);
