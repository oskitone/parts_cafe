include <battery_holder.scad>;
include <enclosure.scad>;

BATTERY_HOLDER_FIXTURE_HITCH_WIDTH = AAA_BATTERY_LENGTH / 2;
BATTERY_HOLDER_FIXTURE_HITCH_LENGTH = ENCLOSURE_WALL;

BATTERY_HOLDER_FIXTURE_HITCH_WEB_WIDTH = ENCLOSURE_INNER_WALL;
BATTERY_HOLDER_FIXTURE_HITCH_WEB_LENGTH = AAA_BATTERY_DIAMETER;
BATTERY_HOLDER_FIXTURE_HITCH_WEB_HEIGHT = 0;

function get_battery_holder_back_hitch_position(
    battery_holder_position = [0,0,0],
    battery_holder_dimensions = [0,0,0],

    hitch_width = BATTERY_HOLDER_FIXTURE_HITCH_WIDTH,
    tolerance = 0
) = [
    battery_holder_position.x
        + (battery_holder_dimensions.x - hitch_width) / 2,
    battery_holder_position.y
        + tolerance * 2
        + battery_holder_dimensions.y
];

module battery_holder_fixture_nub(tolerance = 0) {
    e = .0251;

    cube([
        BATTERY_HOLDER_NUB_FIXTURE_WIDTH - tolerance * 2,
        BATTERY_HOLDER_NUB_FIXTURE_DEPTH + e,
        BATTERY_HOLDER_NUB_FIXTURE_HEIGHT - tolerance * 2
    ]);
}

module battery_holder_hitch(
    tolerance = 0,

    z = ENCLOSURE_FLOOR_CEILING,

    width = BATTERY_HOLDER_FIXTURE_HITCH_WIDTH,
    length = BATTERY_HOLDER_FIXTURE_HITCH_LENGTH,
    height = BATTERY_HOLDER_DEFAULT_FLOOR + AAA_BATTERY_DIAMETER,

    web_width = BATTERY_HOLDER_FIXTURE_HITCH_WEB_WIDTH,
    web_length = BATTERY_HOLDER_FIXTURE_HITCH_WEB_LENGTH,
    web_height = BATTERY_HOLDER_FIXTURE_HITCH_WEB_HEIGHT
) {
    e = .0151;

    translate([0, 0, z - e]) {
        cube([width, length, height + e]);
    }

    translate([
        tolerance + (width - BATTERY_HOLDER_NUB_FIXTURE_WIDTH) / 2,
        -BATTERY_HOLDER_NUB_FIXTURE_DEPTH,
        z + BATTERY_HOLDER_NUB_FIXTURE_Z + tolerance
    ]) {
        battery_holder_fixture_nub(tolerance);
    }

    for (x = [0, 0 + width - web_width]) {
        translate([x, length - e, z - e]) {
            hull() {
                cube([web_width, web_length + e, e]);

                translate([0, 0, web_height]) {
                    cube([web_width, web_length + e, e]);
                }

                translate([0, 0, height - e]) {
                    cube([web_width, e, e]);
                }
            }
        }
    }
}

module battery_holder_hitches(
    tolerance = 0,

    battery_holder_position = [0,0,0],
    battery_holder_dimensions = [0,0,0],

    hitch_width = BATTERY_HOLDER_FIXTURE_HITCH_WIDTH,
    hitch_length = BATTERY_HOLDER_FIXTURE_HITCH_LENGTH,
    hitch_height = BATTERY_HOLDER_DEFAULT_FLOOR + AAA_BATTERY_DIAMETER,

    web_width = BATTERY_HOLDER_FIXTURE_HITCH_WEB_WIDTH,
    web_length = BATTERY_HOLDER_FIXTURE_HITCH_WEB_LENGTH,
    web_height = BATTERY_HOLDER_FIXTURE_HITCH_WEB_HEIGHT
) {
    e = .004;

    module _hitch() {
        battery_holder_hitch(
            tolerance = tolerance,

            z = battery_holder_position.z - e,

            width = hitch_width,
            length = hitch_length,
            height = hitch_height,

            web_width = web_width,
            web_length = web_length,
            web_height = web_height
        );
    }

    translate([
        battery_holder_position.x
            + (battery_holder_dimensions.x - hitch_width) / 2,
        battery_holder_position.y - hitch_length - tolerance * 2,
        0
    ]) {
        mirror([0, 1, 0]) translate([0, -hitch_length, 0]) {
            _hitch();
        }
    }

    translate(
        get_battery_holder_back_hitch_position(
            battery_holder_position = battery_holder_position,
            battery_holder_dimensions = battery_holder_dimensions,
            hitch_width = hitch_width,
            tolerance = tolerance
        )
    ) {
        _hitch();
    }
}

module battery_holder_enclosure_fixtures(
    battery_holder_dimensions = undef,
    battery_count = 3,

    include_left_side_aligner = true,
    include_right_side_aligner = true,
    include_back_hitch = true,
    include_front_nub = true,

    web_width = BATTERY_HOLDER_FIXTURE_HITCH_WEB_WIDTH,
    web_length = BATTERY_HOLDER_FIXTURE_HITCH_WEB_LENGTH,
    web_height = BATTERY_HOLDER_FIXTURE_HITCH_WEB_HEIGHT,

    hitch_width = BATTERY_HOLDER_FIXTURE_HITCH_WIDTH,
    hitch_length = BATTERY_HOLDER_FIXTURE_HITCH_LENGTH,

    side_aligner_width = ENCLOSURE_INNER_WALL,
    side_aligner_clearance = .2,

    battery_holder_wall = ENCLOSURE_INNER_WALL,
    battery_holder_floor = BATTERY_HOLDER_DEFAULT_FLOOR,

    battery_holder_position = [0,0,0],

    tolerance = 0
) {
    e = .0419;

    battery_holder_dimensions = battery_holder_dimensions
        ? battery_holder_dimensions
        : get_battery_holder_dimensions(
            count = battery_count,
            tolerance = tolerance,
            wall = battery_holder_wall,
            floor = battery_holder_floor
        );

    module _side_aligner(x) {
        length = battery_holder_wall
            + (AAA_BATTERY_DIAMETER - KEYSTONE_5204_5226_TAB_WIDTH) / 2;
        height = length;

        translate([
            x + battery_holder_position.x,
            ENCLOSURE_WALL - e,
            ENCLOSURE_FLOOR_CEILING - e
        ]) {
            flat_top_rectangular_pyramid(
                top_width = side_aligner_width,
                top_length = 0,
                bottom_width = side_aligner_width,
                bottom_length = length + e,
                height = height + e,
                top_weight_y = 0
            );
        }
    }

    if (include_front_nub) {
        _width = BATTERY_HOLDER_NUB_FIXTURE_WIDTH - tolerance * 2;

        x = battery_holder_position.x
            + (battery_holder_dimensions.x - _width) / 2;
        z = ENCLOSURE_FLOOR_CEILING + BATTERY_HOLDER_NUB_FIXTURE_Z
            + tolerance;

        translate([x, battery_holder_position.y - tolerance * 2 - e, z]) {
            battery_holder_fixture_nub(tolerance);
        }
    }

    if (include_left_side_aligner) {
        _side_aligner(-side_aligner_width - side_aligner_clearance - tolerance);
    }

    if (include_right_side_aligner) {
        _side_aligner(side_aligner_clearance + battery_holder_dimensions.x);
    }

    if (include_back_hitch) {
        translate(
            get_battery_holder_back_hitch_position(
                battery_holder_position = battery_holder_position,
                battery_holder_dimensions = battery_holder_dimensions,
                hitch_width = hitch_width,
                tolerance = tolerance
            )
        ) {
            battery_holder_hitch(
                tolerance = tolerance,

                z = battery_holder_position.z - e,

                width = hitch_width,
                length = hitch_length,
                height = battery_holder_floor + AAA_BATTERY_DIAMETER,

                web_width = web_width,
                web_length = web_length,
                web_height = web_height
            );
        }
    }
}
