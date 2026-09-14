const std = @import("std");
const shell = @import("shell");
const allocator = @import("allocator");
const dac = @import("dac");
const spi = @import("spi");

const free_command = shell.ShellCommand{
    .name = "free",
    .help = "free",
    .parameter_mask = 1,
    .handler = free_handler
};

const dac_command = shell.ShellCommand{
    .name = "dac",
    .help = "dac value",
    .parameter_mask = 2,
    .handler = dac_handler
};

fn free_handler(argc: usize, argv: [][]const u8, writer: *std.Io.Writer) std.Io.Writer.Error!isize {
    _ = argc;
    _ = argv;
    try writer.print("{} bytes free\n", .{allocator.get_free_size()});
    return 0;
}

fn dac_handler(argc: usize, argv: [][]const u8, writer: *std.Io.Writer) std.Io.Writer.Error!isize {
    _ = argc;
    const v = std.fmt.parseInt(usize, argv[0], 10) catch {
        _ = try writer.write("invalid number\n");
        return 1;
    };
    if (v > 4095) {
        _ = try writer.write("value is out of range\n");
        return 2;
    }
    dac.dac.ch2.r12bdhr = v;
    return 0;
}

pub fn register_system_commands(sh: *shell.Shell) isize {
    _ = sh.register_command(&free_command);
    return sh.register_command(&dac_command);
}