const std = @import("std");
const shell = @import("shell");
const alloc = @import("allocator");
const hal = @import("hal");
const system_timer = @import("system_timer");

const free_command = shell.ShellCommand{
    .name = "free",
    .help = "free",
    .parameter_mask = 1,
    .handler = freeHandler
};

const reboot_command = shell.ShellCommand{
    .name = "reboot",
    .help = "reboot",
    .parameter_mask = 1,
    .handler = rebootHandler
};

const delay_command = shell.ShellCommand{
    .name = "delay",
    .help = "delay ms",
    .parameter_mask = 2,
    .handler = delayHandler
};

fn freeHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    try parameters.writer.print("{} bytes free\n", .{alloc.getFreeSize()});
    return 0;
}

fn rebootHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    _ = parameters;
    hal.reboot();
    return 0;
}

fn delayHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    const ms = std.fmt.parseInt(u8, parameters.argv[0], 10) catch {
        try parameters.writer.print("invalid number {s}\n", .{parameters.argv[0]});
        return 1;
    };
    system_timer.delayms(ms);
    return 0;
}

pub fn registerCommands(sh: *shell.Shell) shell.ShellError!void {
    try sh.registerCommand(&free_command);
    try sh.registerCommand(&reboot_command);
    try sh.registerCommand(&delay_command);
}