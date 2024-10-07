// https://www.digikey.com/en/products/detail/35PM1/SC1455-ND/1288859

SOCKET_BARREL_DIAMETER = 3.5;
SOCKET_BARREL_HEIGHT = .203 * 25.4;

SOCKET_INNER_DIAMETER = (.25 + .219) * 25.4;
SOCKET_INNER_HEIGHT = .406 * 25.4;

module socket() {
    e = .1482;

    cylinder(
        d = SOCKET_INNER_DIAMETER,
        h = SOCKET_INNER_HEIGHT
    );

    translate([0, 0, SOCKET_INNER_HEIGHT - e]) {
        cylinder(
            d = SOCKET_BARREL_DIAMETER,
            h = SOCKET_BARREL_HEIGHT
        );  
    }
}