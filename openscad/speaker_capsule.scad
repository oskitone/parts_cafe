include <cylinder_grip.scad>;
include <donut.scad>;
include <enclosure.scad>;
include <speaker-TR-050F-8OHM-R.scad>;
include <threads.scad>;

module speaker_capsule(
    wall = ENCLOSURE_WALL * 1.5,
    floor_ceiling = ENCLOSURE_FLOOR_CEILING,

    tolerance = .1,
    speaker_diameter_clearance = .2,
    speaker_bottom_clearance = 1,

    wire_access_width = 4,

    fillet = ENCLOSURE_FILLET,

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

    speaker_cavity_diameter = speaker_diameter
        + (tolerance + speaker_diameter_clearance) * 2;
    speaker_inner_brim_diameter = speaker_diameter
        - speaker_brim_depth * 2 + tolerance * 2;
    inner_total_height = test_print
        ? threaded_height * 3
        : speaker_total_height + speaker_bottom_clearance;

    outer_height = inner_total_height + floor_ceiling * 2;

    outer_cap_height = floor_ceiling + threaded_height;
    outer_middle_height = outer_height - outer_cap_height * 2;

    outer_cap_diameter = speaker_cavity_diameter + wall * 2;

    function get_threads_diameter(cavity) = (
        outer_cap_diameter
            - (outer_cap_diameter - speaker_cavity_diameter) / 2
            + (tolerance + thread_clearance) * (cavity ? 2 : -2)
    );

    module _inner_cavities(cap = true) {
        brim_z = outer_height - floor_ceiling - speaker_brim_height;
        chamfer = (speaker_cavity_diameter - speaker_inner_brim_diameter) / 2;
        bottom_cavity_height = inner_total_height - speaker_brim_height - chamfer;

        // Bottom
        translate([0, 0, floor_ceiling]) {
            cylinder(
                d = speaker_cavity_diameter,
                h = bottom_cavity_height
            );
        }

        // Chamfer from bottom to speaker brim
        translate([0, 0, floor_ceiling + bottom_cavity_height - e]) {
            cylinder(
                d1 = speaker_cavity_diameter,
                d2 = speaker_inner_brim_diameter,
                h = chamfer + e * 2
            );
        }

        // Speaker brim
        translate([0, 0, brim_z]) {
            cylinder(
                d = speaker_cavity_diameter,
                h = speaker_brim_height + e
            );
        }

        // Speaker exposure
        // TODO: grill
        translate([0, 0, test_print ? -e : outer_height - floor_ceiling - e]) {
            cylinder(
                d = speaker_inner_brim_diameter,
                h = outer_height * 2
            );
        }
    }

    module _threads(cavity = true, z = 0, chamfer_top = false, chamfer_bottom = false) {
        diameter = get_threads_diameter(cavity);

        leadin = (chamfer_top && chamfer_bottom)
            ? 2
            : (chamfer_top || chamfer_bottom)
                ? (chamfer_top ? 1 : 3)
                : 0;
        
        translate([0, 0, z]) {
            if (show_threads) {
                metric_thread(
                    diameter = diameter,
                    pitch = thread_pitch,
                    length = threaded_height + e,
                    internal = cavity,
                    leadin = leadin,
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

        module _cap() {
            module _end() {
                donut(
                    diameter = outer_cap_diameter,
                    thickness = fillet * 2,
                    segments = outer_segments, $fn = outer_segments
                );
            }

            render() hull() {
                for (z = [fillet, height - fillet]) {
                    translate([0, 0, z]) {
                        _end();
                    }
                }
            }
        }

        difference() {
            union() {
                translate([0, 0, cylinder_z]) {
                    if (cap) {
                        _cap();
                    } else {
                        cylinder(
                            d = get_threads_diameter(cavity = false),
                            h = height,
                            $fn = outer_segments
                        );
                    }
                }

                if (!cap) {
                    zs = [
                        outer_height - floor_ceiling - threaded_height - e,
                        floor_ceiling
                    ];

                    for (i = [0, 1]) {
                        _threads(
                            cavity = false,
                            z = zs[i],
                            chamfer_top = i == 0,
                            chamfer_bottom = i == 1
                        );
                    }
                }
            }

            _inner_cavities(cap = cap);

            if (cap) {
                translate([0, 0, bottom_cap ? 0 : outer_height - outer_cap_height]) {
                    cylinder_grip(
                        diameter = outer_cap_diameter,
                        height = outer_cap_height,
                        count = grip_count,
                        rotation_offset = 0,
                        size = 2,
                        $fn = 6
                    );
                }

                _threads(
                    cavity = true,
                    z = top_cap
                        ? outer_height - floor_ceiling - threaded_height - e
                        : floor_ceiling
                );
            }

            if (bottom_cap) {
                translate([wire_access_width / -2, 0, floor_ceiling]) {
                    cube([wire_access_width, outer_cap_diameter * 2, outer_cap_height]);
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
            translate([-e, -(outer_cap_diameter / 2 + e), -e]) {
                cube([
                    e,
                    outer_cap_diameter + e * 2,
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