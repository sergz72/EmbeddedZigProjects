const std = @import("std");
const rcu = @import("rcu");
const gpio = @import("gpio");
const cpu = @import("cpu");
const timer = @import("timer");
const usart = @import("usart");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const system_timer = @import("system_timer");
const scb = @import("scb");
const fmc = @import("fmc");
const fwdgt = @import("fwdgt");
const shell = @import("shell");
const usart_writer = @import("usart_writer");

const LED_PIN = 13;
const LED_PIN_MASK: u16 = 1 << LED_PIN;
const LED_PORT = gpio.gpioc;
const LED_INIT: gpio.GpioInit = .{
    .mode = .output,
    .output_speed = .low
};

const USART_INSTANCE = usart.usart0;

const USART_TX_PIN = 9;
const USART_TX_PIN_MASK: u16 = 1 << USART_TX_PIN;
const USART_TX_PORT = gpio.gpioa;
const USART_TX_PIN_INIT: gpio.GpioInit = .{
    .mode = .alternate,
    .output_speed = .high,
    .alternate = 1
};

const USART_RX_PIN = 10;
const USART_RX_PIN_MASK: u16 = 1 << USART_RX_PIN;
const USART_RX_PORT = gpio.gpioa;
const USART_RX_PIN_INIT: gpio.GpioInit = .{
    .mode = .alternate,
    .pud = .pullup,
    .output_speed = .high,
    .alternate = 1
};

const TIMER_INSTANCE = timer.bctm5;

pub var timer_interrupt: bool = undefined;
pub var sh: *shell.Shell = undefined;

pub const panic = std.debug.no_panic;

export fn TIMER5_IRQHandler() callconv(.c) void {
    if (TIMER_INSTANCE.intf.upif) {
        timer_interrupt = true;
        // clear interrupt flag
        TIMER_INSTANCE.intf = timer.TimerIntf{};
    }
}

export fn USART0_IRQHandler() callconv(.c) void {
    if (USART_INSTANCE.stat.rbne) {
        sh.processChar(@truncate(USART_INSTANCE.rdata));
    }
}

inline fn initTimer() void {
    TIMER_INSTANCE.psc = @truncate(cpu.cpu.current_frequency / 10000 - 1);
    TIMER_INSTANCE.car = 10000 - 1; //1 second interval
    TIMER_INSTANCE.dmainten = timer.TimerDmaIntEn{.upie = true};
    nvic.nvic.enableInterrupt(interrupts.Interrupt.TIMER5.toU8());
    timer_interrupt = false;
}

inline fn initUsart() void {
    USART_TX_PORT.init(USART_TX_PIN_MASK, USART_TX_PIN_INIT);
    USART_RX_PORT.init(USART_RX_PIN_MASK, USART_RX_PIN_INIT);
    USART_INSTANCE.init(115200, cpu.cpu.current_frequency);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.USART0.toU8());
    usart_writer.usart_writer.writeCharFunc = usartWrite;
}

export fn SystemInit() callconv(.c) void {
    rcu.rcu.enableIrc40k();
    system_timer.delay_init(system_timer.init_div1);
    rcu.rcu.ahben = rcu.RcuAhben{.paen = true, .pcen = true, .crcen = true};
    rcu.rcu.apb1en = rcu.RcuApb1en{.timer5en = true};
    rcu.rcu.apb2en = rcu.RcuApb2en{.usart0en = true};
    LED_PORT.init(LED_PIN_MASK, LED_INIT);

    initTimer();
    initUsart();

    if (!fwdgt.fwdgt.init(10000)) {
        while (true) {}
    }
}

pub fn usartWrite(byte: u8) void {
    USART_INSTANCE.write(byte);
}

pub inline fn startTimer() void {
    TIMER_INSTANCE.ctl0 = timer.TimerCtl0{.cen = true, .arse = true};
}

pub inline fn ledToggle() void {
    LED_PORT.tg = LED_PIN_MASK;
}

pub fn flashWrite(address: usize, data: []const u8) fmc.FmcError!void {
    fmc.fmc.flashUnlock();
    defer fmc.fmc.flashLock();
    try fmc.fmc.write(address, data);
}

pub fn flashSectorErase(address: usize) fmc.FmcError!void {
    fmc.fmc.flashUnlock();
    defer fmc.fmc.flashLock();
    try fmc.fmc.pageErase(address);
}

pub fn reboot() void {
    scb.scb.reboot();
}

pub fn wdtReset() void {
    fwdgt.fwdgt.reload();
}

pub fn getResetCause() []const u8 {
    return rcu.rcu.getResetCause();
}
