const board = @import("board");
const tc = @import("tc");
const system_timer = @import("system_timer");
const cpu = @import("cpu");
const gclk = @import("gclk");
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
    gclk.gclk.channelEnable(.tc4_tc5, 0);
}

inline fn timerInit() void {
    timer_interrupt = false;
    TIMER_INSTANCE.cc[0] = @truncate(cpu.cpu.current_frequency / 1024);
    TIMER_INSTANCE.intenset = .{.mc0 = true};
    TIMER_INSTANCE.ctrla = .{.runstdby = true, .presync = .presc, .prescaler = .div1024};
    nvic.nvic.enableInterrupt(interrupts.Interrupt.TC5.toU8());
}

export fn SystemInit() callconv(.c) void {
    board.init();
    //clocksInit();
    //timerInit();
}

inline fn timerStart() void {
    TIMER_INSTANCE.ctrla.enable = true;
}

export fn main() callconv(.c) noreturn {
    //timerStart();
    while (true) {
        system_timer.delayms(1000);
        board.ledToggle();
        //asm volatile("wfi");
        //if (timer_interrupt) {
        //    timer_interrupt = false;
        //    board.ledToggle();
        //}
    }
}
