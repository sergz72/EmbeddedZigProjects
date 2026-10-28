const std = @import("std");
const shell = @import("shell");
const ds3231 = @import("ds3231");
const generic_rtc = @import("generic_rtc");

const init_command = shell.ShellCommand{
    .name = "ds3231_init",
    .help = "ds3231_init enable_sqw(0|1)",
    .parameter_mask = 2,
    .handler = initHandler
};

const date_get_command = shell.ShellCommand{
    .name = "ds3231_date_get",
    .help = "ds3231_date_get",
    .parameter_mask = 1,
    .handler = dateGetHandler
};

const date_set_command = shell.ShellCommand{
    .name = "ds3231_date_set",
    .help = "ds3231_date_set year month day hour minute second",
    .parameter_mask = 1 << 6,
    .handler = dateSetHandler
};

var device: *const ds3231.DS3231 = undefined;

fn initHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    const enable_sqw = std.fmt.parseInt(usize, parameters.argv[0], 10) catch {
        _ = try parameters.writer.write("invalid value\n");
        return 1;
    };

    device.init(enable_sqw != 0) catch |err| {
        try parameters.writer.print("{s} {s}\n", .{ @errorName(err), device.i2c_error_name});
        return 2;
    };

    return 0;
}

fn dateGetHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    var rtc: generic_rtc.RtcData = undefined;
    device.get(&rtc) catch |err| {
        try parameters.writer.print("{s} {s}\n", .{ @errorName(err), device.i2c_error_name});
        return 1;
    };
    try parameters.writer.print("{d}.{s}.{d:0>2} {d}:{d:0>2}:{d:0>2} weekday={s} yday={d}\n", .{
        rtc.day, @tagName(rtc.month), rtc.year, rtc.hours, rtc.minutes, rtc.seconds, @tagName(rtc.wday), rtc.yday
    });
    return 0;
}

fn dateSetHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    var rtc: generic_rtc.RtcData = undefined;
    rtc.year = std.fmt.parseInt(usize, parameters.argv[0], 10) catch {
        _ = try parameters.writer.write("invalid value\n");
        return 1;
    };
    const month = std.fmt.parseInt(u8, parameters.argv[1], 10) catch {
        _ = try parameters.writer.write("invalid month\n");
        return 3;
    };
    rtc.setMonth(month) catch {
        _ = try parameters.writer.write("invalid month\n");
        return 4;
    };
    rtc.day = std.fmt.parseInt(u8, parameters.argv[2], 10) catch {
        _ = try parameters.writer.write("invalid day\n");
        return 5;
    };
    rtc.hours = std.fmt.parseInt(u8, parameters.argv[3], 10) catch {
        _ = try parameters.writer.write("invalid hour\n");
        return 6;
    };
    rtc.minutes = std.fmt.parseInt(u8, parameters.argv[4], 10) catch {
        _ = try parameters.writer.write("invalid minute\n");
        return 7;
    };
    rtc.seconds = std.fmt.parseInt(u8, parameters.argv[5], 10) catch {
        _ = try parameters.writer.write("invalid second\n");
        return 8;
    };
    rtc.validate() catch |err| {
        try parameters.writer.print("{s}\n", .{ @errorName(err) });
        return 9;
    };
    device.setDateTime(&rtc) catch |err| {
        try parameters.writer.print("{s} {s}\n", .{ @errorName(err), device.i2c_error_name});
        return 10;
    };
    return 0;
}

pub fn registerCommands(sh: *shell.Shell, dev: *const ds3231.DS3231) shell.ShellError!void {
    device = dev;
    try sh.registerCommand(&init_command);
    try sh.registerCommand(&date_get_command);
    try sh.registerCommand(&date_set_command);
}
