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
const scd4x = @import("scd4x");
const veml = @import("veml7700");

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

pub const panic = std.debug.no_panic;

pub var timer_interrupt: bool = undefined;
pub var sh: *shell.Shell = undefined;
pub var scd_device: scd4x.SCD4x = .{.i2c_read = scdRead, .i2c_write = scdWrite};
pub var veml_device: veml.VEML7700 = .{.i2c_read = vemlRead, .i2c_write = vemlWrite};
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

pub fn i2cScan(channel: usize, address: u10) u8 {
    if (channel != 0)
        return 'e';
    I2C_INSTANCE.scan(address, I2C_TIMEOUT) catch {
        return 'e';
    };
    return 0;
}

pub fn scdRead(data: []u8) bool {
    I2C_INSTANCE.read(scd4x.SCD4X_SENSOR_ADDR, data, I2C_TIMEOUT) catch |err| {
        scd_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn scdWrite(data: []const u8) bool {
    I2C_INSTANCE.write(scd4x.SCD4X_SENSOR_ADDR, data, I2C_TIMEOUT) catch |err| {
        scd_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn vemlRead(reg: u8) ?u16 {
    var rdata: [2]u8 = undefined;
    I2C_INSTANCE.transfer(veml.VEML7700_I2C_ADDRESS, &[_]u8{ reg }, &rdata, I2C_TIMEOUT) catch |err| {
        veml_device.i2c_error_name = @errorName(err);
        return null;
    };
    return std.mem.readInt(u16, &rdata, .little);
}

pub fn vemlWrite(reg: u8, data: u16) bool {
    const wdata: []const u8 = &.{reg, @truncate(data), @truncate(data >> 8)};
    I2C_INSTANCE.write(veml.VEML7700_I2C_ADDRESS, wdata, I2C_TIMEOUT) catch |err| {
        veml_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
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
