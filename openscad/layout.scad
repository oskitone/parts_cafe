include <../../parts_cafe/openscad/enclosure_engraving.scad>;

HORIZONTAL = "horizontal";
VERTICAL = "vertical";

LOREM_IPSUM = ["LOREM","IPSUM", "DOLOR", "SIT", "AMET", "CONSECTETUR", "ADIPISCING", "ELIT", "SED", "DO", "EIUSMOD", "TEMPOR", "INCIDIDUNT", "UT", "LABORE", "ET", "DOLORE", "MAGNA", "ALIQUA"];

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

function get_knob_and_label_array_length(
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

module knob_and_label(
    string = "",
    position = [0, 0],

    knob_diameter = 20,

    label_length = 5,
    label_gutter = 2.5,

    label_text_size = 3.2,

    knob_height = 1
) {
    radius = knob_diameter / 2;

    translate([
        position.x + radius,
        position.y + label_length + label_gutter + radius,
        0
    ]) {
        cylinder(
            d = knob_diameter,
            h = knob_height
        );
    }

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

module knob_and_label_array(
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

    debug = false
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

    function get_label(i) = (
        let(
            _i = direction == HORIZONTAL
                ? i % _count
                : _count - 1 - i % _count
        )

        labels[(label_i_offset + _i) % len(labels)]
    );

    for (i = [0 : _count - 1]) {
        _position = direction == HORIZONTAL
            ? [i * (knob_diameter + gutter), 0]
            : [0, i * (label_length + label_gutter + knob_diameter + gutter)];

        knob_and_label(
            string = get_label(i),
            position = [
                position.x + _position.x,
                position.y + _position.y
            ],
            knob_diameter = knob_diameter
        );
    }

    if (debug) {
        width = direction == HORIZONTAL
            ? available_area != undef
                ? available_area
                : knob_diameter * count + gutter * (count - 1)
            : knob_diameter;
        length = get_knob_and_label_array_length(
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

    enclosure_height = 1,

    label_length = 5, // SCOUT_LABEL_LENGTH
    label_gutter = 2.5, // SCOUT_GUTTER / 2

    label_text_size = 3.2, // SCOUT_LABEL_TEXT_SIZE

    gutter = 5 // TODO: get SCOUT_GUTTER
) {
    direction = columns != undef
        ? VERTICAL
        : HORIZONTAL;
    stack = direction == VERTICAL ? columns : rows;

    big_knob_diameter = 50;

    SCOUT_KNOB_DIAMETER = 20; // TODO: use
    APC_WHEEL_DIAMETER = 25.58; // TODO: use
    minimum_knob_diameter = 10; // TODO: use

    available_area = direction == VERTICAL
        ? get_knob_and_label_array_length(
            knob_diameter = big_knob_diameter,
            count = stack[0]
        )
        : big_knob_diameter * stack[0] + gutter * (stack[0] - 1);

    module _array(
        count,
        knob_diameter = undef,
        position = [0, 0],
        available_area = undef,
        label_i_offset = 0
    ) {
        knob_and_label_array(
            count = count,

            label_i_offset = label_i_offset,

            available_area = available_area,

            direction = direction,

            position = position,

            knob_diameter = knob_diameter,

            label_length = label_length,
            label_gutter = label_gutter,

            label_text_size = label_text_size,

            gutter = gutter
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
            sum = 0, i = 0;
            i < len(stack) - 1;
            sum = direction == VERTICAL
                ? (sum + _get_column_width(i))
                : 0, i = i + 1
        ) (
            direction == VERTICAL
                ? (sum + _get_column_width(i))
                : 0
        )
    ];

    function get_row_y(i) = (
        get_knob_and_label_array_length(
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
            sum = 0, i = 0;
            i < len(stack) - 1;
            sum = sum + get_row_y(i), i = i + 1
        ) (
            sum + get_row_y(i)
        )
    ];

    /* echo("column_xs", column_xs); */
    /* echo("row_ys", row_ys); */

    stack_is = [
        for (
            sum = 0, i = 0;
            i < len(stack);
            sum = sum + stack[i], i = i + 1
        ) (
            sum + stack[i]
        )
    ];

    _array(
        count = stack[0],
        knob_diameter = big_knob_diameter,
        label_i_offset = 0
    );

    for (i = [1 : len(stack) - 1]) {
        position = direction == HORIZONTAL
            ? [0, row_ys[i - 1] + (gutter * i)]
            : [column_xs[i - 1] + (gutter * i), 0];

        _array(
            count = stack[i],
            position = position,
            label_i_offset = stack_is[i - 1],
            available_area = available_area
        );
    }
}

layout(
    /* columns = [1,2,3,5], */
    rows = [2,4,1,3],
    gutter = 5
);
