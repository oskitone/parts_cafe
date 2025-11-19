include <dice_pips.scad>;
include <rounded_cube.scad>;

// FACT: "Dice" is plural. Its singular is "die."
// OPINION: I don't like that.

module dice(
    size = 16,
    fillet = 1,
    pips = [1,2,3,4,5,6],
    engraving_depth = 2,
    center = true
) {
    e = 0.0124;

    positions = [
        [0, 0, size + e], // top
        [0, 0, -e], // bottom
        [0, size / 2 + e, size / 2], // back
        [0, size / -2 - e, size / 2], // front
        [size / -2 - e, 0, size / 2], // left
        [size / 2 + e, 0, size / 2], // right
    ];
    rotations = [
        [0, 180, 0], // top
        [0, 0, 0], // bottom
        [90, 0, 0], // back
        [-90, 0, 0], // front
        [0, 90, 0], // left
        [0, -90, 0], // right
    ];

    intersection() {
        difference() {
            rounded_cube(
                [size, size, size],
                radius = fillet,
                center = center
            );

            for (i = [0 : len(pips) - 1]) {
                translate(positions[i]) {
                    rotate(rotations[i]) {
                        linear_extrude(height = engraving_depth + e) {
                            dice_pips(
                                count = pips[i],
                                diameter = size / 5,
                                size = size / 2,
                                center = true
                            );
                        }
                    }
                }
            }
        }

        translate([0, 0, size / 2]) {
            sphere(
                r = sqrt(2 * pow(size / 2, 2)),
                $fn = 36
            );
        }
    }
}

* translate([20 * 0, 0, 0]) dice();
* translate([20 * 1, 0, 0]) dice(pips = [0,0,1,5,6,6]);
* translate([20 * 2, 0, 0]) dice(pips = [3,3,3,3,3,3]);
* translate([20 * 3, 0, 0]) dice(pips = [3,4,5,6]);