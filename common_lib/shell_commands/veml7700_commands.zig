const std = @import("std");
const shell = @import("shell");
const veml = @import("veml7700");

const init_command = shell.ShellCommand{
    .name = "veml_init",
    .help = "veml_init",
    .parameter_mask = 1,
    .handler = initHandler
};

const get_command = shell.ShellCommand{
    .name = "veml_get",
    .help = "veml_get",
    .parameter_mask = 1,
    .handler = getHandler
};

var veml_device: *veml.VEML7700 = undefined;

fn initHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    veml_device.init() catch |err| {
        try parameters.writer.print("{s} {s}\n", .{@errorName(err), veml_device.i2c_error_name});
        return 1;
    };
    return 0;
}

fn getHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    var result: veml.VEML7700Result = undefined;
    veml_device.measure(&result, false) catch |err| {
        try parameters.writer.print("{s} {s}\n", .{@errorName(err), veml_device.i2c_error_name});
        return 1;
    };
    try parameters.writer.print("Lux: {} gain: {s} tries: {}\n", .{result.lux, @tagName(result.gain), result.tries});
    return 0;
}

pub fn registerCommands(sh: *shell.Shell, device: *veml.VEML7700) shell.ShellError!void {
    veml_device = device;
    try sh.registerCommand(&init_command);
    try sh.registerCommand(&get_command);
}
