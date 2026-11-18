const std = @import("std");
const port = @import("port");
const gclk = @import("gclk");
const pm = @import("pm");
const supc = @import("supc");
const sercom = @import("sercom");
const tc = @import("tc");
const cpu = @import("cpu");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const system_timer = @import("system_timer");

const LED_PIN = 27;
const LED_PIN_MASK: u32 = 1 << LED_PIN;

const USART_INSTANCE = sercom.sercom2;
const USART_RX_PIN = 25;
const USART_RX_PIN_MASK: u32 = 1 << USART_RX_PIN;
const USART_TX_PIN = 24;
const USART_TX_PIN_MASK: u32 = 1 << USART_TX_PIN;

pub const panic = std.debug.no_panic;

const TIMER_INSTANCE = tc.tc5_16;

var timer_interrupt: bool = undefined;

export fn SERCOM2_2_Handler() callconv(.c) void {
    const flags = USART_INSTANCE.usart.intflag;
    if (flags.err) {
        USART_INSTANCE.usart.intflag = .{.err = true};
    }
    if (flags.rxc) {
        const data = USART_INSTANCE.usart.data;
        USART_INSTANCE.usart.data = data;
    }
}

export fn TC5_Handler() callconv(.c) void {
    TIMER_INSTANCE.intflag = .{ .mc0 = true };
    timer_interrupt = true;
}

inline fn clocksInit() void {
    //USART
    gclk.gclk.channelEnable(.sercom2_core, 0);
    //Timer
    gclk.gclk.channelEnable(.tc4_tc5, 0);
}

inline fn usartInit() void {
    const init: sercom.UsartInitParameters = .{
        .baud = 115200,
        .clock_frequency = cpu.cpu.current_frequency,
        .rxpo = 3,
        .txpo = 1,
        .tx_pin = USART_TX_PIN,
        .rx_pin = USART_RX_PIN,
        .pmux = .D
    };
    USART_INSTANCE.usart.init(init);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.SERCOM2_2.toU8());
}

inline fn timerInit() void {
    timer_interrupt = false;
    TIMER_INSTANCE.cc[0] = @truncate(cpu.cpu.current_frequency / 1024);
    TIMER_INSTANCE.intenset = .{.mc0 = true};
    TIMER_INSTANCE.ctrla = .{.runstdby = true, .presync = .presc, .prescaler = .div1024};
    nvic.nvic.enableInterrupt(interrupts.Interrupt.TC5.toU8());
}

export fn SystemInit() callconv(.c) void {
    pm.pm.sleepcfg = .idle;
    supc.supc.buckConverterEnable();
    system_timer.delay_init(system_timer.init_div1);
    port.ports[0].dirset = LED_PIN_MASK;
    clocksInit();
    usartInit();
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
            port.ports[0].outtgl = LED_PIN_MASK;
        }
    }
}
