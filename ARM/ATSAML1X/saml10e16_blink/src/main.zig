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

export fn TC2_Handler() callconv(.c) void {
    tc.tc2_16.intflag = .{ .ovf = true };
    timer_interrupt = true;
}

inline fn clocksInit() void {
    //USART
    gclk.gclk.channelEnable(.sercom2_core, 0);
    //Timer
    gclk.gclk.channelEnable(.tc2, 0);
}

inline fn usartInit() void {
    port.ports[0].pincfg[USART_TX_PIN] = .{.pmuxen = true};
    port.ports[0].pincfg[USART_RX_PIN] = .{.pmuxen = true, .inen = true, .pullen = true};
    port.ports[0].pmux[USART_TX_PIN/2] = .{.pmuxe = .D, .pmuxo = .D};
    const init: sercom.UsartInitParameters = .{
        .baud = 115200,
        .clock_frequency = cpu.cpu.current_frequency,
        .rxpo = 3,
        .txpo = 1
    };
    USART_INSTANCE.usart.init(init);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.SERCOM2_2.toU8());
}

inline fn timerInit() void {
    timer_interrupt = false;
    tc.tc2_16.setPer(@truncate(cpu.cpu.current_frequency / 10240));
    tc.tc2_16.intenset = .{.ovf = true};
    tc.tc2_16.ctrla = .{.runstdby = true, .presync = .presc, .prescaler = .div1024};
    nvic.nvic.enableInterrupt(interrupts.Interrupt.TC2.toU8());
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
    tc.tc2_16.ctrla.enable = true;
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
