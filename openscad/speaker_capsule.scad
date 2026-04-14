include <enclosure.scad>;
include <speaker-TR-050F-8OHM-R.scad>;
include <threads.scad>;

module speaker_capsule(
    wall = ENCLOSURE_WALL * 1.5, // TODO: decouple threads vs body
    floor_ceiling = ENCLOSURE_FLOOR_CEILING,

    tolerance = .1,
    thread_clearance = .1, // TODO: confirm
    speaker_bottom_clearance = 1,

    wire_access_diameter = 2,
    wire_access_rotation = 0,

    fillet = 1, // TODO

    show_top = true,
    show_bottom = true,
    show_speaker = false,

    debug = false,
    test_print = false,

    z_separation = 3,

    threaded_height = 4, // TODO: try bigger threads too

    speaker_diameter = SPEAKER_DIAMETER,
    speaker_brim_height = SPEAKER_BRIM_HEIGHT,
    speaker_brim_depth = SPEAKER_BRIM_DEPTH,
    speaker_magnet_height = SPEAKER_MAGNET_HEIGHT,
    speaker_magnet_diameter = SPEAKER_MAGNET_DIAMETER,
    speaker_total_height = SPEAKER_TOTAL_HEIGHT,
    speaker_cone_height = SPEAKER_CONE_HEIGHT
) {
    e = .0235;

    inner_top_diameter = speaker_diameter + tolerance * 2;
    inner_bottom_diameter = speaker_diameter - speaker_brim_depth * 2 + tolerance * 2;
    inner_total_height = speaker_total_height + speaker_bottom_clearance;

    outer_diameter = inner_top_diameter + wall * 2;
    outer_height = inner_total_height + floor_ceiling * 2;
    outer_bottom_height = floor_ceiling + speaker_bottom_clearance
        + (speaker_total_height - threaded_height);
    outer_top_height = outer_height - outer_bottom_height;

    speaker_z = floor_ceiling + speaker_bottom_clearance;

    module _inner_cavities(top = true) {
        brim_z = outer_bottom_height + (threaded_height - speaker_brim_height);
        translate([0, 0, floor_ceiling]) {
            cylinder(
                d = inner_bottom_diameter,
                h = inner_total_height
            );
        }

        translate([0, 0, brim_z - (top ? e : 0)]) {
            cylinder(
                d = inner_top_diameter,
                h = speaker_brim_height + e
            );
        }

        translate([0, 0, outer_height - floor_ceiling - e]) {
            cylinder(
                d = inner_bottom_diameter,
                h = floor_ceiling + e * 2
            );
        }
    }

    module threads(cavity = true) {
        bleed = tolerance + thread_clearance;

        diameter = outer_diameter
            - (outer_diameter - inner_top_diameter) / 2
            + (cavity ? bleed * 2 : bleed * -2);
        
        translate([0, 0, outer_bottom_height - e]) {
            * cylinder(
                d = diameter,
                h = threaded_height + e
            );

            metric_thread(
                diameter = diameter,
                length = threaded_height + e,
                internal = !cavity,
                n_starts = 6
            );
        }
    }

    module _half(top = false) {
        height = top
            ? outer_top_height
            : outer_bottom_height;

        difference() {
            union() {
                translate([0, 0, top ? outer_bottom_height : 0]) {
                    cylinder(
                        d = outer_diameter,
                        h = height
                    );
                }

                if (!top) {
                    threads(cavity = false);
                }
            }

            _inner_cavities(top = top);

            if (top) {
                threads(cavity = true);
            }

            if (test_print) {
                translate([0, 0, -e]) {
                    cylinder(
                        d = outer_diameter + e * 2,
                        h = outer_bottom_height - floor_ceiling + e
                    );
                }
            }
        }
    }

    intersection() {
        union() {
            if (show_top) {
                translate([0, 0, z_separation]) {
                    _half(top = true);
                }
            }
            if (show_bottom) {
                _half(top = false);
            }
        }


        if (debug) {
            translate([-e, -(outer_diameter / 2 + e), -e]) {
                cube([
                    e,
                    outer_diameter + e * 2,
                    outer_height + e * 2 + z_separation
                ]);
            }
        }
    }

    if (show_speaker) {
        translate([0, 0, speaker_z + e]) {
            % speaker();
        }
    }
}

speaker_capsule(
    show_top = true,
    show_bottom = true,
    show_speaker = true,
    debug = $preview,
    test_print = false,
    z_separation = .1
);