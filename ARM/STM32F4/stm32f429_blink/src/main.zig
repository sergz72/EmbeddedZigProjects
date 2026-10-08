const system_timer = @import("system_timer");
const board = @import("board");

export fn SystemInit() callconv(.c) void {
    system_timer.delay_init(system_timer.init_div8);
    board.init_leds();
}

export fn main() callconv(.c) noreturn {
    while (true) {
        board.led_green_on();
        board.led_red_off();
        system_timer.delayms(1000);
        board.led_green_off();
        board.led_red_on();
        system_timer.delayms(1000);
    }
}
