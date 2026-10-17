const std = @import("std");
const shell = @import("shell");
const bme = @import("bme280");

const init_command = shell.ShellCommand{
    .name = "bme_init",
    .help = "bme_init",
    .parameter_mask = 1,
    .handler = initHandler
};

const get_command = shell.ShellCommand{
    .name = "bme_get",
    .help = "bme_get",
    .parameter_mask = 1,
    .handler = getHandler
};

var bme_device: *bme.BME280 = undefined;

fn initHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    bme_device.init() catch |err| {
        try parameters.writer.print("{s} {s}\n", .{@errorName(err), bme_device.i2c_error_name});
        return 1;
    };
    return 0;
}

fn getHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    const result = bme_device.get() catch |err| {
        try parameters.writer.print("{s} {s}\n", .{@errorName(err), bme_device.i2c_error_name});
        return 1;
    };
    try parameters.writer.print("Pressure: {}\ntemperature: {}\nhumidity: {}\n",
                                .{result.pressure, result.temperature, result.humidity});
    return 0;
}

pub fn registerCommands(sh: *shell.Shell, device: *bme.BME280) shell.ShellError!void {
    bme_device = device;
    try sh.registerCommand(&init_command);
    try sh.registerCommand(&get_command);
}
