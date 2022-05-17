LED_DIAMETER = 5;
LED_BASE_DIAMETER = 6;
LED_HEIGHT = 8.6;

module led(
    diameter = LED_DIAMETER,
    height = LED_HEIGHT
) {
    hull() {
        cylinder(
            d = diameter,
            h = height - diameter / 2
        );

        translate([0, 0, height - diameter / 2]) {
            sphere(d = diameter);
        }
    }
}
