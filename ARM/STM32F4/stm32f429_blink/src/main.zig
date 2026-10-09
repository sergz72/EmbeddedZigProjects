const system_timer = @import("system_timer");
const board = @import("board");

fn usart_callback(data: u8) void {
    board.USART_INSTANCE.dr = data;
}

export fn SystemInit() callconv(.c) void {
    board.init();
    board.initUsart(115200, usart_callback);
}

export fn main() callconv(.c) noreturn {
    while (true) {
        board.ledGreenOn();
        board.ledRedOff();
        system_timer.delayms(1000);
        board.ledGreenOff();
        board.ledRedOn();
        system_timer.delayms(1000);
    }
}
