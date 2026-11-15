const std = @import("std");
const board = @import("board");
const ctimer = @import("ctimer");
const syscon = @import("syscon");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const shell = @import("shell");
const scb = @import("scb");
const fmu = @import("fmu");
const scd4x = @import("scd4x");
const veml = @import("veml7700");

pub var timer_interrupt: bool = undefined;
pub var sh: *shell.Shell = undefined;
pub var scd_device: scd4x.SCD4x = .{.i2c_read = scdRead, .i2c_write = scdWrite};
pub var veml_device: veml.VEML7700 = .{.i2c_read = vemlRead, .i2c_write = vemlWrite};

pub const TIMER_INSTANCE = ctimer.ctimer0;

fn uart_callback(data: u8) void {
    sh.processChar(0, data);
}

fn initTimer() void {
    timer_interrupt = false;
    syscon.syscon0.ahbclkctrlset1.timer0 = true;
    syscon.syscon0.ctimerclksel[0] = .pll0;
    syscon.syscon0.ctimerclkdiv[0] = syscon.Clkdiv{.halt = false, .div = 47};
    TIMER_INSTANCE.pr = 1000;
    TIMER_INSTANCE.mr[0] = 1000;
    TIMER_INSTANCE.mcr = ctimer.Mcr{.mr0i = true, .mr0r = true};
    nvic.nvic.enableInterrupt(interrupts.Interrupt.CTIMER0.toU8());
}

export fn SystemInit() callconv(.c) void {
    board.init();
    board.initUart(115200, uart_callback);
    board.initArduinoI2c();
    board.initArduinoSpi();
    board.initFlashSpi();
    board.initLightSensor();
    board.initSensorI2c();
    initTimer();
}

pub fn startTimer() void {
    TIMER_INSTANCE.tcr = ctimer.Tcr{.cen = true};
}

pub fn flashWrite(address: usize, data: []u8) fmu.FmuError!void {
    //flash.flash.flashUnlock();
    //defer flash.flash.flashLock();
    //try flash.flash.write(address, data);
    _ = address;
    _ = data;
    return fmu.FmuError.Timeout;
}

pub fn flashSectorErase(address: usize) fmu.FmuError!void {
    //flash.flash.flashUnlock();
    //defer flash.flash.flashLock();
    //try flash.flash.sectorErase(address);
    _ = address;
    return fmu.FmuError.Timeout;
}

pub fn reboot() void {
    scb.scb.reboot();
}

pub fn wdtReset() void {
    //iwdg.iwdg.reload();
}

pub fn getResetCause() []const u8 {
    return "Unknown";//rcc.rcc.getResetCause();
}

pub fn i2cScan(channel: usize, address: u10) [2]u8 {
    if (channel != 0)
        return [2]u8{'e', 'c'};
    board.ARDUINO_I2C_INSTANCE.scan(@truncate(address), board.I2C_TIMEOUT) catch |err| {
        const e: []const u8 = @errorName(err);
        return [2]u8{e[0], e[1]};
    };
    return [2]u8{0,0};
}

pub fn spiSendReceive(channel: usize, wdata: []const u8, rdata: []u8) bool {
    _ = channel;
    //board.arduinoSpiCsSet(false);
    //board.SPI_INSTANCE.sendReceivePoll8(wdata, rdata);
    //board.arduinoSpiCsSet(true);
    //return true;
    _ = wdata;
    _ = rdata;
    return false;
}

pub fn scdRead(data: []u8) bool {
    board.ARDUINO_I2C_INSTANCE.read(scd4x.SCD4X_SENSOR_ADDR, data, board.I2C_TIMEOUT) catch |err| {
        scd_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn scdWrite(data: []const u8) bool {
    board.ARDUINO_I2C_INSTANCE.write(scd4x.SCD4X_SENSOR_ADDR, data, board.I2C_TIMEOUT) catch |err| {
        scd_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn vemlRead(reg: u8) ?u16 {
    var rdata: [2]u8 = undefined;
    board.ARDUINO_I2C_INSTANCE.transfer(veml.VEML7700_I2C_ADDRESS, &[_]u8{ reg }, &rdata, board.I2C_TIMEOUT) catch |err| {
        veml_device.i2c_error_name = @errorName(err);
        return null;
    };
    return std.mem.readInt(u16, &rdata, .little);
}

pub fn vemlWrite(reg: u8, data: u16) bool {
    const wdata: []const u8 = &.{reg, @truncate(data), @truncate(data >> 8)};
    board.ARDUINO_I2C_INSTANCE.write(veml.VEML7700_I2C_ADDRESS, wdata, board.I2C_TIMEOUT) catch |err| {
        veml_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

export fn CTIMER0_IRQHandler() callconv(.c) void {
    if (TIMER_INSTANCE.ir.mr0int) {
        TIMER_INSTANCE.ir = ctimer.Ir{.mr0int = true};
        timer_interrupt = true;
    }
}