PTV09A_POT_BASE_WIDTH = 10;
PTV09A_POT_BASE_LENGTH = 11;
PTV09A_POT_BASE_HEIGHT = 6.8;
PTV09A_POT_ACTUATOR_DIAMETER = 6.1;
PTV09A_POT_ACTUATOR_BASE_DIAMETER = 6.9;
PTV09A_POT_ACTUATOR_BASE_HEIGHT = 2;
PTV09A_POT_ACTUATOR_HEIGHT = 20 - PTV09A_POT_BASE_HEIGHT;
PTV09A_POT_ACTUATOR_D_SHAFT_HEIGHT = 7;
PTV09A_POT_ACTUATOR_D_SHAFT_DEPTH = PTV09A_POT_ACTUATOR_DIAMETER - 4.5;

POT_SHAFT_TYPE_SPLINED = "pot_shaft_type_splined";
POT_SHAFT_TYPE_PLAIN = "pot_shaft_type_plain";
POT_SHAFT_TYPE_FLATTED = "pot_shaft_type_flatted";
POT_SHAFT_TYPE_DEFAULT = POT_SHAFT_TYPE_SPLINED;

module pot(
    show_base = true,
    show_actator = true,

    base_width = PTV09A_POT_BASE_WIDTH,
    base_length = PTV09A_POT_BASE_LENGTH,
    base_height = PTV09A_POT_BASE_HEIGHT,

    actuator_diameter = PTV09A_POT_ACTUATOR_DIAMETER,
    actuator_height = PTV09A_POT_ACTUATOR_HEIGHT,

    shaft_type = POT_SHAFT_TYPE_DEFAULT,
    actuator_d_shaft_height = PTV09A_POT_ACTUATOR_D_SHAFT_HEIGHT,
    actuator_d_shaft_depth = PTV09A_POT_ACTUATOR_D_SHAFT_DEPTH,

    diameter_bleed = 0,
    actuator_height_bleed = 0
) {
    e = .0421;

    if (show_base) {
        translate([base_width / -2, base_length / -2, 0]) {
            cube([base_width, base_length, base_height]);
        }
    }

    if (show_actator) {
        translate([0, 0, base_height - e]) {
            difference() {
                cylinder(
                    d = actuator_diameter + diameter_bleed * 2,
                    h = actuator_height + actuator_height_bleed + e
                );

                if (shaft_type == POT_SHAFT_TYPE_FLATTED) {
                    translate([
                        actuator_diameter / -2 - diameter_bleed,
                        actuator_diameter / -2 - e - diameter_bleed,
                        actuator_height - actuator_d_shaft_height
                    ]) {
                        cube([
                            actuator_diameter + diameter_bleed * 2,
                            actuator_d_shaft_depth + e,
                            actuator_d_shaft_height + actuator_height_bleed + e
                        ]);
                    }
                }
            }
        }
    }
}
