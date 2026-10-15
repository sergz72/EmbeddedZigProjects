const hal = @import("hal");
const scd4x = @import("scd4x");
const scd4x_commands = @import("scd4x_commands");

pub var scd_device: scd4x.SCD4x = .{.i2c_read = scdRead, .i2c_write = scdWrite};

pub fn init() void {
    scd4x_commands.registerCommands(hal.sh, &scd_device) catch { while (true){} };
}

pub fn scdRead(data: []u8) bool {
    hal.i2cRead(scd4x.SCD4X_SENSOR_ADDR, data) catch |err| {
        scd_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn scdWrite(data: []const u8) bool {
    hal.i2cWrite(scd4x.SCD4X_SENSOR_ADDR, data) catch |err| {
        scd_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}
