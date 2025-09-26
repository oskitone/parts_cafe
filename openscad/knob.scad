include <wheel.scad>;

module knob(
    diameter = 20,
    height = 10,

    fillet = 2,

    ceiling = 1.8,
    hub_diameter = PTV09A_POT_ACTUATOR_DIAMETER + 1.2 * 2,

    dimple_count = 1,
    dimple_depth = 1,
    dimple_y = 20 / 2 / 2,

    chamfer = 1.2 - .5,
    shim_size = .6,
    shim_count = 5,

    round_bottom = true,

    brim_diameter = 0,
    brim_height = 0,

    shaft_type = POT_SHAFT_TYPE_DEFAULT,

    grip_count = undef,

    test_fit = false,

    color = undef,
    cavity_color = undef,

    debug = false,

    tolerance = 0
) {
    wheel(
        diameter = diameter,
        height = height,

        fillet = fillet,

        ceiling = ceiling,

        brodie_knob_count = 0,

        dimple_count = dimple_count,
        dimple_depth = dimple_depth,
        dimple_y = dimple_y,

        spokes_count = 0,

        chamfer = chamfer,
        shim_size = shim_size,
        shim_count = shim_count,

        round_bottom = round_bottom,

        brim_diameter = brim_diameter,
        brim_height = brim_height,

        shaft_type = shaft_type,

        grip_count = grip_count,

        test_fit = test_fit,

        color = color,
        cavity_color = cavity_color,

        debug = debug,

        tolerance = tolerance
    );
}

* knob(
    color = "#fff",
    cavity_color = "#eee",
    tolerance = .1,
    debug = 1,
    $fn = undef
);