const board = @import("board");
const ctimer = @import("ctimer");
const syscon = @import("syscon");
const nvic = @import("nvic");
const interrupts = @import("interrupts");

var timer_interrupt: bool = undefined;

fn uart_callback(data: u8) void {
    board.UART_INSTANCE.data.data8 = data;
}

fn initTimer() void {
    timer_interrupt = false;
    syscon.syscon0.ahbclkctrlset1.timer0 = true;
    syscon.syscon0.ctimerclksel[0] = .pll0;
    syscon.syscon0.ctimerclkdiv[0] = syscon.Clkdiv{.halt = false, .div = 47};
    ctimer.ctimer0.pr = 1000;
    ctimer.ctimer0.mr[0] = 1000;
    ctimer.ctimer0.mcr = ctimer.Mcr{.mr0i = true, .mr0r = true};
    nvic.nvic.enableInterrupt(interrupts.Interrupt.CTIMER0.toU8());
    ctimer.ctimer0.tcr = ctimer.Tcr{.cen = true};
}

export fn main() callconv(.c) noreturn {
    board.initUart(115200, uart_callback);
    initTimer();
    while (true) {
        asm volatile ("wfi");
        if (timer_interrupt) {
            timer_interrupt = false;
            board.ledGreenToggle();
        }
    }
}

export fn CTIMER0_IRQHandler() callconv(.c) void {
    if (ctimer.ctimer0.ir.mr0int) {
        ctimer.ctimer0.ir = ctimer.Ir{.mr0int = true};
        timer_interrupt = true;
    }
}