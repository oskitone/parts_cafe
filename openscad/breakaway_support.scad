DEFAULT_DFM_LAYER_HEIGHT = .2;

BREAKAWAY_SUPPORT_DISTANCE = 10;
BREAKAWAY_SUPPORT_DEPTH = .6;

module breakaway_support(
    width = BREAKAWAY_SUPPORT_DEPTH,
    length = BREAKAWAY_SUPPORT_DEPTH,
    height = 10,

    brim_depth = 1,
    brim_height = DEFAULT_DFM_LAYER_HEIGHT,

    gap = DEFAULT_DFM_LAYER_HEIGHT
) {
    cube([width, length, height - gap]);

    translate([-brim_depth, -brim_depth, 0]) {
        cube([
            width + brim_depth * 2,
            length + brim_depth * 2,
            brim_height
        ]);
    }
}
