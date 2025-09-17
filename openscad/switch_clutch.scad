include <flat_top_rectangular_pyramid.scad>;
include <rib_cavities.scad>;
include <rounded_cube.scad>;
include <switch-OS102011MS2QN1.scad>;

SWITCH_CLUTCH_MIN_BASE_WIDTH = SWITCH_BASE_WIDTH + 2;
SWITCH_CLUTCH_MIN_BASE_LENGTH = SWITCH_BASE_LENGTH + SWITCH_ACTUATOR_TRAVEL;
SWITCH_CLUTCH_MIN_BASE_HEIGHT = SWITCH_BASE_HEIGHT + 1;

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

function get_absolute_origin(
    base_width = SWITCH_CLUTCH_MIN_BASE_WIDTH,
    base_length = SWITCH_CLUTCH_MIN_BASE_LENGTH,

    switch_base_width = SWITCH_BASE_WIDTH,
    switch_base_length = SWITCH_BASE_LENGTH,

    switch_origin = SWITCH_ORIGIN,

    z = 0
) = [
    switch_origin.x - (base_width - switch_base_width) / 2,
    switch_origin.y - (base_length - switch_base_length) / 2,
    z
];

module switch_cavity(
    base_width = SWITCH_CLUTCH_MIN_BASE_WIDTH,
    base_length = SWITCH_CLUTCH_MIN_BASE_LENGTH,
    base_height = SWITCH_CLUTCH_MIN_BASE_HEIGHT,

    actuator_width = SWITCH_CLUTCH_MIN_ACTUATOR_WIDTH,
    actuator_length = SWITCH_CLUTCH_MIN_ACTUATOR_LENGTH,
    actuator_height = SWITCH_CLUTCH_MIN_ACTUATOR_HEIGHT,

    switch_origin = SWITCH_ORIGIN,

    z = 0
) {
    # switch(
        position = 0,

        base_width = base_width,
        base_length = base_length,
        base_height = base_height,

        actuator_width = actuator_width,
        actuator_length = actuator_length,
        actuator_height = actuator_height,
        actuator_travel = 0,

        origin = get_absolute_origin(
            base_width,
            base_length,
            z
        )
    );
}

module switch_clutch(
    base_width = SWITCH_CLUTCH_MIN_BASE_WIDTH,
    base_length = SWITCH_CLUTCH_MIN_BASE_LENGTH,
    base_height = SWITCH_CLUTCH_MIN_BASE_HEIGHT,

    actuator_width = SWITCH_CLUTCH_MIN_ACTUATOR_WIDTH,
    actuator_length = SWITCH_CLUTCH_MIN_ACTUATOR_LENGTH,
    actuator_height = SWITCH_CLUTCH_MIN_ACTUATOR_HEIGHT,

    position = 0,

    switch_base_width = SWITCH_BASE_WIDTH,
    switch_base_length = SWITCH_BASE_LENGTH,
    switch_base_height = SWITCH_BASE_HEIGHT,

    switch_actuator_width = SWITCH_ACTUATOR_WIDTH,
    switch_actuator_length = SWITCH_ACTUATOR_LENGTH,
    switch_actuator_height = SWITCH_ACTUATOR_HEIGHT,
    switch_actuator_travel = SWITCH_ACTUATOR_TRAVEL,

    switch_origin = SWITCH_ORIGIN,

    fillet = 0,

    color = undef,
    cavity_color = undef,

    debug = false,

    show_dfm = true,

    clearance = 0,
    tolerance = .1
) {
    e = .0193;

    gutter = clearance + tolerance;

    y = switch_actuator_travel / 2 - switch_actuator_travel * (1 - position);

    module _outer() {
        color(cavity_color) {
            translate(get_absolute_origin(
                base_width = base_width,
                base_length = base_length,
                switch_base_width = switch_base_width,
                switch_base_length = switch_base_length,
                switch_origin = switch_origin
            )) {
                cube([base_width, base_length, base_height]);
            }
        }

        color(color) {
            translate(get_absolute_origin(
                base_width = actuator_width,
                base_length = actuator_length,
                switch_base_width = switch_base_width,
                switch_base_length = switch_base_length,
                switch_origin = switch_origin,
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
        cavity_width = switch_base_width + gutter * 2;
        cavity_length = base_length + e * 2;

        switch_cavity(
            base_width = cavity_width,
            base_length = cavity_length,
            base_height = switch_base_height + e,

            actuator_width = cavity_width,
            actuator_length = switch_actuator_length + gutter * 2,
            actuator_height = switch_actuator_height,

            switch_origin = switch_origin,

            z = -e
        );

        if (show_dfm) {
            translate(get_absolute_origin(
                base_width = cavity_width,
                base_length = cavity_length,
                switch_base_width = switch_base_width,
                switch_base_length = switch_base_length,
                switch_origin = switch_origin,
                z = switch_base_height - e
            )) {
                flat_top_rectangular_pyramid(
                    top_width = 0,
                    top_length = cavity_length,
                    bottom_width = cavity_width,
                    bottom_length = cavity_length,
                    height = cavity_width / 3
                );
            }
        }
    }

    module _rib_cavities(depth = DEFAULT_RIB_SIZE) {
        origin = get_absolute_origin(
            base_width = actuator_width,
            base_length = actuator_length,
            switch_base_width = switch_base_width,
            switch_base_length = switch_base_length,
            switch_origin = switch_origin
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

    translate([0, y, 0]) {
        difference() {
            _outer();

            color(cavity_color) {
                _cavity();
                _rib_cavities();
            }

            if (debug) {
                translate([
                    0,
                    get_absolute_origin(
                        base_width = base_width,
                        base_length = base_length,
                        switch_base_width = switch_base_width,
                        switch_base_length = switch_base_length,
                        switch_origin = switch_origin
                    ).y - e,
                    -e
                ]) {
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

for (i = [0 : 2]) {
    translate([0, 22 * i, 0]) {
        switch_clutch(
            // base_height = 6,
            // base_width = SWITCH_BASE_WIDTH + .01,
            base_length = 20,

            // actuator_width = SWITCH_BASE_WIDTH + .01,
            // actuator_length = 10,
            // actuator_height = 4,

            debug = 0,

            fillet = 1, $fn = 6,

            position = i == 2 ? round($t) : i,

            color = "#FFFFFF",
            cavity_color = "#EEEEEE",

            // clearance = .6,
            // tolerance = .1,

            show_dfm = false
        );

        * # translate([0, 0, -.01]) switch(i == 2 ? round($t) : i);
    }
}