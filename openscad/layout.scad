include <enclosure_engraving.scad>;
include <rounded_cube.scad>;
include <switch_clutch_enclosure_engraving.scad>;
include <wheel.scad>;

HORIZONTAL = "horizontal";
VERTICAL = "vertical";

LOREM_IPSUM = ["LOREM","IPSUM", "DOLOR", "SIT", "AMET", "CONSECTETUR", "ADIPISCING", "ELIT", "SED", "DO", "EIUSMOD", "TEMPOR", "INCIDIDUNT", "UT", "LABORE", "ET", "DOLORE", "MAGNA", "ALIQUA"];

function slice(list, start = 0, end) =
    end == 0
        ? []
        : [
            for (i = [start : (end == undef ? len(list) : end) - 1]) (
                list[i]
            )
        ]
;


function substr(string, length, start = 0) = (
    let(split = slice(string, start, min(len(string), start + length)))
    let(cumulative_join = [
        for (
            output = "", i = 0;
            i < len(split);
            output = str(output, split[i]), i = i + 1) (
                str(output, split[i])
            )
    ])

    cumulative_join[len(cumulative_join) - 1]
);

function reverse(list) = [for (i = [len(list)-1:-1:0]) list[i]];

function get_knob_diameter_from_available_length(
    available_length,

    count = 1,

    label_length = 5,
    label_gutter = 2.5,

    gutter = 5
) = (
    (available_length
        - (label_length + label_gutter) * count
        - gutter * (count - 1)
    ) / count
);

function get_control_array_length(
    knob_diameter = 20,
    count = 2,

    label_length = 5,
    label_gutter = 2.5,

    gutter = 5
) = (
    (knob_diameter + label_gutter + label_length) * count
    + gutter * (count - 1)
);

function get_column_width(
    available_area,

    i = 0,

    columns = [],

    label_length = 5,
    label_gutter = 2.5,

    gutter = 5
) = (
    get_knob_diameter_from_available_length(
        available_area,
        count = columns[i],
        label_length = label_length,
        label_gutter = label_gutter,
        gutter = gutter
    )
);

function get_row_length(
    available_area,

    i = 0,

    rows = [],

    label_length = 5,
    label_gutter = 2.5,

    gutter = 5 // needed?
) = (
    0
);

module control_and_label(
    is_knob = true,

    string = "",
    position = [0, 0],

    knob_diameter = 20, // aka width

    label_length = 5,
    label_gutter = 2.5,

    label_text_size = 3.2,

    knob_height = 10,

    quick_preview = false
) {
    radius = knob_diameter / 2;

    module _knob() {
        if (quick_preview) {
            color("#fff") {
                cylinder(
                    d = knob_diameter,
                    h = knob_height
                );
            }
        } else {
            wheel(
                diameter = knob_diameter,
                height = knob_height,

                spokes_count = 0,
                brodie_knob_count = 0,
                dimple_count = 1,

                round_bottom = false,

                color = "#fff",
                cavity_color = "#ccc"
            );
        }
    }

    module _switch() {
        * # cube([knob_diameter, knob_diameter, 10]);

        actuator_width = max(
            SWITCH_CLUTCH_MIN_ACTUATOR_WIDTH,
            (knob_diameter - label_gutter * (2 - 1)) / 2
        );
        actuator_window_dimensions = get_actuator_window_dimensions(
            width = actuator_width,
            control_clearance = 0
        );

        module _window() {
            # actuator_window(actuator_window_dimensions);
        }

        module _clutch() {
            translate([
                actuator_width / 2,
                -SWITCH_ORIGIN.y
                    - SWITCH_CLUTCH_MIN_BASE_LENGTH / 2
                    + SWITCH_CLUTCH_MIN_ACTUATOR_LENGTH / 2
                    + SWITCH_ACTUATOR_TRAVEL,
                -SWITCH_CLUTCH_MIN_BASE_HEIGHT
            ]) {
                switch_clutch(
                    base_width = actuator_width,
                    actuator_width = actuator_width,
                    position = 0,
                    fillet = 1, $fn = 12,
                    color = "#fff",
                    cavity_color = "#ccc"
                );
            }
        }

        module _labels() {
            switch_clutch_enclosure_engraving(
                labels = ["NO", "YES"],
                actuator_window_dimensions = actuator_window_dimensions,
                control_clearance = 0,
                quick_preview = true,
                enclosure_height = 1
            );
        }

        _window();
        _clutch();
        _labels();
    }

    module _label() {
        color("#fff") {
            enclosure_engraving(
                string = string,
                size = label_text_size,
                position = [
                    position.x + radius,
                    position.y + label_length / 2
                ],
                placard = [knob_diameter, label_length]
            );
        }

        translate([position.x, position.y, 0]) {
            color("#ccc") {
                cube([knob_diameter, label_length, .1]);
            }
        }
    }

    x = position.x
        + (is_knob ? radius : 0);
    y = position.y + label_length + label_gutter
        + (is_knob ? radius : 0);

    translate([x, y, 0]) {
        if (is_knob) {
            _knob();
        } else {
            _switch();
        }
    }

    _label();
}

module control_array(
    labels = LOREM_IPSUM,
    count = undef,

    label_i_offset = 0,

    available_area = undef,

    direction = HORIZONTAL,

    position = [0, 0],

    knob_diameter = 20,

    label_length = 5,
    label_gutter = 2.5,

    label_text_size = 3.2,

    gutter = 5,

    debug = false,
    quick_preview = true
) {
    _count = count != undef ? count : len(labels);

    knob_diameter = available_area != undef
        ? direction == VERTICAL
            ? get_knob_diameter_from_available_length(
                available_area,
                count = _count,
                label_length = label_length,
                label_gutter = label_gutter,
                gutter = gutter
            )
            : (available_area - gutter * (_count - 1)) / count
        : knob_diameter;

    function get_label(
        i = 0,
        character_truncate = 100
    ) = (
        let(
            _i = direction == HORIZONTAL
                ? i % _count
                : _count - 1 - i % _count
        )

        substr(
            labels[(label_i_offset + _i) % len(labels)],
            character_truncate
        )
    );

    for (i = [0 : _count - 1]) {
        _position = direction == HORIZONTAL
            ? [i * (knob_diameter + gutter), 0]
            : [0, i * (label_length + label_gutter + knob_diameter + gutter)];

        is_switch = (
            (i + label_i_offset) % 2 == 0)
            && knob_diameter > 18
        ;
        is_knob = !is_switch;

        label = get_label(i, round(knob_diameter / label_length));

        control_and_label(
            is_knob = is_knob,
            string = label,
            position = [
                position.x + _position.x,
                position.y + _position.y
            ],
            knob_diameter = knob_diameter,
            quick_preview = quick_preview
        );
    }

    if (debug) {
        width = direction == HORIZONTAL
            ? available_area != undef
                ? available_area
                : knob_diameter * count + gutter * (count - 1)
            : knob_diameter;
        length = get_control_array_length(
            knob_diameter = knob_diameter,
            count = direction == HORIZONTAL ? 1 : count,

            label_length = label_length,
            label_gutter = label_gutter,

            gutter = gutter
        );

        translate([position.x, position.y, -.01]) {
            # cube([width, length, .11]);
        }
    }
}

module layout(
    columns = undef,
    rows = undef,

    available_area = 100,

    enclosure_height = 25,
    enclosure_fillet = 2,

    label_length = 5, // SCOUT_LABEL_LENGTH
    label_gutter = 2.5, // SCOUT_GUTTER / 2

    label_text_size = 3.2, // SCOUT_LABEL_TEXT_SIZE

    gutter = 5, // TODO: get SCOUT_GUTTER

    outer_gutter = 5,

    quick_preview = true
) {
    e = .01;

    control_and_label_direction = columns != undef
        ? VERTICAL
        : HORIZONTAL;
    stack = control_and_label_direction == VERTICAL ? columns : reverse(rows);

    big_knob_diameter = 50;

    SCOUT_KNOB_DIAMETER = 20; // TODO: use
    APC_WHEEL_DIAMETER = 25.58; // TODO: use
    minimum_knob_diameter = 10; // TODO: use

    module _array(
        count,
        knob_diameter = undef,
        position = [0, 0],
        available_area = undef,
        label_i_offset = 0
    ) {
        control_array(
            count = count,

            label_i_offset = label_i_offset,

            available_area = available_area,

            direction = control_and_label_direction,

            position = position,

            knob_diameter = knob_diameter,

            label_length = label_length,
            label_gutter = label_gutter,

            label_text_size = label_text_size,

            gutter = gutter,

            quick_preview = quick_preview
        );
    }

    function _get_column_width(i) = get_column_width(
        available_area = available_area,

        i = i,

        columns = columns,

        label_length = label_length,
        label_gutter = label_gutter,

        gutter = gutter
    );

    column_xs = [
        for (
            sum = 0, i = -1;
            i < len(stack);
            sum = control_and_label_direction == VERTICAL
                ? (i < 0 ? 0 : sum + _get_column_width(i) + gutter)
                : 0, i = i + 1
        ) (
            control_and_label_direction == VERTICAL
                ? (i < 0 ? 0 : sum + _get_column_width(i) + gutter)
                : 0
        )
    ];

    function get_row_y(i) = (
        get_control_array_length(
            knob_diameter = get_knob_diameter_from_available_length(
                available_area,
                count = stack[i],
                label_length = label_length,
                label_gutter = label_gutter,
                gutter = gutter
            ),
            count = 1,
            label_length = label_length,
            label_gutter = label_gutter,
            gutter = gutter
        ) + label_length + label_gutter
    );

    row_ys = [
        for (
            sum = 0, i = -1;
            i < len(stack);
            sum = i < 0 ? 0 : sum + get_row_y(i) + gutter, i = i + 1
        ) (
            i < 0 ? 0 : sum + get_row_y(i) + gutter
        )
    ];

    stack_is = [
        for (
            sum = 0, i = -1;
            i < len(stack);
            sum = i < 0 ? 0 : sum + stack[i], i = i + 1
        ) (
            i < 0 ? 0 : sum + stack[i]
        )
    ];

    module _control_arrays() {
        for (i = [0 : len(stack) - 1]) {
            _i = control_and_label_direction == HORIZONTAL
                ? len(stack) - 1 - i
                : i;

            position = control_and_label_direction == HORIZONTAL
                ? [0, row_ys[_i]]
                : [column_xs[_i], 0];

            _array(
                count = stack[_i],
                position = position,
                label_i_offset = stack_is[i],
                available_area = available_area
            );
        }
    }

    gutter_bump = outer_gutter * 2 - gutter;
    width = control_and_label_direction == HORIZONTAL
        ? available_area + outer_gutter * 2
        : column_xs[len(column_xs) - 1] + gutter_bump;
    length = control_and_label_direction == HORIZONTAL
        ? row_ys[len(row_ys) - 1] + gutter_bump
        : available_area + outer_gutter * 2;

    module _enclosure() {
        rounded_cube(
            [width, length, enclosure_height],
            quick_preview ? 0 : enclosure_fillet
        );
    }

    translate([width / -2, length / -2, 0]) {
        translate([outer_gutter, outer_gutter, enclosure_height - e]) {
            _control_arrays();
        }

        color("#FF69B4") {
            _enclosure();
        }
    }
}

/* $vpr = [30, 0, -20];
$vpt = [0,0,8];
$vpd = 500;
$vpf = 18; */

layouts = [
    // [columns, rows, available_area]
    [[2,4,3], undef, 100],
    [undef, [3,4,2], 80],
    [[1,2,3], undef, 70],
    [undef, [3,2,1], 50],
    [[4,4,4,4,4], undef, 100],
    [undef, [1,5], 80],
];

layout = layouts[0];

layout(
    columns = layout[0],
    rows = layout[1],

    available_area = layout[2],

    gutter = 5,
    outer_gutter = 5,

    quick_preview = true
);
