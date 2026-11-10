const system_timer = @import("system_timer");
const board = @import("board");

fn uart_callback(data: u8) void {
    board.UART_INSTANCE.data.data8 = data;
}

export fn main() callconv(.c) noreturn {
    board.initUart(115200, uart_callback);
    while (true) {
        system_timer.delayms(1000);
        board.ledRedOff();
        board.ledGreenOn();
        system_timer.delayms(1000);
        board.ledGreenOff();
        board.ledBlueOn();
        system_timer.delayms(1000);
        board.ledBlueOff();
        board.ledRedOn();
    }
}
