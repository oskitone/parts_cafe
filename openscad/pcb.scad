include <ghost_cube.scad>;

PCB_HEIGHT = 1.7;
PCB_HOLE_DIAMETER = 3.2;

// ie, trimmed leads and solder joints on bottom
PCB_BOTTOM_CLEARANCE = 2;

// USAGE: copy and wrap values from *.kicad_pcb, eg:
// PCB_HOLE_POSITIONS = [ get_translated_xy([133.35, 79.375]) ];
function get_translated_xy(xy) = (
    [xy.x - 4 * 25.4, 4.5 * 25.4 - xy.y]
);

module pcb(
    show_board = true,
    show_silkscreen = true,
    show_switches = true,
    show_led = true,

    show_bottom_clearance = false,

    width = 100,
    length = 100,
    height = PCB_HEIGHT,

    bottom_clearance = PCB_BOTTOM_CLEARANCE,

    hole_positions = [],
    hole_diameter = PCB_HOLE_DIAMETER,

    tolerance = 0,

    // NOTE: eyeball it!
    silkscreen_offset = [-.05,-.05],
    silkscreen_path = "../kicad/XYZ-brd.svg",

    pcb_color = "purple",
    silkscreen_color = [1,1,1,.25]
) {
    e = .0143;
    silkscreen_height = e;

    if (show_board) {
        difference() {
            union() {
                color(pcb_color) {
                    cube([width, length, height]);
                }

                if (show_silkscreen) {
                    color(silkscreen_color) {
                        translate([silkscreen_offset.x, silkscreen_offset.y, height - e]) {
                            linear_extrude(silkscreen_height + e) {
                                import(silkscreen_path);
                            }
                        }
                    }
                }
            }

            color(pcb_color) {
                for (xy = hole_positions) {
                    translate([xy.x, xy.y, -e]) {
                        cylinder(
                            d = hole_diameter,
                            h = height + silkscreen_height + e * 2,
                            $fn = 12
                        );
                    }
                }
            }
        }
    }

    if (show_bottom_clearance) {
        translate([e, e, -bottom_clearance]) {
            % ghost_cube([width - e * 2, length - e * 2, bottom_clearance + e]);
        }
    }
}