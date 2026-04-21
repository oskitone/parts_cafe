include <cylinder_grip.scad>;
include <diagonal_grill.scad>;
include <donut.scad>;
include <enclosure.scad>;
include <ring.scad>;
include <speaker-TR-050F-8OHM-R.scad>;
include <threads.scad>;

SPEAKER_CAPSULE_FLOOR_CEILING = ENCLOSURE_FLOOR_CEILING;
SPEAKER_CAPSULE_FILLET = 1.25;

module speaker_capsule(
    wall = ENCLOSURE_WALL * 1.5,
    floor_ceiling = SPEAKER_CAPSULE_FLOOR_CEILING,

    tolerance = .1,
    speaker_diameter_clearance = .2,
    speaker_bottom_clearance = 1,

    wire_access_width = 3,
    wire_access_height = 1,
    wire_access_rotation = 0,

    fillet = SPEAKER_CAPSULE_FILLET,

    show_top = true,
    show_middle = true,
    show_bottom = true,

    show_speaker = false,
    show_threads = true,

    debug = false,
    test_print = false,

    z_separation = 0,

    threaded_height = 5,
    thread_clearance = .2,
    thread_pitch = 1.4,

    outline_gutter = .5,
    outline_depth = .6,
    outline_length = 1,

    speaker_diameter = SPEAKER_DIAMETER,
    speaker_brim_height = SPEAKER_BRIM_HEIGHT,
    speaker_brim_depth = SPEAKER_BRIM_DEPTH,
    speaker_magnet_height = SPEAKER_MAGNET_HEIGHT,
    speaker_magnet_diameter = SPEAKER_MAGNET_DIAMETER,
    speaker_total_height = SPEAKER_TOTAL_HEIGHT,
    speaker_cone_height = SPEAKER_CONE_HEIGHT,

    outer_segments = $preview ? 12 : 60,
    grip_count = 0
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
        translate([0, 0, floor_ceiling > 0 ? floor_ceiling : -e]) {
            cylinder(
                d = speaker_cavity_diameter,
                h = bottom_cavity_height + (floor_ceiling > 0 ? 0 : e)
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
                h = speaker_brim_height + (floor_ceiling > 0 ? e : e * 2)
            );
        }

        // Speaker exposure
        if (floor_ceiling > 0) {
            translate([0, 0, outer_height - floor_ceiling - e]) {
                intersection() {
                    cylinder(
                        d = speaker_inner_brim_diameter,
                        h = floor_ceiling + e * 2
                    );


                    render() diagonal_grill(
                        speaker_inner_brim_diameter + e * 2,
                        speaker_inner_brim_diameter + e * 2,
                        floor_ceiling + e * 2,
                        center = true
                    );
                }
            }

            translate([0, 0, outer_height - outline_depth]) {
                ring(
                    diameter = speaker_inner_brim_diameter
                        + outline_gutter * 2 + outline_length * 2,
                    inner_diameter = speaker_inner_brim_diameter
                        + outline_gutter * 2,
                    height = outline_depth + e
                );
            }
        }
    }

    module _threads(
        cavity = true,
        height = threaded_height,
        z = 0,
        chamfer_top = false,
        chamfer_bottom = false
    ) {
        diameter = get_threads_diameter(cavity);

        leadin = (chamfer_top && chamfer_bottom)
            ? 2
            : (chamfer_top || chamfer_bottom)
                ? (chamfer_top ? 1 : 3)
                : 0;
        
        height = floor_ceiling > 0 ? height : height + e * 2;
        z = floor_ceiling > 0 ? z : z - e;

        translate([0, 0, z]) {
            if (show_threads) {
                metric_thread(
                    diameter = diameter,
                    pitch = thread_pitch,
                    length = height + e,
                    internal = cavity,
                    leadin = leadin,
                    n_starts = 6
                );
            } else {
                cylinder(
                    d = diameter,
                    h = height + e
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

            if (fillet > 0) {
                render() hull() {
                    for (z = [fillet, height - fillet]) {
                        translate([0, 0, z]) {
                            _end();
                        }
                    }
                }
            } else {
                cylinder(
                    d = outer_cap_diameter,
                    outer_cap_height,
                    $fn = outer_segments
                );
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
                    for (i = [0, 1]) {
                        is_bottom = i == 1;

                        _threads(
                            cavity = false,
                            height = is_bottom
                                ? threaded_height - wire_access_height
                                : threaded_height,
                            z = is_bottom
                                ? floor_ceiling + wire_access_height
                                : outer_height - floor_ceiling - threaded_height - e,
                            chamfer_top = i == 0,
                            chamfer_bottom = i == 1
                        );
                    }
                }
            }

            _inner_cavities(cap = cap);

            if (cap) {
                z = bottom_cap ? 0 : outer_height - outer_cap_height
                    - (floor_ceiling > 0 ? 0 : e);

                translate([0, 0, z]) {
                    cylinder_grip(
                        diameter = outer_cap_diameter,
                        height = outer_cap_height + (floor_ceiling > 0 ? 0 : e * 2),
                        count = grip_count,
                        rotation_offset = 0,
                        size = 2,
                        $fn = 6
                    );
                }

                _threads(
                    cavity = true,
                    height = top_cap
                        ? threaded_height
                        : threaded_height- wire_access_height,
                    z = top_cap
                        ? outer_height - floor_ceiling - threaded_height - e
                        : floor_ceiling + wire_access_height
                );
            }

            if (bottom_cap) {
                width = wire_access_width + tolerance * 2;
                z = floor_ceiling > 0 ? floor_ceiling : -e;

                rotate([0, 0, wire_access_rotation]) {
                    translate([width / -2, 0, z]) {
                        cube([
                            width,
                            outer_cap_diameter * 2,
                            outer_cap_height + (floor_ceiling > 0 ? 0 : e * 2)
                        ]);
                    }
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

* speaker_capsule(
    show_top = true,
    show_middle = true,
    show_bottom = true,
    show_speaker = true,
    debug = $preview,
    show_threads = true,
    test_print = false,
    z_separation = $preview ? .1 : 5,
    grip_count = 12
);