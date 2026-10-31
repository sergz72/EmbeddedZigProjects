const std = @import("std");
const rcc = @import("rcc");
const gpio = @import("gpio");
const afio = @import("afio");
const usart = @import("usart");
const cpu = @import("cpu");
const system_timer = @import("system_timer");
const pfic = @import("pfic");
const interrupts = @import("interrupts");
const usart_writer = @import("usart_writer");
const timer = @import("timer");
const shell = @import("shell");
const iwdg = @import("iwdg");
const flash = @import("flash");
const rng = @import("rng");
const rtc = @import("rtc");

const LED_PIN = 2;
const LED_PIN_MASK: u16 = 1 << LED_PIN;
const LED_PORT = gpio.gpiob;

pub const panic = std.debug.no_panic;

const USART_INSTANCE = usart.usart1;

const USART_TX_PIN = 6;
const USART_TX_PIN_MASK: u16 = 1 << USART_TX_PIN;
const USART_TX_PORT = gpio.gpiob;

const USART_RX_PIN = 7;
const USART_RX_PIN_MASK: u16 = 1 << USART_RX_PIN;
const USART_RX_PORT = gpio.gpiob;

const TIMER_INSTANCE = timer.gptm4;

pub var timer_interrupt: bool = undefined;
pub var sh: *shell.Shell = undefined;
var led_status: bool = undefined;

fn TIM4IRQHandler() callconv(.c) void {
    if (TIMER_INSTANCE.intfr.uif) {
        timer_interrupt = true;
        // clear interrupt flag
        TIMER_INSTANCE.intfr = timer.TimerIntfr{};
    }
}

export fn TIM4_IRQHandler() callconv(.naked) void {
    asm volatile(
        \\ call %[handler_fn]
        \\ mret
        :
        : [handler_fn] "i" (&TIM4IRQHandler)
    );
}

fn USART1IRQHandler() callconv(.c) void {
    if (USART_INSTANCE.statr.rxne) {
        sh.processChar(USART_INSTANCE.datar);
    }
}

export fn USART1_IRQHandler() callconv(.naked) void {
    asm volatile(
        \\ call %[handler_fn]
        \\ mret
        :
        : [handler_fn] "i" (&USART1IRQHandler)
    );
}

inline fn initUsart() void {
    USART_TX_PORT.init(USART_TX_PIN_MASK, gpio.GpioModeOutputFastSpeed | gpio.GpioCnfAlternatePushPull);
    USART_RX_PORT.bshr = USART_RX_PIN_MASK; // pullup
    USART_RX_PORT.init(USART_RX_PIN_MASK, gpio.GpioCnfInputPullupPulldown);
    USART_INSTANCE.init(115200, cpu.cpu.current_frequency);
    pfic.pfic.interruptEnable(interrupts.Interrupt.USART1.toU8());
    usart_writer.usart_writer.writeCharFunc = usartWrite;
}

inline fn initTimer() void {
    TIMER_INSTANCE.psc = @truncate(cpu.cpu.current_frequency / 10000 - 1);
    TIMER_INSTANCE.atrlr.value16 = 10000 - 1; //1 second interval
    TIMER_INSTANCE.dmaintenr = timer.TimerDmaIntEnr{.uie = true};
    pfic.pfic.interruptEnable(interrupts.Interrupt.TIM4.toU8());
    timer_interrupt = false;
}

inline fn initClock() void {
    rcc.rcc.setSystemClockTo48MHz();
    rcc.rcc.enableLsi();
}

export fn SystemInit() callconv(.c) void {
    led_status = false;
    initClock();
    system_timer.delayInit();
    rcc.rcc.ahbpcenr = rcc.RccCfgrAhbpcEnr{.crcen = true};
    rcc.rcc.apb2pcenr = rcc.RccCfgrApb2pcEnr{.iopben = true, .afioen = true, .usart1en = true};
    rcc.rcc.apb1pcenr = rcc.RccCfgrApb1pcEnr{.tim4en = true};
    afio.afio.pcfr1 = afio.AfioPcfr1{.usart1_rm = true};
    LED_PORT.init(LED_PIN_MASK, gpio.GpioModeOutputSlowSpeed | gpio.GpioCnfOutputPushPull);
    initUsart();
    initTimer();
    rtc.rtc.init();
    rng.rng.init();
    if (!iwdg.iwdg.init(10000)) {
        while (true) {}
    }
}

pub fn usartWrite(byte: u8) void {
    USART_INSTANCE.write(byte);
}

pub inline fn ledOn() void {
    LED_PORT.bshr = LED_PIN_MASK;
}

pub inline fn ledOff() void {
    LED_PORT.bcr = LED_PIN_MASK;
}

pub inline fn startTimer() void {
    TIMER_INSTANCE.ctlr1 = timer.TimerCtlr1{.cen = true, .apre = true};
}

pub fn ledToggle() void {
    led_status = !led_status;
    if (led_status) {
        LED_PORT.bshr = LED_PIN_MASK;
    } else {
        LED_PORT.bcr = LED_PIN_MASK;
    }
}

pub fn flashWrite(address: usize, data: []const u8) flash.FlashError!void {
    flash.flash.flashUnlock();
    defer flash.flash.flashLock();
    try flash.flash.write(address, data);
}

pub fn flashSectorErase(address: usize) flash.FlashError!void {
    flash.flash.flashUnlock();
    defer flash.flash.flashLock();
    try flash.flash.pageErase(address);
}

pub fn reboot() void {
    pfic.pfic.systemReset();
}

pub fn wdtReset() void {
    iwdg.iwdg.reload();
}

pub fn getResetCause() []const u8 {
    return rcc.rcc.getResetCause();
}
