const system_timer = @import("system_timer");
const board = @import("board");

export fn SystemInit() callconv(.c) void {
    board.init(false);
}

export fn main() callconv(.c) noreturn {
    while (true) {
        board.ledRedOn();
        board.ledGreenOff();
        board.ledYellowOff();
        system_timer.delayms(1000);
        board.ledRedOff();
        board.ledGreenOn();
        board.ledYellowOff();
        system_timer.delayms(1000);
        board.ledRedOff();
        board.ledGreenOff();
        board.ledYellowOn();
        system_timer.delayms(1000);
    }
}
