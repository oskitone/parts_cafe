/* Arndt AZ40R 1.6" */
/* https://www.jameco.com/Jameco/Products/ProdDS/2227516.pdf */

include <ring.scad>;

SPEAKER_DIAMETER = 39.7;
SPEAKER_HEIGHT = 5.4;

SPEAKER_FIXTURE_WALL = 1.2; // ENCLOSURE_INNER_WALL

module speaker() {
    cylinder(
        d = SPEAKER_DIAMETER,
        h = SPEAKER_HEIGHT
    );
}

function get_speaker_fixture_diameter(
    tolerance = 0,
    wall = SPEAKER_FIXTURE_WALL,
    speaker_diameter = SPEAKER_DIAMETER
) = (
    speaker_diameter + wall * 2 + tolerance * 2
);

module speaker_fixture(
    height = SPEAKER_HEIGHT,
    wall = SPEAKER_FIXTURE_WALL,
    tab_cavity_count = 1,
    tab_cavity_rotation = 90,
    tab_cavity_size = 15,
    tolerance = 0,
    quick_preview = true
) {
    e = .053;

    ring_z = height - SPEAKER_HEIGHT;
    diameter = get_speaker_fixture_diameter(tolerance, wall);

    difference() {
        ring(
            diameter = diameter,
            height = height,
            thickness = wall,
            $fn = quick_preview ? undef : 120
        );

        for (i = [0 : tab_cavity_count]) {
            rotation = tab_cavity_rotation + i * (360 / tab_cavity_count);

            rotate([0, 0, rotation]) {
                translate([tab_cavity_size / -2, 0, ring_z - e]) {
                    cube([tab_cavity_size, diameter / 2, height + e * 2]);
                }
            }
        }
    }
}