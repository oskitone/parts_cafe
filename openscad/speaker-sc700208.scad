SPEAKER_DIAMETER = 41.1;
SPEAKER_HEIGHT = 25;
SPEAKER_LENGTH = 71;
SPEAKER_PLATE_HOLE_DIAMETER = 3.6;
SPEAKER_PLATE_HOLE_XY = 4;
SPEAKER_PLATE_HEIGHT = .8;
SPEAKER_RIM_DEPTH = 3.8;
SPEAKER_RIM_HEIGHT = 1.4;
SPEAKER_CONE_DIAMETER = 38;
SPEAKER_MAGNET_DIAMETER = 22;
SPEAKER_MAGNET_HEIGHT = 7.5;

module speaker() {
    e = .01;

    module _speaker_face(
        diameter = SPEAKER_DIAMETER,
        d1, d2,
        height,
        z = 0
    ) {
        d1 = d1 != undef ? d1 : diameter;
        d2 = d2 != undef ? d2 : diameter;

        hull() {
            for (y = [
                SPEAKER_LENGTH / 2 - SPEAKER_DIAMETER / 2,
                SPEAKER_LENGTH / -2 + SPEAKER_DIAMETER / 2,
            ]) {
                translate([0, y, z]) {
                    cylinder(d1 = d1, d2 = d2, h = height);
                }
            }
        }
    }

    module _rim() {
        z = SPEAKER_HEIGHT - SPEAKER_RIM_HEIGHT;

        translate([0, 0, -e]) difference() {
            _speaker_face(
                height = SPEAKER_RIM_HEIGHT,
                z = z
            );

            _speaker_face(
                diameter = SPEAKER_DIAMETER - SPEAKER_RIM_DEPTH,
                height = SPEAKER_RIM_HEIGHT + e * 2,
                z = z - e
            );
        }
    }

    module _plate() {
        translate([
            SPEAKER_DIAMETER / -2,
            SPEAKER_LENGTH / -2,
            SPEAKER_HEIGHT - SPEAKER_RIM_HEIGHT - SPEAKER_PLATE_HEIGHT
        ]) {
            difference() {
                cube([SPEAKER_DIAMETER, SPEAKER_LENGTH, SPEAKER_PLATE_HEIGHT]);

                for (xy = [
                    [SPEAKER_PLATE_HOLE_XY, SPEAKER_PLATE_HOLE_XY],
                    [SPEAKER_DIAMETER - SPEAKER_PLATE_HOLE_XY, SPEAKER_PLATE_HOLE_XY],
                    [SPEAKER_PLATE_HOLE_XY, SPEAKER_LENGTH - SPEAKER_PLATE_HOLE_XY],
                    [SPEAKER_DIAMETER - SPEAKER_PLATE_HOLE_XY, SPEAKER_LENGTH - SPEAKER_PLATE_HOLE_XY],
                ]) {
                    translate([xy.x, xy.y, -e]) {
                        cylinder(
                            d = SPEAKER_PLATE_HOLE_DIAMETER,
                            h = SPEAKER_PLATE_HEIGHT + e * 2
                        );
                    }
                }
            }
        }
    }

    module _cone() {
        hull() {
            _speaker_face(
                d1 = SPEAKER_CONE_DIAMETER,
                d2 = SPEAKER_DIAMETER,
                height = e,
                z = SPEAKER_HEIGHT - SPEAKER_RIM_HEIGHT - SPEAKER_PLATE_HEIGHT - e
            );

            translate([0, 0, SPEAKER_MAGNET_HEIGHT]) {
                cylinder(d = SPEAKER_CONE_DIAMETER, h = e);
            }
        }
    }

    module _magnet() {
        cylinder(
            d = SPEAKER_MAGNET_DIAMETER,
            h = SPEAKER_MAGNET_HEIGHT
        );
    }

    _rim();
    % _plate();
    _cone();
    _magnet();
}