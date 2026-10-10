const std = @import("std");
const shell = @import("shell");
const alloc = @import("allocator");

const free_command = shell.ShellCommand{
    .name = "free",
    .help = "free",
    .parameter_mask = 1,
    .handler = free_handler
};

fn free_handler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    try parameters.writer.print("{} bytes free\n", .{alloc.getFreeSize()});
    return 0;
}

pub fn registerCommands(sh: *shell.Shell) shell.ShellError!void {
    try sh.registerCommand(&free_command);
}