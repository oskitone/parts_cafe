DEFAULT_RIB_SIZE = .8;
DEFAULT_RIB_GUTTER = 1.234;

module rib_cavities(
    width,
    length,

    depth = DEFAULT_RIB_SIZE,
    rib_length = DEFAULT_RIB_SIZE,
    gutter = DEFAULT_RIB_GUTTER
) {
    e = .02581;

    ribbed_length = length - gutter * 2 - rib_length;
    rib_count = round(ribbed_length / (rib_length + gutter));

    for (i = [0 : rib_count - 0]) {
        y = gutter + i * (ribbed_length / rib_count);

        translate([-e, y, 0]) {
            cube([width + e * 2, rib_length, depth + e]);
        }
    }
}
