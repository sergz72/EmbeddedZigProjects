const std = @import("std");
const system_timer = @import("system_timer");
const crm = @import("crm");
const gpio = @import("gpio");
const tmr = @import("tmr");
const cpu = @import("cpu");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const usart = @import("usart");
const i2c = @import("i2c");
const spi = @import("spi");
const flash = @import("flash");
const shell = @import("shell");
const usart_writer = @import("usart_writer");
const scd4x = @import("scd4x");
const veml = @import("veml7700");
const bme = @import("bme280");
const tsl = @import("tsl2591");
const scb = @import("scb");
const wdt = @import("wdt");

const LED_PIN = 4;
const LED_PIN_MASK: u16 = 1 << LED_PIN;
const LED_PORT = gpio.gpiob;
const LED_INIT: gpio.GpioInit = .{
    .mode = .output
};

const USART_INSTANCE = usart.usart1;
const USART_PORT = gpio.gpiob;
//--------------------------------------
const USART_TX_PIN = 6;
const USART_TX_PIN_MASK: u16 = 1 << USART_TX_PIN;
const USART_TX_PIN_INIT: gpio.GpioInit = .{
    .mode = .multiplexed,
    .mux = .mux0
};
//---------------------------------------
const USART_RX_PIN = 7;
const USART_RX_PIN_MASK: u16 = 1 << USART_RX_PIN;
const USART_RX_PIN_INIT: gpio.GpioInit = .{
    .mode = .multiplexed,
    .mux = .mux0,
    .pull = .pullup
};

const TIMER_INSTANCE = tmr.btmr6;

const I2C_INSTANCE = i2c.i2c1;
//--------------------------
const I2C_PORT = gpio.gpiof;
const I2C_SCL_PIN = 1;
const I2C_SCL_PIN_MASK = (1 << I2C_SCL_PIN);
const I2C_SDA_PIN = 0;
const I2C_SDA_PIN_MASK = (1 << I2C_SDA_PIN);
const I2C_PINS_INIT: gpio.GpioInit = .{
    .mode = .multiplexed,
    .pull = .pullup,
    .open_drain = true,
    .mux = .mux1
};
//------------------------------
const I2C_TIMEOUT = 10000;
const I2C_SPEED = 100000;

const SPI_INSTANCE = spi.spi1;
//--------------------------
const SPI_PORT = gpio.gpioa;
//--------------------------
const SPI_RX_PIN = 6;
const SPI_RX_PIN_MASK: u24 = 1 << SPI_RX_PIN;
const SPI_RX_PIN_INIT: gpio.GpioInit = .{
    .mode = .multiplexed,
    .pull = .pullup,
    .mux = .mux0
};
//--------------------------
const SPI_TX_PIN = 7;
const SPI_TX_PIN_MASK: u24 = 1 << SPI_TX_PIN;
const SPI_OUT_PINS_INIT: gpio.GpioInit = .{
    .mode = .multiplexed,
    .mux = .mux0
};
//--------------------------
const SPI_CLK_PIN = 5;
const SPI_CLK_PIN_MASK: u24 = 1 << SPI_CLK_PIN;
//--------------------------
const SPI_CS_PORT = gpio.gpiob;
const SPI_CS_PIN = 0;
const SPI_CS_PIN_MASK: u24 = 1 << SPI_CS_PIN;
const SPI_CS_PIN_INIT: gpio.GpioInit = .{
    .mode = .output
};
const SPI_BAUD = 1000000;

pub const CC1101_TIMEOUT = 10000;
//--------------------------
const GDO0_PORT = gpio.gpiob;
const GDO0_PIN = 1;
const GDO0_PIN_MASK: u24 = 1 << GDO0_PIN;
const GDO0_PIN_INIT: gpio.GpioInit = .{
    .mode = .input,
    .pull = .pulldown
};
const GDO2_PORT = gpio.gpiob;
const GDO2_PIN = 2;
const GDO2_PIN_MASK: u24 = 1 << GDO2_PIN;
const GDO2_PIN_INIT: gpio.GpioInit = .{
    .mode = .input,
    .pull = .pullup
};

pub var timer_interrupt: bool = undefined;
pub var sh: *shell.Shell = undefined;
pub var scd_device: scd4x.SCD4x = .{.i2c_read = scdRead, .i2c_write = scdWrite};
pub var veml_device: veml.VEML7700 = .{.i2c_read = vemlRead, .i2c_write = vemlWrite};
pub var bme_device: bme.BME280 = .{
    .i2c_read = bmeRead,
    .i2c_write = bmeWrite,
    .delayms = system_timer.delayms
};

const tsl_init: tsl.TSL2591Init = .{
    .i2c_read8 = tslRead8,
    .i2c_read16 = tslRead16,
    .i2c_write = tslWrite,
    .i2c_command = tslCommand,
    .delayms = system_timer.delayms,
    .config = .{}
};

pub var tsl_device: tsl.TSL2591 = .{
    .init_data = &tsl_init
};

pub const panic = std.debug.no_panic;

export fn TMR6_GLOBAL_IRQHandler() callconv(.c) void {
    if (TIMER_INSTANCE.ists.ovfif) {
        TIMER_INSTANCE.ists = .{}; // clear interrupt flag
        timer_interrupt = true;
    }
}

export fn USART1_IRQHandler() callconv(.c) void {
    if (USART_INSTANCE.sts.rdbf) {
        sh.processChar(@truncate(USART_INSTANCE.dt));
    }
}

inline fn initTimer() void {
    TIMER_INSTANCE.div = @truncate(cpu.cpu.current_frequency / 10000 - 1);
    TIMER_INSTANCE.pr = 10000 - 1; //1 second interval
    const v: tmr.TmrIden = .{.ovfien = true};
    TIMER_INSTANCE.iden = v;
    nvic.nvic.enableInterrupt(interrupts.Interrupt.TMR6_GLOBAL.toU8());
    timer_interrupt = false;
}

inline fn initUsart() void {
    USART_PORT.init(USART_TX_PIN_MASK, USART_TX_PIN_INIT);
    USART_PORT.init(USART_RX_PIN_MASK, USART_RX_PIN_INIT);
    USART_INSTANCE.init(115200, cpu.cpu.current_frequency);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.USART1.toU8());
    usart_writer.usart_writer.writeCharFunc = usartWrite;
}

inline fn initI2c() void {
    I2C_PORT.init(I2C_SCL_PIN_MASK|I2C_SDA_PIN_MASK, I2C_PINS_INIT);
    I2C_INSTANCE.initMaster(I2C_SPEED);
    I2C_INSTANCE.enable();
}

inline fn initSpi() void {
    SPI_PORT.init(SPI_TX_PIN_MASK|SPI_CLK_PIN_MASK, SPI_OUT_PINS_INIT);
    SPI_PORT.init(SPI_RX_PIN_MASK, SPI_RX_PIN_INIT);
    SPI_INSTANCE.initMasterSoftwareCs(SPI_BAUD, cpu.cpu.apb2_frequency);
    SPI_CS_PORT.setPins(SPI_CS_PIN_MASK); // cs is 1
    SPI_CS_PORT.init(SPI_CS_PIN_MASK, SPI_CS_PIN_INIT);
}

inline fn initCC1101() void {
    GDO0_PORT.init(GDO0_PIN_MASK, GDO0_PIN_INIT);
    GDO2_PORT.init(GDO2_PIN_MASK, GDO2_PIN_INIT);
}

export fn SystemInit() callconv(.c) void {
    system_timer.delay_init(system_timer.init_div1);
    const v: crm.CrmAhbEn = .{.gpioaen = true, .gpioben = true, .gpiofen = true, .crcen = true};
    crm.crm.ahben = v;
    const v2: crm.CrmApb1 = .{.tmr6 = true, .i2c1 = true};
    crm.crm.apb1en = v2;
    const v3: crm.CrmApb2 = .{.usart1 = true, .spi1 = true};
    crm.crm.apb2en = v3;
    LED_PORT.init(LED_PIN_MASK, LED_INIT);
    initTimer();
    initUsart();
    initI2c();
    initSpi();
    initCC1101();
    if (!wdt.wdt.init(10000)) {
        while (true) {}
    }
}

pub fn usartWrite(byte: u8) void {
    USART_INSTANCE.write(byte);
}

pub inline fn startTimer() void {
    const v: tmr.TmrCtrl1 = .{.tmren = true};
    TIMER_INSTANCE.ctrl1 = v;
}

pub inline fn ledToggle() void {
    LED_PORT.togglePins(LED_PIN_MASK);
}

pub fn i2cScan(channel: usize, address: u10) [2]u8 {
    if (channel != 0)
        return [2]u8{'e', 'c'};
    I2C_INSTANCE.scan(address, I2C_TIMEOUT) catch |err| {
        const e: []const u8 = @errorName(err);
        return [2]u8{e[0], e[1]};
    };
    return [2]u8{0,0};
}

pub fn spi1CsSet(context: *anyopaque, state: bool) bool {
    _ = context;
    if (state) {
        SPI_CS_PORT.setPins(SPI_CS_PIN_MASK);
    } else {
        SPI_CS_PORT.clearPins(SPI_CS_PIN_MASK);
    }
    return true;
}

pub fn spiSendReceive(channel: usize, wdata: []const u8, rdata: []u8) bool {
    _ = channel;
    _ = spi1CsSet(@ptrFromInt(1), false);
    SPI_INSTANCE.sendReceivePoll8(wdata, rdata);
    _ = spi1CsSet(@ptrFromInt(1), true);
    return true;
}

pub fn spi1Write(context: *anyopaque, data: []const u8) bool {
    _ = context;
    SPI_INSTANCE.sendPoll8(data);
    return true;
}

pub fn spi1ReadWrite(context: *anyopaque, data: []u8) bool {
    _ = context;
    SPI_INSTANCE.sendReceivePoll8(data, data);
    return true;
}

pub fn spi1Transfer(context: *anyopaque, wdata: []const u8, rdata: []u8) bool {
    _ = context;
    SPI_INSTANCE.transferPoll8(wdata, rdata);
    return true;
}

pub fn getGdo01(context: *anyopaque) ?bool {
    _ = context;
    return GDO0_PORT.istat & GDO0_PIN_MASK != 0;
}

pub fn getGdo21(context: *anyopaque) ?bool {
    _ = context;
    return GDO2_PORT.istat & GDO2_PIN_MASK != 0;
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

pub fn bmeRead(reg: u8, data: []u8) bool {
    I2C_INSTANCE.transfer(bme.BME280_ADDRESS, &[_]u8{ reg }, data, I2C_TIMEOUT) catch |err| {
        bme_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn bmeWrite(data: []const u8) bool {
    I2C_INSTANCE.write(bme.BME280_ADDRESS, data, I2C_TIMEOUT) catch |err| {
        bme_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn tslRead8(reg: u8) ?u8 {
    var data: [1]u8 = undefined;
    I2C_INSTANCE.transfer(tsl.TSL2591_I2C_ADDRESS, &[_]u8{ reg }, &data, I2C_TIMEOUT) catch |err| {
        tsl_device.i2c_error_name = @errorName(err);
        return null;
    };
    return data[0];
}

pub fn tslRead16(reg: u8) ?u16 {
    var data: [2]u8 = undefined;
    I2C_INSTANCE.transfer(tsl.TSL2591_I2C_ADDRESS, &[_]u8{ reg }, &data, I2C_TIMEOUT) catch |err| {
        tsl_device.i2c_error_name = @errorName(err);
        return null;
    };
    return std.mem.readInt(u16, &data, .little);
}

pub fn tslWrite(reg: u8, value: u8) bool {
    const data: [2]u8 = .{reg, value};
    I2C_INSTANCE.write(tsl.TSL2591_I2C_ADDRESS, &data, I2C_TIMEOUT) catch |err| {
        tsl_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn tslCommand(command: u8) bool {
    const data: [1]u8 = .{command};
    I2C_INSTANCE.write(tsl.TSL2591_I2C_ADDRESS, &data, I2C_TIMEOUT) catch |err| {
        tsl_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn flashWrite(address: usize, data: []u8) flash.FlashError!void {
    flash.flash.flashUnlock();
    defer flash.flash.flashLock();
    try flash.flash.write(address, data);
}

pub fn flashSectorErase(address: usize) flash.FlashError!void {
    flash.flash.flashUnlock();
    defer flash.flash.flashLock();
    try flash.flash.sectorErase(address);
}

pub fn reboot() void {
    scb.scb.reboot();
}

pub fn wdtReset() void {
    wdt.wdt.reload();
}

pub fn getResetCause() []const u8 {
    return "Test";
}