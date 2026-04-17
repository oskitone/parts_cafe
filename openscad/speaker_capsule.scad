include <cylinder_grip.scad>;
include <enclosure.scad>;
include <speaker-TR-050F-8OHM-R.scad>;
include <threads.scad>;

module speaker_capsule(
    wall = ENCLOSURE_WALL * 1.5, // TODO: decouple threads vs body
    floor_ceiling = ENCLOSURE_FLOOR_CEILING,

    tolerance = .1,
    speaker_diameter_clearance = .2,
    speaker_bottom_clearance = 1,

    wire_access_width = 4,

    fillet = 1, // TODO

    show_top = true,
    show_middle = true,
    show_bottom = true,

    show_speaker = false,
    show_threads = true,

    debug = false,
    test_print = false,

    z_separation = 3,

    threaded_height = 4,
    thread_clearance = .2,
    thread_pitch = 1.4,

    speaker_diameter = SPEAKER_DIAMETER,
    speaker_brim_height = SPEAKER_BRIM_HEIGHT,
    speaker_brim_depth = SPEAKER_BRIM_DEPTH,
    speaker_magnet_height = SPEAKER_MAGNET_HEIGHT,
    speaker_magnet_diameter = SPEAKER_MAGNET_DIAMETER,
    speaker_total_height = SPEAKER_TOTAL_HEIGHT,
    speaker_cone_height = SPEAKER_CONE_HEIGHT,

    outer_segments = undef,
    grip_count = undef
) {
    e = .0235;

    inner_cap_diameter = speaker_diameter + (tolerance + speaker_diameter_clearance) * 2;
    inner_middle_diameter = speaker_diameter - speaker_brim_depth * 2 + tolerance * 2;
    inner_total_height = test_print
        ? threaded_height * 3
        : speaker_total_height + speaker_bottom_clearance;

    outer_diameter = inner_cap_diameter + wall * 2;
    outer_height = inner_total_height + floor_ceiling * 2;

    outer_cap_height = floor_ceiling + threaded_height;
    outer_middle_height = outer_height - outer_cap_height * 2;

    module _inner_cavities(cap = true) {
        // Main block
        translate([0, 0, floor_ceiling]) {
            cylinder(
                d = inner_middle_diameter,
                h = inner_total_height
            );
        }

        // Redundant speaker brim supports
        for (z = [
            floor_ceiling - e,
            outer_height - floor_ceiling - speaker_brim_height
        ]) {
            translate([0, 0, z]) {
                cylinder(
                    d = inner_cap_diameter,
                    h = speaker_brim_height + e
                );
            }
        }

        // Speaker exposure
        // TODO: grill
        translate([0, 0, test_print ? -e : outer_height - floor_ceiling - e]) {
            cylinder(
                d = inner_middle_diameter,
                h = outer_height * 2
            );
        }
    }

    module _threads(cavity = true, z = 0) {
        bleed = tolerance + thread_clearance;

        diameter = outer_diameter
            - (outer_diameter - inner_cap_diameter) / 2
            + (cavity ? bleed * 2 : bleed * -2);
        
        translate([0, 0, z]) {
            if (show_threads) {
                metric_thread(
                    diameter = diameter,
                    pitch = thread_pitch,
                    length = threaded_height + e,
                    internal = cavity,
                    leadin = 2,
                    n_starts = 6
                );
            } else {
                cylinder(
                    d = diameter,
                    h = threaded_height + e
                );
            }
        }
    }

    module _section(top_cap = false, bottom_cap = false) {
        cap = top_cap || bottom_cap;

        height = cap
            ? outer_cap_height
            : outer_middle_height;

        cylinder_z = cap
            ? (top_cap ? outer_cap_height + outer_middle_height : 0)
            : outer_cap_height;

        difference() {
            union() {
                translate([0, 0, cylinder_z]) {
                    cylinder(
                        d = outer_diameter,
                        h = height,
                        $fn = outer_segments
                    );
                }

                if (cap) {
                    translate([0, 0, bottom_cap ? 0 : outer_height - outer_cap_height]) {
                        cylinder_grip(
                            diameter = outer_diameter,
                            height = outer_cap_height,
                            count = grip_count,
                            rotation_offset = 0,
                            size = 2,
                            $fn = 6
                        );
                    }
                }

                if (!cap) {
                    for (z = [
                        outer_height - floor_ceiling - threaded_height - e,
                        floor_ceiling
                    ]) {
                        _threads(cavity = false, z = z);
                    }
                }
            }

            _inner_cavities(cap = cap);

            if (cap) {
                _threads(
                    cavity = true,
                    z = top_cap
                        ? outer_height - floor_ceiling - threaded_height - e
                        : floor_ceiling
                );
            }

            if (bottom_cap) {
                translate([wire_access_width / -2, 0, floor_ceiling]) {
                    cube([wire_access_width, outer_diameter * 2, outer_cap_height]);
                }
            }
        }
    }

    intersection() {
        union() {
            if (show_top) {
                translate([0, 0, z_separation * 2]) {
                    _section(top_cap = true);
                }
            }

            if (show_middle) {
                translate([0, 0, z_separation * 1]) {
                    _section();
                }
            }

            if (show_bottom) {
                translate([0, 0, z_separation * 0]) {
                    _section(bottom_cap = true);
                }
            }
        }

        if (debug) {
            translate([-e, -(outer_diameter / 2 + e), -e]) {
                cube([
                    e,
                    outer_diameter + e * 2,
                    outer_height + e * 2 + z_separation * 2
                ]);
            }
        }
    }

    if (show_speaker) {
        z = outer_height - floor_ceiling - speaker_total_height;

        translate([0, 0, z + z_separation * 2]) {
            % speaker();
        }
    }
}

speaker_capsule(
    show_top = true,
    show_middle = true,
    show_bottom = true,
    show_speaker = true,
    debug = $preview,
    show_threads = true,
    test_print = false,
    z_separation = $preview ? .1 : 5,
    outer_segments = $preview ? 12 : 60,
    grip_count = 12
);