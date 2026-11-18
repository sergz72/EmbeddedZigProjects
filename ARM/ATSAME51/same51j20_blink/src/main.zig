const board = @import("board");
const tc = @import("tc");
const cpu = @import("cpu");
const gclk = @import("gclk");
const mclk = @import("mclk");
const nvic = @import("nvic");
const interrupts = @import("interrupts");

const TIMER_INSTANCE = tc.tc5_16;

var timer_interrupt: bool = undefined;

export fn TC5_Handler() callconv(.c) void {
    TIMER_INSTANCE.intflag = .{ .mc0 = true };
    timer_interrupt = true;
}

inline fn clocksInit() void {
    //Timer
    mclk.mclk.apbcmask.tc5 = true;
    gclk.gclk.channelEnable(.tc4_tc5, 0);
}

inline fn timerInit() void {
    timer_interrupt = false;
    TIMER_INSTANCE.initTimerInterrupt(@truncate(cpu.cpu.current_frequency / 1024), .div1024);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.TC5.toU8());
}

export fn SystemInit() callconv(.c) void {
    board.init();
    clocksInit();
    timerInit();
}

inline fn timerStart() void {
    TIMER_INSTANCE.ctrla.enable = true;
}

export fn main() callconv(.c) noreturn {
    timerStart();
    while (true) {
        asm volatile("wfi");
        if (timer_interrupt) {
            timer_interrupt = false;
            board.ledToggle();
        }
    }
}
