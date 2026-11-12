const std = @import("std");
const system_timer = @import("system_timer");
const board = @import("board");
const rcc = @import("rcc");
const tim = @import("tim");
const cpu = @import("cpu");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const flash = @import("flash");
const scb = @import("scb");
const shell = @import("shell");
const rng = @import("rng");
const scd4x = @import("scd4x");
const veml = @import("veml7700");

const TIMER_INSTANCE = tim.tim7;

var led_status: bool = undefined;

pub var timer_interrupt: bool = undefined;
pub var sh: *shell.Shell = undefined;
pub var scd_device: scd4x.SCD4x = .{.i2c_read = scdRead, .i2c_write = scdWrite};
pub var veml_device: veml.VEML7700 = .{.i2c_read = vemlRead, .i2c_write = vemlWrite};

export fn TIM7_IRQHandler() callconv(.c) void {
    if (TIMER_INSTANCE.sr.u) {
        timer_interrupt = true;
        // clear interrupt flag
        TIMER_INSTANCE.sr = tim.Timr{};
    }
}

fn usartCallback(data: u8) void {
    sh.processChar(0, data);
}

inline fn initTimer() void {
    rcc.rcc.hpenr.apb1l.tim7en = true;
    TIMER_INSTANCE.psc = @truncate(cpu.cpu.pclk1_frequency / 10000 - 1);
    TIMER_INSTANCE.arr = 10000 - 1; //1 second interval
    TIMER_INSTANCE.dier = .{.u = true};
    nvic.nvic.enableInterrupt(interrupts.Interrupt.TIM7.toU8());
    timer_interrupt = false;
}

pub inline fn startTimer() void {
    TIMER_INSTANCE.cr1 = .{.cen = true, .arpe = true};
}

export fn SystemInit() callconv(.c) void {
    led_status = false;
    board.init(false, 48000000, rcc.PllCharacteristicsH563);
    board.initUsart(115200, &usartCallback, true);
    initTimer();
    rcc.rcc.hsi48On();
    rng.rng.init();
    rcc.rcc.hpenr.ahb1.crcen = true;
    board.initArduinoI2c();
    board.initArduinoSPI(1000000, .full_duplex);
}

pub fn ledToggle() void {
    led_status = !led_status;
    if (led_status) {
        board.ledRedOn();
    } else {
        board.ledRedOff();
    }
}

pub fn flashWrite(address: usize, data: []u8) flash.FlashError!void {
    _ = address;
    _ = data;
    return flash.FlashError.Timeout;
}

pub fn flashSectorErase(address: usize) flash.FlashError!void {
    _ = address;
    return flash.FlashError.Timeout;
}

pub fn reboot() void {
    scb.scb.reboot();
}

pub fn wdtReset() void {
    //todo
}

pub fn getResetCause() []const u8 {
    return rcc.rcc.getResetCause();
}

pub fn i2cScan(channel: usize, address: u10) [2]u8 {
    if (channel != 0)
        return [2]u8{'e', 'c'};
    board.I2C_INSTANCE.scan(address, board.I2C_TIMEOUT) catch |err| {
        const e: []const u8 = @errorName(err);
        return [2]u8{e[0], e[1]};
    };
    return [2]u8{0,0};
}

pub fn scdRead(data: []u8) bool {
    board.I2C_INSTANCE.read(scd4x.SCD4X_SENSOR_ADDR, data, board.I2C_TIMEOUT) catch |err| {
        scd_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn scdWrite(data: []const u8) bool {
    board.I2C_INSTANCE.write(scd4x.SCD4X_SENSOR_ADDR, data, board.I2C_TIMEOUT) catch |err| {
        scd_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn vemlRead(reg: u8) ?u16 {
    var rdata: [2]u8 = undefined;
    board.I2C_INSTANCE.transfer(veml.VEML7700_I2C_ADDRESS, &[_]u8{ reg }, &rdata, board.I2C_TIMEOUT) catch |err| {
        veml_device.i2c_error_name = @errorName(err);
        return null;
    };
    return std.mem.readInt(u16, &rdata, .little);
}

pub fn vemlWrite(reg: u8, data: u16) bool {
    const wdata: []const u8 = &.{reg, @truncate(data), @truncate(data >> 8)};
    board.I2C_INSTANCE.write(veml.VEML7700_I2C_ADDRESS, wdata, board.I2C_TIMEOUT) catch |err| {
        veml_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn spiSendReceive(channel: usize, wdata: []const u8, rdata: []u8) bool {
    _ = channel;
    board.arduinoSpiCsSet(false);
    board.SPI_INSTANCE.sendReceivePoll8(wdata, rdata);
    board.arduinoSpiCsSet(true);
    return true;
}
