const std = @import("std");
const board = @import("board");
const system_timer = @import("system_timer");
const pfic = @import("pfic");
const interrupts = @import("interrupts");
const cpu = @import("cpu");
const timer = @import("timer");
const rcc = @import("rcc");

const TIMER_INSTANCE = timer.bctm7;

var led_status: bool = undefined;
var timer_interrupt: bool = undefined;

pub const panic = std.debug.no_panic;

fn TIM7IRQHandler() callconv(.c) void {
    if (TIMER_INSTANCE.intfr.uif) {
        timer_interrupt = true;
        // clear interrupt flag
        TIMER_INSTANCE.intfr = timer.TimerIntfr{};
    }
}

export fn TIM7_IRQHandler() callconv(.naked) void {
    asm volatile(
        \\ call %[handler_fn]
        \\ mret
        :
        : [handler_fn] "i" (&TIM7IRQHandler)
    );
}

inline fn initTimer() void {
    rcc.rcc.hb1pcenr.tim7en = true;
    TIMER_INSTANCE.psc = @truncate(cpu.cpu.current_frequency / 10000 - 1);
    TIMER_INSTANCE.atrlr.value16 = 10000 - 1; //1 second interval
    TIMER_INSTANCE.dmaintenr = timer.TimerDmaIntEnr{.uie = true};
    pfic.interruptEnable(interrupts.Interrupt.TIM7.toU8());
    timer_interrupt = false;
}

export fn SystemInit() callconv(.c) void {
    board.init0();
    initTimer();
}

fn timerHandler() void {
    if (!timer_interrupt)
        return;
    timer_interrupt = false;
    led_status = !led_status;
    if (led_status) {
        board.ledGreenOn();
    } else {
        board.ledGreenOff();
    }
}

inline fn startTimer() void {
    TIMER_INSTANCE.ctlr1 = timer.TimerCtlr1{.cen = true, .apre = true};
}

export fn main() callconv(.c) noreturn {
    pfic.wakeupCpu1(@intFromPtr(&cpu.CORE_V5F_START_ADDRESS));
    startTimer();
    while (true) {
        asm volatile("wfi");
        timerHandler();
    }
}
