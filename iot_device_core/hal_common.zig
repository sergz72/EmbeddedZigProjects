const std = @import("std");
const hal = @import("hal");
const lcd = @import("lcd");

pub var lcd_device: lcd.LcdKS0108 = .{
    .write = hal.lcdWrite,
    .set_reset = hal.lcdReset
};

pub const panic = std.debug.no_panic;

pub fn i2cScan(channel: usize, address: u10) [2]u8 {
    if (channel != 0)
        return [2]u8{'e', 'c'};
    hal.i2cScan(address) catch |err| {
        const e_no: u8 = @truncate(@intFromError(err));
        return [2]u8{'e', '0' + e_no};
    };
    return [2]u8{0,0};
}
