DIAGONAL_GRILL_SIZE = 2;

// TODO / KNOWN ISSUES:
// * skew shouldn't affect position
// * high skew above 45 position is out of bounds

module diagonal_grill(
    width, length, height,
    size = DIAGONAL_GRILL_SIZE,
    offset = 0,
    angle = 45,
    skew = 0,
    center = false
) {
    e = 0.0049;

    _size = cos(skew) * size;
    plot_width = size * 2;

    long_side = max(width, length) + offset;

    module _cavities() {
        count = long_side / plot_width * 2 + 1;
        total_width = (count * 2 - 1) * _size;

        translate([width / 2 + offset, length / 2, 0]) {
            rotate([0, 0, angle]) {
                translate([total_width / -2, total_width / -2, 0]) {
                    for (i = [0 : count - 1]) {
                        translate([plot_width * i, 0, height]) {
                            rotate([0, skew, 0]) {
                                translate([0, 0, height * -2]) {
                                    cube([_size, long_side * 2, max(_size, height) * 3]);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    translate([
        width * (center ? -1/2 : 0),
        length * (center ? -1/2 : 0),
        0
    ]) {
        difference() {
            cube([width, length, height]);
            _cavities();
        }
    }
}

* translate([-40, -20, 0]) {
    # cube([80, 40, 5]);
    diagonal_grill(80, 40, 6, size = 9, skew = round($t * 45));
}