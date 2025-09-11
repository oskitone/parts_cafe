LED_DIAMETER = 5;

LED_MIN_HEIGHT = 8.6;
LED_MAX_HEIGHT = 9;
LED_HEIGHT = LED_MAX_HEIGHT;

LED_BASE_HEIGHT = 1;
LED_BASE_DIAMETER = 6;

LED_LEADS_DIAMETER = .5;

module led(
    diameter = LED_DIAMETER,
    height = LED_HEIGHT,

    base_diameter = LED_BASE_DIAMETER,
    base_height = LED_BASE_HEIGHT,

    leads_diameter = LED_LEADS_DIAMETER,

    exposed_leads_height = 0
) {
    e = .0521;

    if (exposed_leads_height > 0) {
        translate([LED_DIAMETER / -2, leads_diameter / -2, 0]) {
            cube([LED_DIAMETER, leads_diameter, exposed_leads_height]);
        }
    }

    translate([0, 0, exposed_leads_height]) {
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
}

module led_3mm() {
    led(
        diameter = 3.05,
        height = 3.85,
        base_height = .75,
        base_diameter = 4.02
    );
}