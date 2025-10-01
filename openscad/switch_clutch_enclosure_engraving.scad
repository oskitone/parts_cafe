include <console.scad>;
include <enclosure_engraving.scad>;
include <engraving.scad>;
include <switch_clutch.scad>;

SWITCH_CLUTCH_CLEARANCE = .4;

SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_PRIMARY_TEXT_SIZE =
    ENCLOSURE_ENGRAVING_TEXT_SIZE;
SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_SECONDARY_TEXT_SIZE =
    ENCLOSURE_ENGRAVING_TEXT_SIZE * .666;
SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_LENGTH =
    SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_SECONDARY_TEXT_SIZE
    + ENCLOSURE_ENGRAVING_GUTTER * 2;

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

    engraving_length = SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_LENGTH,
    label_gutter = ENCLOSURE_ENGRAVING_GUTTER,

    control_clearance = SWITCH_CLUTCH_CLEARANCE
) = (
    [
        width + control_clearance * 2,
        (length != undef ? length : engraving_length * 2 + label_gutter)
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
    width = 0,
    length = 0,
    depth = ENCLOSURE_ENGRAVING_DEPTH,
    label_gutter = ENCLOSURE_ENGRAVING_GUTTER,
    size = SWITCH_CLUTCH_ENCLOSURE_ENGRAVING_SECONDARY_TEXT_SIZE,
    quick_preview = true,
    position = [0, 0],
    enclosure_height = 1
) {
    e = .0931;

    module _engraving(string, i = 0) {
        placard_length = (length - label_gutter) / 2;
        ys = [
            placard_length / 2,
            placard_length / 2 + placard_length + label_gutter
        ];

        enclosure_engraving(
            string = string,
            size = size,
            chamfer = ENCLOSURE_ENGRAVING_CHAMFER / 2,
            position = [width / 2, ys[i]],
            depth = depth,
            placard = [
                width,
                placard_length
            ],
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
        label_gutter = label_gutter,
        control_clearance = control_clearance
    );

    switch_and_clutch_position = [
        wall_gutter,
        wall_gutter + label_gutter + ENCLOSURE_ENGRAVING_LENGTH
    ];

    width = 24 + wall_gutter * 2;
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

    warn_if(actuator_length > max_actuator_length, str(
        "actuator_length of ", actuator_length,
        " is more than max_actuator_length of ",
        max_actuator_length
    ));

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

    labels_position = [
        switch_and_clutch_position.x + actuator_window_dimensions.x + label_gutter,
        wall_gutter + ENCLOSURE_ENGRAVING_LENGTH + label_gutter
    ];

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
            width = width - labels_position.x - wall_gutter,
            length = length - labels_position.y - wall_gutter,
            depth = depth,
            label_gutter = label_gutter,
            size = secondary_text_size,
            quick_preview = quick_preview,
            position = labels_position,
            enclosure_height = enclosure_height
        );
    }
}
* __demo_switch_clutch_enclosure_engraving(
    wall_gutter = 2,
    switch_position = abs($t - 1 / 2) * 2,
    control_clearance = SWITCH_CLUTCH_CLEARANCE,
    tolerance = .1,
    quick_preview = 1
);
