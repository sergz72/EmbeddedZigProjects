const system_timer = @import("system_timer");
const board = @import("board");
const rcc = @import("rcc");

fn usart_callback(data: u8) void {
    board.USART_INSTANCE.tdr = data;
}

export fn SystemInit() callconv(.c) void {
    board.init(false, 48000000, rcc.PllCharacteristicsH563);
    board.initUsart(115200, &usart_callback);
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
