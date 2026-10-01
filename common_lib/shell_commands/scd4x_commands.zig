const std = @import("std");
const shell = @import("shell");
const scd4x = @import("scd4x");

const get_command = shell.ShellCommand{
    .name = "scd_get",
    .help = "scd_get",
    .parameter_mask = 1,
    .handler = getHandler
};

var scd_device: *scd4x.SCD4x = undefined;

fn getHandler(argc: usize, argv: [][]const u8, writer: *std.Io.Writer) std.Io.Writer.Error!isize {
    _ = argc;
    _ = argv;
    const result = scd_device.get() catch |err| {
        try writer.print("{s}\n", .{@errorName(err)});
        return 1;
    };
    try writer.print("CO2: {}\ntemperature: {}\nhumidity: {}\n",
                .{result.co2, result.temperature_x100, result.humidity_x100});
    return 0;
}

pub fn registerCommands(sh: *shell.Shell, device: *scd4x.SCD4x) shell.ShellError!void {
    scd_device = device;
    try sh.registerCommand(&get_command);
}
