const std = @import("std");
const shell = @import("shell");
const utils = @import("utils");
const spi_memory = @import("spi_memory");

const SendReceiveFunc = *const fn ([]const u8, []u8) bool;

const trfr_command = shell.ShellCommand{
    .name = "spi_trfr",
    .help = "spi_trfr data",
    .parameter_mask = 2,
    .handler = trfrHandler
};

const id_command = shell.ShellCommand{
    .name = "spi_mem_id",
    .help = "spi_mem_id",
    .parameter_mask = 1,
    .handler = idHandler
};

const reset_command = shell.ShellCommand{
    .name = "spi_mem_reset",
    .help = "spi_mem_reset",
    .parameter_mask = 1,
    .handler = resetHandler
};

var spi_trfr_buffer: [21]u8 = undefined;
var spi_trfr_buffer_out: [64]u8 = undefined;
var chip: spi_memory.SpiMemory = undefined;
var send_receive: SendReceiveFunc = undefined;

fn trfrHandler(argc: usize, argv: [][]const u8, writer: *std.Io.Writer) std.Io.Writer.Error!isize {
    _ = argc;
    if (argv[0].len & 1 != 0 or argv[0].len / 2 > spi_trfr_buffer.len) {
        _ = try writer.write("invalid data length\n");
        return 1;
    }
    const bytes = std.fmt.hexToBytes(&spi_trfr_buffer, argv[0]) catch {
        _ = try writer.write("invalid data\n");
        return 2;
    };
    if (!send_receive(bytes, bytes)) {
        _ = try writer.write("spi transfer error\n");
        return 3;
    }
    const idx = utils.bytesToHex(bytes, &spi_trfr_buffer_out);
    spi_trfr_buffer_out[idx-1] = '\n';
    _ = try writer.write(spi_trfr_buffer_out[0..idx]);
    return 0;
}

fn idHandler(argc: usize, argv: [][]const u8, writer: *std.Io.Writer) std.Io.Writer.Error!isize {
    _ = argc;
    _ = argv;
    const id = chip.readId();
    if (id == null) {
        _ = try writer.write("read id error\n");
        return 1;
    }
    try writer.print("0x{x:0>8}\n", .{id.?});
    return 0;
}

fn resetHandler(argc: usize, argv: [][]const u8, writer: *std.Io.Writer) std.Io.Writer.Error!isize {
    _ = argc;
    _ = argv;
    if (!chip.reset()) {
        _ = try writer.write("reset error\n");
        return 1;
    }
    return 0;
}

pub fn registerCommands(sh: *shell.Shell, spi_chip_init: *const spi_memory.SpiMemoryInit, send_receive_func: SendReceiveFunc) shell.ShellError!void {
    chip.init(spi_chip_init);
    send_receive = send_receive_func;
    try sh.registerCommand(&reset_command);
    try sh.registerCommand(&id_command);
    try sh.registerCommand(&trfr_command);
}
