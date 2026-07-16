UART_HEADER_PLOT = 2.54;
UART_HEADER_BLOCK_Y = 1.8;
UART_HEADER_PIN_DIMENSIONS = [.8, 10.25, .8];
UART_HEADER_BLOCK_DIMENSIONS = [UART_HEADER_PLOT * 6, 2.5, 2.5];

module uart_header() {
    x = UART_HEADER_PLOT / 2 - UART_HEADER_PIN_DIMENSIONS.x / 2;
    z = UART_HEADER_BLOCK_DIMENSIONS.y / 2 - UART_HEADER_PIN_DIMENSIONS.z / 2;

    translate([0, UART_HEADER_BLOCK_Y, 0]) {
        % cube(UART_HEADER_BLOCK_DIMENSIONS);
    }

    for (i = [0 : 5]) {
        translate([x + i * UART_HEADER_PLOT, 0, z]) {
            % cube(UART_HEADER_PIN_DIMENSIONS);
        }
    }
}