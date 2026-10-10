const std = @import("std");
const shell = @import("shell");

var i2c_scan: *const fn(usize, u10) [2]u8 = undefined;

const scan_command = shell.ShellCommand{
    .name = "i2c_scan",
    .help = "i2c_scan channel",
    .parameter_mask = 2,
    .handler = scanHandler
};

fn scanHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    const channel = std.fmt.parseInt(usize, parameters.argv[0], 10) catch {
        _ = try parameters.writer.write("invalid channel\n");
        return 1;
    };

    _ = try parameters.writer.write("     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f\n");
    _ = try parameters.writer.write("00:   ");

    for (1..0x7F) |address| {
        if ((address & 0x0F) == 0) {
            try parameters.writer.print("\n{x:2}:", .{address});
        }
        const result = i2c_scan(channel, @truncate(address));
        if (result[0] == 0) {
            try parameters.writer.print(" {x:2}", .{address});
        } else {
            _ = try parameters.writer.print(" {s}", .{&result});
        }
    }

    return 0;
}

pub fn registerCommands(sh: *shell.Shell, scan: *const fn(usize, u10) [2]u8) shell.ShellError!void {
    i2c_scan = scan;
    try sh.registerCommand(&scan_command);
}
