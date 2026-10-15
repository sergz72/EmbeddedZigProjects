const std = @import("std");
const hal = @import("hal");
const veml7700_commands = @import("veml7700_commands");
const veml = @import("veml7700");

pub var veml_device: veml.VEML7700 = .{.i2c_read = vemlRead, .i2c_write = vemlWrite};

pub fn init() void {
    veml_device.init() catch { while (true){} };
    veml7700_commands.registerCommands(hal.sh, &veml_device) catch { while (true){} };
}

pub fn vemlRead(reg: u8) ?u16 {
    var rdata: [2]u8 = undefined;
    hal.i2cTransfer(veml.VEML7700_I2C_ADDRESS, &[_]u8{ reg }, &rdata) catch |err| {
        veml_device.i2c_error_name = @errorName(err);
        return null;
    };
    return std.mem.readInt(u16, &rdata, .little);
}

pub fn vemlWrite(reg: u8, data: u16) bool {
    const wdata: []const u8 = &.{reg, @truncate(data), @truncate(data >> 8)};
    hal.i2cWrite(veml.VEML7700_I2C_ADDRESS, wdata) catch |err| {
        veml_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}
