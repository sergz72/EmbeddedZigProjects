const std = @import("std");
const shell = @import("shell");
const rtc = @import("rtc");
const generic_rtc = @import("generic_rtc");

const date_get_command = shell.ShellCommand{
    .name = "date_get",
    .help = "date_get",
    .parameter_mask = 1,
    .handler = dateGetHandler
};

const date_set_command = shell.ShellCommand{
    .name = "date_set",
    .help = "date_set year month day hour minute second",
    .parameter_mask = 1 << 6,
    .handler = dateSetHandler
};

fn dateGetHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    var rtc_data: generic_rtc.RtcData = undefined;
    rtc.rtc.getTime(&rtc_data);
    try parameters.writer.print("{d}.{s}.{d:0>2} {d}:{d:0>2}:{d:0>2} weekday={s} yday={d}\n", .{
        rtc_data.day, @tagName(rtc_data.month), rtc_data.year, rtc_data.hours, rtc_data.minutes,
        rtc_data.seconds, @tagName(rtc_data.wday), rtc_data.yday
    });
    return 0;
}

fn dateSetHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    var rtc_data: generic_rtc.RtcData = undefined;
    rtc_data.year = std.fmt.parseInt(usize, parameters.argv[0], 10) catch {
        _ = try parameters.writer.write("invalid value\n");
        return 1;
    };
    const month = std.fmt.parseInt(u8, parameters.argv[1], 10) catch {
        _ = try parameters.writer.write("invalid month\n");
        return 3;
    };
    rtc_data.setMonth(month) catch {
        _ = try parameters.writer.write("invalid month\n");
        return 4;
    };
    rtc_data.day = std.fmt.parseInt(u8, parameters.argv[2], 10) catch {
        _ = try parameters.writer.write("invalid day\n");
        return 5;
    };
    rtc_data.hours = std.fmt.parseInt(u8, parameters.argv[3], 10) catch {
        _ = try parameters.writer.write("invalid hour\n");
        return 6;
    };
    rtc_data.minutes = std.fmt.parseInt(u8, parameters.argv[4], 10) catch {
        _ = try parameters.writer.write("invalid minute\n");
        return 7;
    };
    rtc_data.seconds = std.fmt.parseInt(u8, parameters.argv[5], 10) catch {
        _ = try parameters.writer.write("invalid second\n");
        return 8;
    };
    rtc_data.validate() catch |err| {
        try parameters.writer.print("{s}\n", .{ @errorName(err) });
        return 9;
    };
    rtc.rtc.setTime(&rtc_data) catch |err| {
        try parameters.writer.print("{s}\n", .{ @errorName(err)});
        return 10;
    };
    return 0;
}

pub fn registerCommands(sh: *shell.Shell) shell.ShellError!void {
    try sh.registerCommand(&date_get_command);
    try sh.registerCommand(&date_set_command);
}
