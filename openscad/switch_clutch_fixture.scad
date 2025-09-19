include <nuts_and_bolts.scad>;
include <enclosure.scad>;
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

    include_screw_holes = false,
    screw_hole_distance = 0,
    screw_hole_diameter = SCREW_DIAMETER,
    screw_hole_chamfer = .6,

    debug = false,

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
        cube([width, length, height]);

        translate([
            (width - window_width) / 2,
            (length - window_length) / 2,
            cavity_base_height - e
        ]) {
            cube([window_width, window_length, height - cavity_base_height + e * 2]);
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
                        d1 = screw_hole_diameter + tolerance * 2 + screw_hole_chamfer * 2,
                        d2 = screw_hole_diameter + tolerance * 2,
                        h = screw_hole_chamfer + e,
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

module demo(
    count = 3,
    plot = 5.8,
    screw_hole_distance = 21.59,
    switch_clutch_clearance = .4,
    vertical_clearance = .2,
    tolerance = .1
) {
    switch_clearance = plot - SWITCH_BASE_WIDTH;
    switches_width = SWITCH_BASE_WIDTH * count + switch_clearance * (count - 1);

    // clutch rests on switch, not PCB
    switch_clutch_width = plot - switch_clutch_clearance; // TODO: tolerance?
    switch_clutch_base_length = SWITCH_CLUTCH_MIN_BASE_LENGTH;
    switch_clutch_base_height = 7;

    actuator_length = SWITCH_CLUTCH_MIN_ACTUATOR_LENGTH;

    window_width = switch_clutch_width * count + switch_clutch_clearance * (count + 1);

    fixture_width = screw_hole_distance + 5;
    fixture_length = switch_clutch_base_length + SWITCH_ACTUATOR_TRAVEL
        + .01;

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
            height = switch_clutch_base_height + vertical_clearance + ENCLOSURE_FLOOR_CEILING,

            cavity_base_width = window_width,
            cavity_base_length = fixture_length + 10,
            cavity_base_height = switch_clutch_base_height + vertical_clearance,

            window_width = window_width,
            window_length = actuator_length + SWITCH_ACTUATOR_TRAVEL,

            include_screw_holes = true,
            screw_hole_distance = screw_hole_distance,

            tolerance = tolerance
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
                actuator_height = 4,

                position = round($t * count) == i ? 1 : 0,

                cavity_base_width = 100, chamfer_cavity_top = 0,

                fillet = 1, $fn = 6,

                color = "#FFFFFF",
                cavity_color = "#EEEEEE",

                clearance = 0,
                tolerance = tolerance
            );

            % translate([0,0,-.01]) switch(position = round($t * count) == i ? 1 : 0);
        }
    }
}

* demo();