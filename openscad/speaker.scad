SPEAKER_DIAMETER = 49.8;
SPEAKER_BRIM_HEIGHT = 2.3;
SPEAKER_BRIM_DEPTH = 2.65;
SPEAKER_MAGNET_HEIGHT = 11.6;
SPEAKER_MAGNET_DIAMETER = 22;
SPEAKER_TOTAL_HEIGHT = 18;
SPEAKER_CONE_HEIGHT = SPEAKER_TOTAL_HEIGHT - SPEAKER_MAGNET_HEIGHT
    - SPEAKER_BRIM_HEIGHT;

module speaker(
    diameter = SPEAKER_DIAMETER,
    brim_height = SPEAKER_BRIM_HEIGHT,
    brim_depth = SPEAKER_BRIM_DEPTH,
    magnet_height = SPEAKER_MAGNET_HEIGHT,
    magnet_diameter = SPEAKER_MAGNET_DIAMETER,
    total_height = SPEAKER_TOTAL_HEIGHT,
    cone_height = SPEAKER_CONE_HEIGHT
) {
    e = .043;


    cylinder(
        d = magnet_diameter,
        h = magnet_height
    );

    translate([0, 0, magnet_height - e]) {
        cylinder(
            d1 = magnet_diameter,
            d2 = diameter - brim_depth * 2,
            h = cone_height + e * 2
        );
    };

    translate([0, 0, magnet_height + cone_height - e]) {
        cylinder(
            d = diameter,
            h = brim_height
        );
    }
}
