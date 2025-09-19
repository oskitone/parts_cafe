include <enclosure.scad>;
include <flat_top_rectangular_pyramid.scad>;
include <nuts_and_bolts.scad>;
include <switch_clutch.scad>;

module switch_clutch_fixture(
    width = SWITCH_BASE_WIDTH + 1,
    length = SWITCH_BASE_LENGTH + 1,
    height = SWITCH_BASE_HEIGHT + ENCLOSURE_FLOOR_CEILING,

    cavity_base_width = SWITCH_BASE_WIDTH,
    cavity_base_length = SWITCH_BASE_LENGTH,
    cavity_base_height = SWITCH_BASE_HEIGHT,

    window_width = SWITCH_ACTUATOR_WIDTH,
    window_length = SWITCH_ACTUATOR_LENGTH,

    fillet = 0,
    chamfer = .6,

    include_screw_holes = false,
    screw_hole_distance = 0,
    screw_hole_diameter = SCREW_DIAMETER - .4, // NOTE: intentionally tight

    debug = false,

    color = undef,
    cavity_color = undef,

    tolerance = .1
) {
    e = .0419;

    window_width = window_width + tolerance * 2;
    window_length = window_length + tolerance * 2;

    cavity_base_width = cavity_base_width + tolerance * 2;
    cavity_base_length = cavity_base_length + tolerance * 2;

    if (debug) {
        % translate([
            -SWITCH_ORIGIN.x + (width - SWITCH_BASE_WIDTH) / 2,
            -SWITCH_ORIGIN.y + (length - SWITCH_BASE_LENGTH) / 2,
            SWITCH_ORIGIN.z
        ]) switch();
    }

    difference() {
        color(color) {
            rounded_cube([width, length, height], fillet);
        }

        color(cavity_color) {
            translate([
                (width - window_width) / 2,
                (length - window_length) / 2,
                cavity_base_height - e
            ]) {
                cube([window_width, window_length, height - cavity_base_height + e * 2]);
            }

            translate([
                (width - window_width) / 2,
                (length - window_length) / 2,
                height - chamfer
            ]) {
                flat_top_rectangular_pyramid(
                    top_width = window_width + chamfer * 2,
                    top_length = window_length + chamfer * 2,
                    bottom_width = window_width,
                    bottom_length = window_length,
                    height = chamfer + e
                );
            }

            translate([
                (width - cavity_base_width) / 2,
                (length - cavity_base_length) / 2,
                -e
            ]) {
                cube([cavity_base_width, cavity_base_length, cavity_base_height + e]);
            }

            if (include_screw_holes) {
                for (x_add = [-1, 1]) {
                    translate([
                        width / 2 + screw_hole_distance / 2 * x_add,
                        length / 2,
                        -e
                    ]) {
                        cylinder(
                            d = screw_hole_diameter + tolerance * 2,
                            h = cavity_base_height + e,
                            $fn = 8
                        );

                        cylinder(
                            d1 = screw_hole_diameter + tolerance * 2 + chamfer * 2,
                            d2 = screw_hole_diameter + tolerance * 2,
                            h = chamfer + e,
                            $fn = 8
                        );
                    }
                }
            }

            if (debug) {
                translate([width / 2, -e, -e]) {
                    cube([
                        width / 2 + e,
                        length + e * 2,
                        height + e * 2
                    ]);
                }
            }
        }
    }
}

module demo(
    count = 3,
    plot = 5.8,
    fixture_width = 28,
    fixture_length = 20,
    fixture_height = 10,
    screw_hole_distance = 21.59,
    actuator_exposure = 4,
    switch_clutch_base_height = 8,
    switch_clutch_clearance = .6,
    vertical_clearance = .6,
    fillet = 1,
    tolerance = .1,
    debug = false
) {
    switch_clearance = plot - SWITCH_BASE_WIDTH;
    switches_width = SWITCH_BASE_WIDTH * count + switch_clearance * (count - 1);

    // clutch rests on switch, not PCB
    switch_clutch_width = plot - switch_clutch_clearance; // TODO: tolerance?
    switch_clutch_base_length = max(
        fixture_length - SWITCH_ACTUATOR_TRAVEL - fillet,
        SWITCH_CLUTCH_MIN_BASE_LENGTH
    );

    window_width = switch_clutch_width * count + switch_clutch_clearance * (count + 1);

    x_gutter = (fixture_width - window_width) / 2;

    actuator_length = max(
        fixture_length - x_gutter * 2 - SWITCH_ACTUATOR_TRAVEL,
        SWITCH_CLUTCH_MIN_ACTUATOR_LENGTH
    );

    translate([
        SWITCH_ORIGIN.x - (switch_clutch_width - SWITCH_BASE_WIDTH) / 2
            - (fixture_width - window_width) / 2
            - switch_clutch_clearance,
        fixture_length / -2,
        0
    ]) {
        switch_clutch_fixture(
            width = fixture_width,
            length = fixture_length,
            height = fixture_height,

            cavity_base_width = window_width,
            cavity_base_length = fixture_length + 10,
            cavity_base_height = switch_clutch_base_height + vertical_clearance,

            window_width = window_width,
            window_length = actuator_length + SWITCH_ACTUATOR_TRAVEL,

            fillet = fillet, $fn = 8,

            include_screw_holes = true,
            screw_hole_distance = screw_hole_distance,

            tolerance = tolerance,

            color = "#FF69B4",
            cavity_color = "#CC5490",

            debug = debug
        );
    }

    for (i = [0 : count - 1]) {
        translate([
            (SWITCH_BASE_WIDTH + switch_clearance) * i,
            -SWITCH_ORIGIN.y - SWITCH_BASE_LENGTH / 2,
            0
        ]) {
            switch_clutch(
                base_height = switch_clutch_base_height,
                base_width = switch_clutch_width,
                base_length = switch_clutch_base_length,

                actuator_width = switch_clutch_width,
                actuator_length = actuator_length,
                actuator_height = fixture_height - switch_clutch_base_height
                    + actuator_exposure,

                position = round($t * count) == i ? 1 : 0,

                cavity_base_width = switch_clutch_width,

                fillet = fillet, $fn = 6,

                color = "#FFFFFF",
                cavity_color = "#EEEEEE",

                clearance = 0.4,
                tolerance = tolerance,

                debug = debug
            );

            % translate([0,0,-.01]) switch(position = round($t * count) == i ? 1 : 0);
        }
    }
}

* demo();