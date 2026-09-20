const std = @import("std");
const shell = @import("shell");
const allocator = @import("allocator");
const spi = @import("spi");
const utils = @import("utils");

const free_command = shell.ShellCommand{
    .name = "free",
    .help = "free",
    .parameter_mask = 1,
    .handler = free_handler
};

const spi_trfr_command = shell.ShellCommand{
    .name = "spi_trfr",
    .help = "spi_trfr data",
    .parameter_mask = 2,
    .handler = spi_trfr_handler
};

fn free_handler(argc: usize, argv: [][]const u8, writer: *std.Io.Writer) std.Io.Writer.Error!isize {
    _ = argc;
    _ = argv;
    try writer.print("{} bytes free\n", .{allocator.get_free_size()});
    return 0;
}

var spi_trfr_buffer: [21]u8 = undefined;
var spi_trfr_buffer_out: [64]u8 = undefined;

fn spi_trfr_handler(argc: usize, argv: [][]const u8, writer: *std.Io.Writer) std.Io.Writer.Error!isize {
    _ = argc;
    if (argv[0].len & 1 != 0 or argv[0].len / 2 > spi_trfr_buffer.len) {
        _ = try writer.write("invalid data length\n");
        return 1;
    }
    const bytes = std.fmt.hexToBytes(&spi_trfr_buffer, argv[0]) catch {
        _ = try writer.write("invalid data\n");
        return 1;
    };
    spi.spi2.send_receive_poll8(bytes, bytes);
    const idx = utils.bytesToHex(bytes, &spi_trfr_buffer_out);
    spi_trfr_buffer_out[idx-1] = '\n';
    _ = try writer.write(spi_trfr_buffer_out[0..idx]);
    return 0;
}

pub fn register_system_commands(sh: *shell.Shell) isize {
    _ = sh.register_command(&free_command);
    return sh.register_command(&spi_trfr_command);
}