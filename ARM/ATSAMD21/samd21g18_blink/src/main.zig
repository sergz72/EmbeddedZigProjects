const std = @import("std");
const port = @import("port");
const system_timer = @import("system_timer");
const tc = @import("tc");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const gclk = @import("gclk");
const cpu = @import("cpu");
const pm = @import("pm");
const sercom = @import("sercom");
const sysctrl = @import("sysctrl");
const nvmctrl = @import("nvmctrl");

const LED1_PIN = 27;
const LED1_PIN_MASK: u32 = 1 << LED1_PIN;
const LED1_PORT = 0;

const LED2_PIN = 3;
const LED2_PIN_MASK: u32 = 1 << LED2_PIN;
const LED2_PORT = 1;

const USART_PORT = 0;
pub const USART_INSTANCE = sercom.sercom1;
//--------------------------------
const USART_TX_PIN = 16;
const USART_TX_PIN_MASK = 1 << USART_TX_PIN;
//--------------------------------
const USART_RX_PIN = 18;
const USART_RX_PIN_MASK = 1 << USART_RX_PIN;

const TIMER_INSTANCE = tc.tc3_16;

pub const panic = std.debug.no_panic;

var timer_interrupt: bool = undefined;

export fn TC3_Handler() callconv(.c) void {
    TIMER_INSTANCE.intflag = .{ .mc0 = true };
    timer_interrupt = true;
}

export fn SERCOM1_Handler() callconv(.c) void {
    const flags = USART_INSTANCE.usart.intflag;
    if (flags.err) {
        USART_INSTANCE.usart.intflag = .{.err = true};
    }
    if (flags.rxc) {
        const data = USART_INSTANCE.usart.data;
        USART_INSTANCE.usart.data = data;
    }
}

inline fn initClocks() void {
    //sysctrl.enableXosc32k();
    //gclk.setXosc32kForDfll48(1);
    //sysctrl.setXosc32kForDfll48();
    //nvmctrl.setWaitStates(1);
    //gclk.gclk.genctrl = gclk.GclkGenctrl{
    //    .id = 0,
    //    .src = .dfll48m,
    //    .genen = true,
    //};
    //cpu.cpu.current_frequency = 48000000;
    //USART
    pm.pm.apbcmask.sercom1 = true;
    gclk.channelEnable(.sercom1_core, 0);
    //Timer
    pm.pm.apbcmask.tc3 = true;
    gclk.channelEnable(.tcc2_tc3, 0);
    system_timer.delay_init(system_timer.init_div1);
}

inline fn initLeds() void {
    port.ports[LED1_PORT].outset = LED1_PIN_MASK;
    port.ports[LED1_PORT].dirset = LED1_PIN_MASK;
    port.ports[LED2_PORT].dirset = LED2_PIN_MASK;
}

inline fn initTimer() void {
    timer_interrupt = false;
    TIMER_INSTANCE.initTimerInterrupt(@truncate(cpu.cpu.current_frequency / 1024), .div1024);
    nvic.enableInterrupt(interrupts.Interrupt.TC3.toU8());
}

inline fn initUsart() void {
    const uinit = sercom.UsartInitParameters{
        .baud = 115200,
        .clock_frequency = cpu.cpu.current_frequency,
        .rxpo = 2,
        .txpo = 0,
        .tx_pin = USART_TX_PIN,
        .rx_pin = USART_RX_PIN,
        .port = USART_PORT,
        .pmux = .C
    };
    USART_INSTANCE.usart.init(uinit);
    nvic.enableInterrupt(interrupts.Interrupt.SERCOM1.toU8());
}

export fn SystemInit() callconv(.c) void {
    initClocks();
    initLeds();
    initTimer();
    //initUsart();
}

fn timerHandler() void {
    if (timer_interrupt) {
        timer_interrupt = false;
        port.ports[LED1_PORT].outtgl = LED1_PIN_MASK;
        port.ports[LED2_PORT].outtgl = LED2_PIN_MASK;
    }
}

inline fn timerStart() void {
    TIMER_INSTANCE.ctrla.enable = true;
}

export fn main() callconv(.c) noreturn {
    timerStart();
    while (true) {
        asm volatile ("wfi");
        timerHandler();
    }
}
