include <flat_top_rectangular_pyramid.scad>;
include <rib_cavities.scad>;
include <rounded_cube.scad>;
include <switch-OS102011MS2QN1.scad>;

SWITCH_CLUTCH_MIN_BASE_HEIGHT = SWITCH_BASE_HEIGHT + 1;
SWITCH_CLUTCH_MIN_BASE_WIDTH = SWITCH_BASE_WIDTH + 2;
SWITCH_CLUTCH_MIN_BASE_LENGTH = SWITCH_BASE_LENGTH + SWITCH_ACTUATOR_TRAVEL;

SWITCH_CLUTCH_MIN_ACTUATOR_WIDTH = SWITCH_CLUTCH_MIN_BASE_WIDTH;
SWITCH_CLUTCH_MIN_ACTUATOR_LENGTH = SWITCH_ACTUATOR_LENGTH + 2;
SWITCH_CLUTCH_MIN_ACTUATOR_HEIGHT = SWITCH_ACTUATOR_HEIGHT;

function get_max_switch_clutch_actuator_length(
    actuator_window_length =
        SWITCH_CLUTCH_MIN_ACTUATOR_LENGTH + SWITCH_ACTUATOR_TRAVEL,
    control_clearance = 0,
    tolerance = 0
) = (
    actuator_window_length
        - SWITCH_ACTUATOR_TRAVEL
        - (control_clearance + tolerance) * 2
);

module switch_clutch(
    base_height = SWITCH_CLUTCH_MIN_BASE_HEIGHT,
    base_width = SWITCH_CLUTCH_MIN_BASE_WIDTH,
    base_length = SWITCH_CLUTCH_MIN_BASE_LENGTH,

    actuator_width = SWITCH_CLUTCH_MIN_ACTUATOR_WIDTH,
    actuator_length = SWITCH_CLUTCH_MIN_ACTUATOR_LENGTH,
    actuator_height = SWITCH_CLUTCH_MIN_ACTUATOR_HEIGHT,

    position = 0,

    cavity_base_width = SWITCH_BASE_WIDTH,
    cavity_base_length = SWITCH_BASE_LENGTH,
    cavity_base_height = SWITCH_BASE_HEIGHT,

    cavity_actuator_width = SWITCH_ACTUATOR_WIDTH,
    cavity_actuator_length = SWITCH_ACTUATOR_LENGTH,
    cavity_actuator_height = SWITCH_ACTUATOR_HEIGHT,
    cavity_actuator_travel = SWITCH_ACTUATOR_TRAVEL,

    switch_base_width = SWITCH_BASE_WIDTH,
    switch_base_length = SWITCH_BASE_LENGTH,
    switch_origin = SWITCH_ORIGIN,

    fillet = 0,

    color = undef,
    cavity_color = undef,

    debug = false,

    chamfer_cavity_top = true, // for DFM when printed standing up

    clearance = 0,
    tolerance = .1
) {
    e = .0193;

    gutter = clearance + tolerance;

    function get_absolute_origin(
        _base_width = base_width,
        _base_length = base_length,
        z = 0
    ) = [
        switch_origin.x - (_base_width - switch_base_width) / 2,
        switch_origin.y - (_base_length - switch_base_length) / 2,
        z
    ];

    module _switch(
        base_width = 0,
        base_length = 0,
        base_height = 0,

        actuator_width = 0,
        actuator_length = 0,
        actuator_height = 0,

        z = 0
    ) {
        switch(
            position = 0,

            base_width = base_width,
            base_length = base_length,
            base_height = base_height,

            actuator_width = actuator_width,
            actuator_length = actuator_length,
            actuator_height = actuator_height,
            actuator_travel = 0,

            origin = get_absolute_origin(base_width, base_length, z)
        );
    }

    module _outer() {
        color(cavity_color) {
            translate(get_absolute_origin()) {
                cube([base_width, base_length, base_height]);
            }
        }

        color(color) {
            translate(get_absolute_origin(
                actuator_width,
                actuator_length,
                z = base_height - fillet - e
            )) {
                rounded_cube(
                    [actuator_width, actuator_length, actuator_height + fillet + e],
                    fillet
                );
            }
        }
    }

    module _cavity() {
        width = cavity_base_width + gutter * 2;
        length = cavity_base_length + gutter * 2
            + cavity_actuator_travel;

        _switch(
            base_width = width,
            base_length = length,
            base_height = cavity_base_height + e,

            actuator_width = cavity_actuator_width + gutter * 2,
            actuator_length = cavity_actuator_length + gutter * 2,
            actuator_height = cavity_actuator_height,

            z = -e
        );

        if (chamfer_cavity_top) {
            translate(get_absolute_origin(
                width,
                length,
                cavity_base_height - e
            )) {
                flat_top_rectangular_pyramid(
                    top_width = 0,
                    top_length = length,
                    bottom_width = width,
                    bottom_length = length,
                    height = width / 3
                );
            }
        }
    }

    module _rib_cavities(depth = DEFAULT_RIB_SIZE) {
        origin = get_absolute_origin(
            _base_width = actuator_width,
            _base_length = actuator_length
        );

        translate([
            origin.x,
            origin.y,
            base_height + actuator_height - depth
        ]) {
            rib_cavities(
                width = actuator_width,
                length = actuator_length,
                depth = depth
            );
        }
    }

    translate([
        0,
        cavity_actuator_travel / 2 - cavity_actuator_travel * (1 - position),
        0
    ]) {
        difference() {
            _outer();

            color(cavity_color) {
                _cavity();
                _rib_cavities();
            }

            if (debug) {
                translate([0, get_absolute_origin().y - e, -e]) {
                    color(cavity_color) {
                        cube([
                            base_width / 2 + e,
                            base_length + e * 2,
                            base_height + actuator_height + e * 2
                        ]);
                    }
                }
            }
        }
    }
}

* for (i = [0 : 2]) {
    translate([0, 14 * i, 0]) {
        switch_clutch(
            base_height = 7,
            base_width = 15,
            base_length = 12,

            actuator_width = 10,
            actuator_length = 10,
            actuator_height = 4,

            position = i == 2 ? round($t) : i,

            // Uncomment either (but not both!) of these to demo
            // full width/length cavities:
            // cavity_base_width = 100, chamfer_cavity_top = 0,
            // cavity_base_length = 100,

            fillet = 1, $fn = 6,

            color = "#FFFFFF",
            cavity_color = "#EEEEEE",

            debug = true,

            clearance = 0,
            tolerance = .1
        );

        # translate([0,0,-.01]) switch(i == 2 ? round($t) : i);
    }
}