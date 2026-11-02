const system_timer = @import("system_timer");
const board = @import("board");
const rcc = @import("rcc");
const tim = @import("tim");
const cpu = @import("cpu");
const nvic = @import("nvic");
const interrupts = @import("interrupts");

const TIMER_INSTANCE = tim.tim7;

var led_status: bool = undefined;

pub var timer_interrupt: bool = undefined;

export fn TIM7_IRQHandler() callconv(.c) void {
    if (TIMER_INSTANCE.sr.u) {
        timer_interrupt = true;
        // clear interrupt flag
        TIMER_INSTANCE.sr = tim.Timr{};
    }
}

fn usart_callback(data: u8) void {
    board.USART_INSTANCE.tdr = data;
}

inline fn initTimer() void {
    rcc.rcc.hpenr.apb1l.tim7en = true;
    TIMER_INSTANCE.psc = @truncate(cpu.cpu.pclk1_frequency / 10000 - 1);
    TIMER_INSTANCE.arr = 10000 - 1; //1 second interval
    TIMER_INSTANCE.dier = .{.u = true};
    nvic.nvic.enableInterrupt(interrupts.Interrupt.TIM7.toU8());
    timer_interrupt = false;
}

inline fn startTimer() void {
    TIMER_INSTANCE.cr1 = .{.cen = true, .arpe = true};
}

export fn SystemInit() callconv(.c) void {
    board.init(false, 48000000, rcc.PllCharacteristicsH563);
    board.initUsart(115200, &usart_callback);
    initTimer();
}

fn ledRedToggle() void {
    led_status = !led_status;
    if (led_status) {
        board.ledRedOn();
    } else {
        board.ledRedOff();
    }
}

export fn main() callconv(.c) noreturn {
    led_status = false;
    startTimer();
    while (true) {
        asm volatile ("wfi");
        ledRedToggle();
    }
}
