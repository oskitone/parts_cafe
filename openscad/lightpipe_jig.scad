include <../../parts_cafe/openscad/lightpipe.scad>;

// TODO/try:
// * a big metal washer vs knife
// * width covers full material_length

module lightpipe_jig(
    length = LIGHTPIPE_LENGTH,
    diameter = LIGHTPIPE_DIAMETER,
    width = 20,
    base = 5,
    wall = 5,
    material_length = 100,
    blade_width = .6,
    extension = 10,
    tolerance = 0
) {
    e = .014; // TODO: is this affecting dimensions?, revisit

    dimensions = [
        width,
        diameter + wall * 2,
        base + diameter
    ];

    material_position = [
        wall - tolerance,
        dimensions.y / 2,
        base + diameter / 2
    ];

    module _cavity() {
        cavity_length = dimensions.x - wall + tolerance + e * 2;

        translate(material_position) {
            rotate([0, 90, 0]) {
                cylinder(
                    d = diameter,
                    h = cavity_length
                );
            }
        }

        translate([
            material_position.x,
            material_position.y - diameter / 2,
            material_position.z - e
        ]) {
            cube([
                dimensions.x + 10, // NOTE: just arbitrarily bigger
                diameter,
                diameter / 2 + e * 2
            ]);
        }

        translate([
            material_position.x + length,
            -e,
            material_position.z - e
        ]) {
            cube([
                dimensions.x + 11, // NOTE: ^
                dimensions.y + e * 2,
                diameter / 2 + e * 2
            ]);
        }

        translate([
            material_position.x + length,
            -e,
            material_position.z - diameter / 2
        ]) {
            cube([
                blade_width + tolerance * 2,
                dimensions.y + e * 2,
                diameter + e * 2
            ]);
        }
    }

    difference() {
        cube(dimensions);

        _cavity();
    }

    % translate(material_position) {
        rotate([0, 90, 0]) {
            cylinder(
                d = diameter,
                h = length
            );
        }
    }
}

lightpipe_jig(tolerance = .1, $fn = 24);