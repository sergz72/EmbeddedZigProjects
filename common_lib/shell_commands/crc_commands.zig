const std = @import("std");
const shell = @import("shell");
const utils = @import("utils");

const crc_command = shell.ShellCommand{
    .name = "crc",
    .help = "crc size data",
    .parameter_mask = 4,
    .handler = crcHandler
};

pub const Generators = struct {
    crc8: ?*const fn([]const u8) u8,
    crc16: ?*const fn([]const u8) u16,
    crc32: ?*const fn([]const u8) u32
};

var generators: *const Generators = undefined;
var buffer: [32]u8 = undefined;

fn crcHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    const size = std.fmt.parseInt(usize, parameters.argv[0], 10) catch {
        try parameters.writer.print("invalid size {s}\n", .{parameters.argv[0]});
        return 1;
    };
    if (size != 8 and size != 16 and size != 32) {
        _ = try parameters.writer.write("invalid size\n");
        return 2;
    }
    if (parameters.argv[1].len & 1 != 0 or parameters.argv[1].len / 2 > buffer.len) {
        _ = try parameters.writer.write("invalid data length\n");
        return 3;
    }
    const bytes = std.fmt.hexToBytes(&buffer, parameters.argv[1]) catch {
        _ = try parameters.writer.write("invalid data\n");
        return 4;
    };
    switch (size) {
        8 => {
            if (generators.crc8) |g| {
                const crc = g(bytes);
                _ = try parameters.writer.print("crc8: {x:0>2}\n", .{crc});
            } else {
                _ = try parameters.writer.write("crc8 generator not available\n");
                return 5;
            }
        },
        16 => {
            if (generators.crc16) |g| {
                const crc = g(bytes);
                _ = try parameters.writer.print("crc16: {x:0>4}\n", .{crc});
            } else {
                _ = try parameters.writer.write("crc16 generator not available\n");
                return 6;
            }
        },
        32 => {
            if (generators.crc32) |g| {
                const crc = g(bytes);
                _ = try parameters.writer.print("crc32: {x:0>8}\n", .{crc});
            } else {
                _ = try parameters.writer.write("crc32 generator not available\n");
                return 7;
            }
        },
        else => return 1
    }
    return 0;
}

pub fn registerCommands(sh: *shell.Shell, gens: *const Generators) shell.ShellError!void {
    generators = gens;
    try sh.registerCommand(&crc_command);
}
