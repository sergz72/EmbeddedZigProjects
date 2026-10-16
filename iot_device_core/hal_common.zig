const std = @import("std");
const hal = @import("hal");
const lcd = @import("lcd");

pub const MAX_ENV_MEASUREMENT = 6;
pub const EnvMeasurement = enum(usize) {
    internal_temperature = 0,
    internal_humidity = 1,
    pressure = 2,
    co2 = 3,
    luminocity = 4,
    external_temperature = 5,
    external_humidity = 6
};

pub var env: [MAX_ENV_MEASUREMENT+1]i24 = .{0x7FFFFF, 0x7FFFFF, 0x7FFFFF, 0x7FFFFF, 0x7FFFFF, 0x7FFFFF, 0x7FFFFF};

pub var lcd_device: lcd.LcdKS0108 = .{
    .write = hal.lcdWrite,
    .set_reset = hal.lcdReset
};

pub const panic = std.debug.no_panic;

pub fn i2cScan(channel: usize, address: u10) [2]u8 {
    if (channel != 0)
        return [2]u8{'e', 'c'};
    hal.i2cScan(address) catch |err| {
        const e: []const u8 = @errorName(err);
        return [2]u8{e[0], e[1]};
    };
    return [2]u8{0,0};
}
