module donut(
  diameter,
  thickness,

  segments = 24, // DEPRECATED
  starting_angle = 0,
  coverage = 360
) {
    $fn = segments; // TODO: remove when segments is no longer used

    rotate([0, 0, 90 - starting_angle]) {
        rotate_extrude(angle = -coverage) {
            translate([(diameter - thickness) / 2, 0]) {
              circle(thickness / 2);
            }
        }
    }
}
