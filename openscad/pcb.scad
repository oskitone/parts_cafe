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

function get_pcb_dimensions(
    edge_cuts = [
        // Copy from *.kicad_pcb
        // start xy -> end xy
        [[0, 0], [10, 0]],
        [[10, 0], [10, 10]],
        [[10, 10], [0, 10]],
        [[0, 10], [0, 0]],
    ],
    height = PCB_HEIGHT
) = (
    // Theoretically only need either START or END, since cut is a closed loop
    let (start_xs = [ for (cut = edge_cuts) cut[0].x ])
    let (start_ys = [ for (cut = edge_cuts) cut[0].y ])

    [
        max(start_xs) - min(start_xs),
        max(start_ys) - min(start_ys),
        height
    ]
);

function get_pcb_component_offset_position(
    edge_cuts = [[[0, 0], [0, 0]]]
) = (
    [
        min([for (cut = edge_cuts) cut[0].x]) * -1,
        min(start_ys = [for (cut = edge_cuts) cut[0].y])
    ]
);

function get_pcb_component_positions(
    component_positions = [[0, 0]],
    pcb_component_offset_position = [0, 0],
    pcb_dimensions = [0, 0, 0]
) = (
    // For KiCad -> OpenSCAD, Y axis is flipped but X is not
    [ for (xy = component_positions) [
        pcb_component_offset_position.x + xy.x,
        pcb_component_offset_position.y + (pcb_dimensions.y - xy.y)
    ] ]
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