SUPPORT_BAR_LENGTH = 1.2; // ENCLOSURE_INNER_WALL

module support_bar(
    width = 10,
    length = SUPPORT_BAR_LENGTH,
    height = 5,
    web_chamfer = undef,
    web_chamfer_width = SUPPORT_BAR_LENGTH
) {
    web_chamfer = web_chamfer ? web_chamfer : height;

    cube([width, length, height]);

    for (x = [0, width - web_chamfer_width]) {
        translate([x, -web_chamfer, 0]) {
            flat_top_rectangular_pyramid(
                top_width = web_chamfer_width,
                top_length = length,

                bottom_width = web_chamfer_width,
                bottom_length = length + web_chamfer * 2,

                height = height
            );
        }
    }
}