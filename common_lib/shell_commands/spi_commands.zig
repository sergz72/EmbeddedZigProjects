const std = @import("std");
const shell = @import("shell");
const utils = @import("utils");

const SendReceiveFunc = *const fn (usize, []const u8, []u8) bool;

const trfr_command = shell.ShellCommand{
    .name = "spi_trfr",
    .help = "spi_trfr channel data",
    .parameter_mask = 4,
    .handler = trfrHandler
};

var spi_trfr_buffer: [21]u8 = undefined;
var spi_trfr_buffer_out: [64]u8 = undefined;
var send_receive: SendReceiveFunc = undefined;

fn trfrHandler(argc: usize, argv: [][]const u8, writer: *std.Io.Writer) std.Io.Writer.Error!isize {
    _ = argc;

    const channel = std.fmt.parseInt(usize, argv[0], 10) catch {
        _ = try writer.write("invalid channel\n");
        return 1;
    };

    if (argv[1].len & 1 != 0 or argv[1].len / 2 > spi_trfr_buffer.len) {
        _ = try writer.write("invalid data length\n");
        return 1;
    }
    const bytes = std.fmt.hexToBytes(&spi_trfr_buffer, argv[1]) catch {
        _ = try writer.write("invalid data\n");
        return 2;
    };
    if (!send_receive(channel, bytes, bytes)) {
        _ = try writer.write("spi transfer error\n");
        return 3;
    }
    const idx = utils.bytesToHex(bytes, &spi_trfr_buffer_out);
    spi_trfr_buffer_out[idx-1] = '\n';
    _ = try writer.write(spi_trfr_buffer_out[0..idx]);
    return 0;
}

pub fn registerCommands(sh: *shell.Shell, send_receive_func: SendReceiveFunc) shell.ShellError!void {
    send_receive = send_receive_func;
    try sh.registerCommand(&trfr_command);
}
