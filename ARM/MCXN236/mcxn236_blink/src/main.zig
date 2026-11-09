const system_timer = @import("system_timer");
const board = @import("board");

export fn main() callconv(.c) noreturn {
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
