const system_timer = @import("system_timer");
const board = @import("board");

export fn SystemInit() callconv(.c) void {
    board.init();
}

export fn main() callconv(.c) noreturn {
    while (true) {
        board.ledOn();
        system_timer.delayms(1000);
        board.ledOff();
        system_timer.delayms(1000);
    }
}
