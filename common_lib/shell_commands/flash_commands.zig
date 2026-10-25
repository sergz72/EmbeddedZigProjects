const std = @import("std");
const shell = @import("shell");
const hal = @import("hal");
const utils = @import("utils");

var write_buffer: [32]u8 = undefined;

const flash_read_command = shell.ShellCommand{
    .name = "flash_read",
    .help = "flash read address size",
    .parameter_mask = 4,
    .handler = flashReadHandler
};

const flash_sector_erase_command = shell.ShellCommand{
    .name = "flash_sector_erase",
    .help = "flash sector_erase address",
    .parameter_mask = 2,
    .handler = flashSectorEraseHandler
};

const flash_write_command = shell.ShellCommand{
    .name = "flash_write",
    .help = "flash write address data",
    .parameter_mask = 4,
    .handler = flashWriteHandler
};

fn flashReadHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    const address = std.fmt.parseInt(usize, parameters.argv[0], 0) catch {
        try parameters.writer.print("invalid address {s}\n", .{parameters.argv[0]});
        return 1;
    };
    const size = std.fmt.parseInt(usize, parameters.argv[1], 0) catch {
        try parameters.writer.print("invalid size {s}\n", .{parameters.argv[1]});
        return 1;
    };
    const ptr: [*]const u8 = @ptrFromInt(address);
    const data = ptr[0..size];
    try utils.printHex(data, parameters.writer);
    return 0;
}

fn flashSectorEraseHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    const address = std.fmt.parseInt(usize, parameters.argv[0], 0) catch {
        _ = try parameters.writer.write("invalid address\n");
        return 1;
    };

    hal.flashSectorErase(address) catch |err| {
        try parameters.writer.print("flash sector erase error {s}\n", .{@errorName(err)});
        return 4;
    };
    return 0;
}

fn flashWriteHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    const address = std.fmt.parseInt(usize, parameters.argv[0], 0) catch {
        _ = try parameters.writer.write("invalid address\n");
        return 1;
    };

    if (parameters.argv[1].len & 1 != 0 or parameters.argv[1].len / 2 > write_buffer.len) {
        _ = try parameters.writer.write("invalid data length\n");
        return 2;
    }
    const bytes = std.fmt.hexToBytes(&write_buffer, parameters.argv[1]) catch {
        _ = try parameters.writer.write("invalid data\n");
        return 3;
    };
    hal.flashWrite(address, bytes) catch |err| {
        try parameters.writer.print("flash write error {s}\n", .{@errorName(err)});
        return 4;
    };
    return 0;
}
    
pub fn registerCommands(sh: *shell.Shell) shell.ShellError!void {
    try sh.registerCommand(&flash_read_command);
    try sh.registerCommand(&flash_sector_erase_command);
    try sh.registerCommand(&flash_write_command);
}
