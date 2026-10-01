const std = @import("std");
const shell = @import("shell");
const utils = @import("utils");
const spi_memory = @import("spi_memory");

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

var chip: spi_memory.SpiMemory = undefined;

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

pub fn registerCommands(sh: *shell.Shell, spi_chip_init: *const spi_memory.SpiMemoryInit) shell.ShellError!void {
    chip.init(spi_chip_init);
    try sh.registerCommand(&reset_command);
    try sh.registerCommand(&id_command);
}
