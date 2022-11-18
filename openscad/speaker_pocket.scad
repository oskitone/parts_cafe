include <ring.scad>;
include <speaker.scad>;

module speaker_pocket(
    wall = 2,
    floor_ceiling = 1,

    tolerance = 0,

    show_speaker = false,
    debug = false,

    speaker_diameter = SPEAKER_DIAMETER,
    speaker_brim_height = SPEAKER_BRIM_HEIGHT,
    speaker_brim_depth = SPEAKER_BRIM_DEPTH,
    speaker_magnet_height = SPEAKER_MAGNET_HEIGHT,
    speaker_magnet_diameter = SPEAKER_MAGNET_DIAMETER,
    speaker_total_height = SPEAKER_TOTAL_HEIGHT,
    speaker_cone_height = SPEAKER_CONE_HEIGHT
) {
    e = .042;

    outer_diameter = speaker_diameter + (tolerance + wall) * 2;
    outer_height = speaker_total_height + floor_ceiling;

    module _outer_wall() {
        ring(
            diameter = outer_diameter,
            height = outer_height,
            thickness = wall
        );
    }

    module _brim() {
        translate([0, 0, outer_height - floor_ceiling]) {
            ring(
                diameter = outer_diameter - wall * 2 + e * 2,
                height = floor_ceiling,
                thickness = speaker_brim_depth + tolerance - e * 2
            );
        }
    }

    difference() {
        union() {
            _outer_wall();
            _brim();
        }

        if (debug) {
            translate([0, outer_diameter / -2 - e, -e]) {
                cube([
                    outer_diameter / 2 + e,
                    outer_diameter + e * 2,
                    outer_height + e * 2
                ]);
            }
        }
    }

    if (show_speaker) {
        % speaker(
            speaker_diameter,
            speaker_brim_height,
            speaker_brim_depth,
            speaker_magnet_height,
            speaker_magnet_diameter,
            speaker_total_height,
            speaker_cone_height
        );
    }
}

* speaker_pocket(
    tolerance = .1,

    show_speaker = true,
    debug = true
);
