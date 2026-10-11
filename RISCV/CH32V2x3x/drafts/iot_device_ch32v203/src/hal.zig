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
const i2c = @import("i2c");
const spi = @import("spi");

const LED_PIN = 2;
const LED_PIN_MASK: u16 = 1 << LED_PIN;
const LED_PORT = gpio.gpiob;

const USART_INSTANCE = usart.usart1;

const USART_TX_PIN = 6;
const USART_TX_PIN_MASK: u16 = 1 << USART_TX_PIN;
const USART_TX_PORT = gpio.gpiob;

const USART_RX_PIN = 7;
const USART_RX_PIN_MASK: u16 = 1 << USART_RX_PIN;
const USART_RX_PORT = gpio.gpiob;

const I2C_INSTANCE = i2c.i2c1;
const I2C_PORT = gpio.gpiob;
//--------------------------
const I2C_SCL_PIN = 8;
const I2C_SCL_PIN_MASK = 1 << I2C_SCL_PIN;
//--------------------------
const I2C_SDA_PIN = 9;
const I2C_SDA_PIN_MASK = 1 << I2C_SDA_PIN;
//------------------------------
const I2C_SPEED = 100000;
//------------------------------
const I2C_TIMEOUT = 10000;

const TIMER_INSTANCE = timer.gptm4;

pub const CC1101_TIMEOUT = 10000;

pub var timer_interrupt: bool = undefined;
pub var sh: *shell.Shell = undefined;
var led_status: bool = undefined;

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

pub fn usartWrite(byte: u8) void {
    USART_INSTANCE.write(byte);
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
    TIMER_INSTANCE.atrlr.value16 = 1000 - 1; //0.1 second interval
    TIMER_INSTANCE.dmaintenr = timer.TimerDmaIntEnr{.uie = true};
    pfic.pfic.interruptEnable(interrupts.Interrupt.TIM4.toU8());
    timer_interrupt = false;
}

inline fn initClock() void {
    rcc.rcc.ctlr.hseon = true;
    while (!rcc.rcc.ctlr.hserdy) {
        asm volatile ("nop");
    }
    rcc.rcc.cfgr0.sw = .hse;
    while (rcc.rcc.cfgr0.sws != .hse) {
        asm volatile ("nop");
    }
}

pub inline fn initI2C() void {
   I2C_PORT.init(I2C_SCL_PIN_MASK|I2C_SDA_PIN_MASK, gpio.GpioModeOutputFastSpeed | gpio.GpioCnfAlternateOpenDrain);
   I2C_INSTANCE.initMaster(I2C_SPEED);
}

pub inline fn initSPI() void {
}

export fn SystemInit() callconv(.c) void {
    led_status = false;
    initClock();
    system_timer.delayInit();
    rcc.rcc.apb2pcenr = rcc.RccCfgrApb2pcEnr{.iopben = true, .afioen = true, .usart1en = true};
    rcc.rcc.apb1pcenr = rcc.RccCfgrApb1pcEnr{.i2c1en = true, .tim4en = true};
    afio.afio.pcfr1 = afio.AfioPcfr1{.usart1_rm = true, .i2c1_rm = true};
    LED_PORT.init(LED_PIN_MASK, gpio.GpioModeOutputSlowSpeed | gpio.GpioCnfOutputPushPull);
    initUsart();
    initTimer();
    initI2C();
    initSPI();
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

pub inline fn i2cScan(address: u10) i2c.I2cError!void {
    _ = address;
    //return I2C_INSTANCE.scan(address, I2C_TIMEOUT);
}

pub inline fn i2cRead(address: u10, data: []u8) i2c.I2cError!void {
    _ = address;
    _ = data;
    //return I2C_INSTANCE.read(address, data, I2C_TIMEOUT);
}

pub inline fn i2cWrite(address: u10, data: []const u8) i2c.I2cError!void {
    _ = address;
    _ = data;
    //return I2C_INSTANCE.write(address, data, I2C_TIMEOUT);
}

pub inline fn i2cTransfer(address: u10, wdata: []const u8, rdata: []u8) i2c.I2cError!void {
    _ = address;
    _ = wdata;
    _ = rdata;
    //return I2C_INSTANCE.transfer(address, wdata, rdata, I2C_TIMEOUT);
}

pub fn spi1CsSet(context: *anyopaque, state: bool) bool {
    _ = context;
    _ = state;
    // if (state) {
    //     SPI_CS_PORT.bop = SPI_CS_PIN_MASK;
    // } else {
    //     SPI_CS_PORT.bc = SPI_CS_PIN_MASK;
    // }
    // return true;
    return false;
}

pub fn spiSendReceive(channel: usize, wdata: []const u8, rdata: []u8) bool {
    _ = channel;
    _ = wdata;
    _ = rdata;
    // _ = spi1CsSet(@ptrFromInt(1), false);
    // SPI_INSTANCE.sendReceivePoll8(wdata, rdata);
    // _ = spi1CsSet(@ptrFromInt(1), true);
    // return true;
    return false;
}

pub fn spi1Write(context: *anyopaque, data: []const u8) bool {
    _ = context;
    _ = data;
    //SPI_INSTANCE.sendPoll8(data);
    //return true;
    return false;
}

pub fn spi1ReadWrite(context: *anyopaque, data: []u8) bool {
    _ = context;
    _ = data;
    //SPI_INSTANCE.sendReceivePoll8(data, data);
    //return true;
    return false;
}

pub fn spi1Transfer(context: *anyopaque, wdata: []const u8, rdata: []u8) bool {
    _ = context;
    _ = wdata;
    _ = rdata;
    //SPI_INSTANCE.transferPoll8(wdata, rdata);
    //return true;
    return false;
}

pub fn getGdo01(context: *anyopaque) ?bool {
    _ = context;
    //return GDO0_PORT.istat & GDO0_PIN_MASK != 0;
    return null;
}

pub fn getGdo21(context: *anyopaque) ?bool {
    _ = context;
    //return GDO2_PORT.istat & GDO2_PIN_MASK != 0;
    return null;
}
