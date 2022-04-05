DEFAULT_RIB_SIZE = .8;
DEFAULT_RIB_GUTTER = 1.234;

module rib_cavities(
    width,
    length,

    depth = DEFAULT_RIB_SIZE,
    rib_length = DEFAULT_RIB_SIZE,
    gutter = DEFAULT_RIB_GUTTER,

    z = 0
) {
    e = .02581;

    plot = rib_length + gutter;
    ribbable_length = length - rib_length * 2;
    count = round(ribbable_length / plot);
    ribbed_length = count * plot - gutter;

    if (count > 0) {
        for (i = [0 : count - 1]) {
            y = (length - ribbed_length) / 2 + i * plot;

            translate([-e, y, z]) {
                cube([width + e * 2, rib_length, depth + e]);
            }
        }
    }
}

module __demo_rib_cavities(
    width = 2,
    height = 5,
    lengths = [1,2,3,4,4.2,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
) {
    for (i = [0: len(lengths) - 1]) {
        translate([i * (width + 1), 0, 0]) {
            difference() {
                cube([width, lengths[i], height]);

                rib_cavities(
                    width = width,
                    length = lengths[i],
                    z = height - DEFAULT_RIB_SIZE
                );
            }
        }
    }
}
/* __demo_rib_cavities(); */
