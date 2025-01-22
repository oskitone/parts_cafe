include <battery_holder.scad>;
include <enclosure.scad>;

BATTERY_HOLDER_FIXTURE_HITCH_WIDTH = AAA_BATTERY_LENGTH / 2;

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

module battery_holder_fixtures(
    include_left_side_aligner = true,
    include_right_side_aligner = true,
    include_back_hitch = true,
    include_front_nub = true,

    web_width = ENCLOSURE_INNER_WALL,
    web_length = 10,
    web_height = 10,

    hitch_width = BATTERY_HOLDER_FIXTURE_HITCH_WIDTH,
    hitch_length = ENCLOSURE_WALL,

    side_aligner_width = ENCLOSURE_INNER_WALL,
    side_aligner_clearance = .2,

    battery_holder_wall = ENCLOSURE_INNER_WALL,
    battery_holder_floor = BATTERY_HOLDER_DEFAULT_FLOOR,

    battery_holder_position = [0,0,0],

    tolerance = 0
) {
    e = .0419;

    battery_holder_dimensions = get_battery_holder_dimensions(
        count = 2,
        tolerance = tolerance,
        wall = battery_holder_wall,
        floor = battery_holder_floor
    );

    module _nub(y) {
        _width = BATTERY_HOLDER_NUB_FIXTURE_WIDTH - tolerance * 2;
        _length = BATTERY_HOLDER_NUB_FIXTURE_DEPTH;
        _height = BATTERY_HOLDER_NUB_FIXTURE_HEIGHT - tolerance * 2;

        x = battery_holder_position.x
            + (battery_holder_dimensions.x - _width) / 2;
        z = ENCLOSURE_FLOOR_CEILING + BATTERY_HOLDER_NUB_FIXTURE_Z
            + tolerance;

        translate([x, y - e, z]) {
            cube([_width, _length + e, _height]);
        }
    }

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

    module _back_hitch() {
        height = battery_holder_floor + AAA_BATTERY_DIAMETER;

        position = get_battery_holder_back_hitch_position(
            battery_holder_position = battery_holder_position,
            battery_holder_dimensions = battery_holder_dimensions,
            hitch_width = hitch_width,
            tolerance = tolerance
        );

        translate([position.x, position.y, ENCLOSURE_FLOOR_CEILING - e]) {
            cube([hitch_width, hitch_length, height + e]);
        }

        _nub(position.y - BATTERY_HOLDER_NUB_FIXTURE_DEPTH + e);

        for (x = [position.x, position.x + hitch_width - web_width]) {
            translate([
                x,
                position.y + hitch_length - e,
                ENCLOSURE_FLOOR_CEILING - e
            ]) {
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

    if (include_front_nub) {
        _nub(battery_holder_position.y - 0 - tolerance * 1);
    }

    if (include_left_side_aligner) {
        _side_aligner(-side_aligner_width - side_aligner_clearance - tolerance);
    }

    if (include_right_side_aligner) {
        _side_aligner(side_aligner_clearance + battery_holder_dimensions.x);
    }

    if (include_back_hitch) {
        _back_hitch();
    }
}
