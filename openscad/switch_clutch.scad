include <../../parts_cafe/openscad/rib_cavities.scad>;

include <switch.scad>;

module switch_clutch(
    // TODO: base_width and base_length
    base_height = SWITCH_BASE_HEIGHT + 1,

    actuator_width = SWITCH_ACTUATOR_WIDTH + 2,
    actuator_length = SWITCH_ACTUATOR_LENGTH + 2,
    actuator_height = SWITCH_ACTUATOR_HEIGHT + 2,

    position = 0,

    switch_base_width = SWITCH_BASE_WIDTH,
    switch_base_length = SWITCH_BASE_LENGTH,
    switch_base_height = SWITCH_BASE_HEIGHT,

    switch_actuator_width = SWITCH_ACTUATOR_WIDTH,
    switch_actuator_length = SWITCH_ACTUATOR_LENGTH,
    switch_actuator_height = SWITCH_ACTUATOR_HEIGHT,
    switch_actuator_travel = SWITCH_ACTUATOR_TRAVEL,

    switch_origin = SWITCH_ORIGIN,

    coverage = 1,
    wall = 1,

    debug = false,

    clearance = 0,
    tolerance = .1
) {
    e = .0193;

    gutter = clearance + tolerance;

    // TODO: use derivations if unprovided
    base_width = switch_base_width + gutter * 2 + wall * 2;
    base_length = switch_base_length + switch_actuator_travel + coverage * 2;

    y = switch_actuator_travel / 2 - switch_actuator_travel * (1 - position);

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
        _switch(
            base_width = base_width,
            base_length = base_length,
            base_height = base_height,

            actuator_width = actuator_width,
            actuator_length = actuator_length,
            actuator_height = actuator_height
        );
    }

    module _cavity() {
        width = switch_base_width + gutter * 2;

        _switch(
            base_width = width,
            base_length = switch_base_length + switch_actuator_travel
                + coverage * 2 + e * 2,
            base_height = switch_base_height + e,

            actuator_width = width,
            actuator_length = switch_actuator_length + gutter * 2,
            actuator_height = switch_actuator_height,

            z = -e
        );
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

    translate([0, y, 0]) {
        difference() {
            _outer();

            _cavity();

            _rib_cavities();

            if (debug) {
                translate([0, get_absolute_origin().y - e, -e]) {
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
