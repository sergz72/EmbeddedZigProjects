const board = @import("board");
const shell = @import("shell");
const timer = @import("timer");
const cpu = @import("cpu");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const rcc = @import("rcc");

const TIMER_INSTANCE = timer.bctm7;

pub var timer_interrupt: bool = undefined;
pub var sh: *shell.Shell = undefined;

export fn TIM7_IRQHandler() callconv(.c) void {
    if (TIMER_INSTANCE.sr.uif) {
        timer_interrupt = true;
        // clear interrupt flag
        TIMER_INSTANCE.sr = timer.TimerSr{};
    }
}

inline fn initTimer() void {
    rcc.rcc.apb1enr.tim7en = true;
    TIMER_INSTANCE.psc = @truncate(cpu.cpu.apb1_frequency * 2 / 10000 - 1);
    TIMER_INSTANCE.arr.value16 = 1000 - 1; //0.1 second interval
    TIMER_INSTANCE.dier = .{.uie = true};
    nvic.nvic.enableInterrupt(interrupts.Interrupt.TIM7.toU8());
    timer_interrupt = false;
}

export fn SystemInit() callconv(.c) void {
    board.init();
    board.initSdram();
    initTimer();
}

pub inline fn startTimer() void {
    TIMER_INSTANCE.cr1 = .{.cen = true, .apre = true};
}
