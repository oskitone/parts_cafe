LED_DIAMETER = 5;
LED_HEIGHT = 8.6;

LED_BASE_HEIGHT = 1;
LED_BASE_DIAMETER = 6;

module led(
    diameter = LED_DIAMETER,
    height = LED_HEIGHT,

    base_diameter = LED_BASE_DIAMETER,
    base_height = LED_BASE_HEIGHT
) {
    cylinder(
        d = base_diameter,
        h = base_height
    );

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
