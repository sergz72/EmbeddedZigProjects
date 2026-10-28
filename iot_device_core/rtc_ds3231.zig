const ds3231 = @import("ds3231");
const ds3231_commands = @import("ds3231_commands");
const hal = @import("hal");
const hal_common = @import("hal_common");
const ui = @import("ui");

var rtc: ds3231.DS3231 = .{.i2c_write = ds3231Write, .i2c_transfer = ds3231Transfer};

pub fn init() ds3231.DS3231Error!void {
    if (hal.INIT_DEVICES) {
        try rtc.init(true);
        try rtc.get(&hal_common.rtc_data);
    }
    ds3231_commands.registerCommands(hal.sh, &rtc) catch { while (true){} };
}

pub fn ds3231Transfer(reg: u8, data: []u8) bool {
    hal.i2cTransfer(ds3231.DS3231_I2C_ADDRESS, &[_]u8{ reg }, data) catch |err| {
        rtc.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn ds3231Write(data: []const u8) bool {
    hal.i2cWrite(ds3231.DS3231_I2C_ADDRESS, data) catch |err| {
        rtc.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}
