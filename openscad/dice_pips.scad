module dice_pips(
    count = 1,
    diameter = 3,

    // ie, max width/length between pip centers
    size = 7,

    center = true
) {
    _start = 0;
    _center = size / 2;
    _end = size;

    center = [_center, _center];
    center_left = [_start, _center];
    center_right = [_end, _center];
    lower_left = [_start, _start];
    lower_right = [_end, _start];
    top_left = [_start, _end];
    top_right = [_end, _end];

    positions = [
        [center],
        [lower_left, top_right],
        [lower_left, center, top_right],
        [lower_left, lower_right, top_left, top_right],
        [lower_left, lower_right, center, top_left, top_right],
        [lower_left, lower_right, center_left, center_right, top_left, top_right],
    ];

    translate(center ? [-_center, -_center] : [0, 0]) {
        for (position = positions[count - 1]) {
            translate(position) {
                circle(d = diameter);
            }
        }
    }
}

* dice_pips(round($t * 6) + 1, $fn = 24);