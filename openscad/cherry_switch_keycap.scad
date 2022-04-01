STOCK_CHERRY_SWITCH_KEYCAP_DIMENSIONS = [18, 18, 10];

module cherry_switch_keycap(
    dimensions,

    exposed_height = 5,

    contact_width = 14,
    contact_length = 14,

    fillet = 1
) {
    base_height = dimensions.z - exposed_height;

    module _layer(width, length, z) {
        for (
            x = [fillet, width - fillet],
            y = [fillet, length - fillet]
        ) {
            translate([
                x + (dimensions.x - width) / 2,
                y + (dimensions.y - length) / 2,
                z
            ]) {
                sphere(r = fillet);
            }
        }
    }

    hull() {
        _layer(dimensions.x, dimensions.y, fillet);
        _layer(dimensions.x, dimensions.y, base_height);
        _layer(contact_width, contact_length, dimensions.z - fillet);
    }
}
