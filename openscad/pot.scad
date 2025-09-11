PTV09A_POT_BASE_WIDTH = 10;
PTV09A_POT_BASE_LENGTH = 11;
PTV09A_POT_BASE_HEIGHT_FROM_PCB = 8.8; // ie, shaft_z
PTV09A_POT_ACTUATOR_DIAMETER = 6.1;
PTV09A_POT_ACTUATOR_BASE_DIAMETER = 6.9;
PTV09A_POT_ACTUATOR_HEIGHT = 20 - PTV09A_POT_BASE_HEIGHT_FROM_PCB;
PTV09A_POT_ACTUATOR_SPLINED_SHAFT_HEIGHT = 7;
PTV09A_POT_ACTUATOR_D_SHAFT_HEIGHT = 7;
PTV09A_POT_ACTUATOR_D_SHAFT_DEPTH = PTV09A_POT_ACTUATOR_DIAMETER - 4.5;

POT_SHAFT_TYPE_SPLINED = "pot_shaft_type_splined";
POT_SHAFT_TYPE_PLAIN = "pot_shaft_type_plain";
POT_SHAFT_TYPE_FLATTED = "pot_shaft_type_flatted";
POT_SHAFT_TYPE_DEFAULT = POT_SHAFT_TYPE_SPLINED;

// Distance from pin 1 to shaft center
PTV09A_POT_ORIGIN = [2.5, -7.5];

module pot(
    show_base = true,
    show_actator = true,

    base_width = PTV09A_POT_BASE_WIDTH,
    base_length = PTV09A_POT_BASE_LENGTH,
    base_height = PTV09A_POT_BASE_HEIGHT_FROM_PCB,

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
        height = actuator_height + actuator_height_bleed;
        flat_cavity_height = actuator_d_shaft_height + actuator_height_bleed;

        difference() {
            translate([0, 0, base_height - e]) {
                cylinder(
                    d = actuator_diameter + diameter_bleed * 2,
                    h = height + e
                );
            }

            if (shaft_type == POT_SHAFT_TYPE_FLATTED) {
                translate([
                    actuator_diameter / -2 - diameter_bleed,
                    actuator_diameter / -2 - e - diameter_bleed,
                    base_height + actuator_height - flat_cavity_height
                ]) {
                    cube([
                        actuator_diameter + diameter_bleed * 2,
                        actuator_d_shaft_depth + e,
                        flat_cavity_height + e
                    ]);
                }
            }
        }
    }
}

/* shaft_types = [
    POT_SHAFT_TYPE_SPLINED,
    POT_SHAFT_TYPE_PLAIN,
    POT_SHAFT_TYPE_FLATTED,
];

shaft_i = round($t * len(shaft_types));
pot(
    shaft_type = shaft_types[shaft_i]
); */
