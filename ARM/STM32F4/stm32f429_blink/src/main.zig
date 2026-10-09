const system_timer = @import("system_timer");
const board = @import("board");

export fn SystemInit() callconv(.c) void {
    board.init();
    board.initUart(115200);
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
