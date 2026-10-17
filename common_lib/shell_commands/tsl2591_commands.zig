const std = @import("std");
const shell = @import("shell");
const tsl = @import("tsl2591");

const init_command = shell.ShellCommand{
    .name = "tsl_init",
    .help = "tsl_init",
    .parameter_mask = 1,
    .handler = initHandler
};

const get_command = shell.ShellCommand{
    .name = "tsl_get",
    .help = "tsl_get",
    .parameter_mask = 1,
    .handler = getHandler
};

var tsl_device: *tsl.TSL2591 = undefined;

fn initHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    tsl_device.init() catch |err| {
        try parameters.writer.print("{s} {s}\n", .{@errorName(err), tsl_device.i2c_error_name});
        return 1;
    };
    return 0;
}

fn getHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    var result: tsl.TSL2591Result = undefined;
    tsl_device.measure(&result) catch |err| {
        try parameters.writer.print("{s} {s}\n", .{@errorName(err), tsl_device.i2c_error_name});
        return 1;
    };
    try parameters.writer.print("Lux: {} gain: {s} tries: {}\n", .{result.lux, @tagName(result.gain), result.tries});
    return 0;
}

pub fn registerCommands(sh: *shell.Shell, device: *tsl.TSL2591) shell.ShellError!void {
    tsl_device = device;
    try sh.registerCommand(&init_command);
    try sh.registerCommand(&get_command);
}
