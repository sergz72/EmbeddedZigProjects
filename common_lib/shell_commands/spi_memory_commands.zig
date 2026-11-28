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

const wren_command = shell.ShellCommand{
    .name = "spi_mem_wren",
    .help = "spi_mem_wren",
    .parameter_mask = 1,
    .handler = wrenHandler
};

const read_command = shell.ShellCommand{
    .name = "spi_mem_read",
    .help = "spi_mem_read address size",
    .parameter_mask = 4,
    .handler = readHandler
};

const fast_read_command = shell.ShellCommand{
    .name = "spi_mem_fast_read",
    .help = "spi_mem_fast_read address size",
    .parameter_mask = 4,
    .handler = fastReadHandler
};

const write_command = shell.ShellCommand{
    .name = "spi_mem_write",
    .help = "spi_mem_write address data",
    .parameter_mask = 4,
    .handler = writeHandler
};

const erase_command = shell.ShellCommand{
    .name = "spi_mem_erase",
    .help = "spi_mem_erase chip|sector|block32|block64 address",
    .parameter_mask = 4,
    .handler = eraseHandler
};

var chip: spi_memory.SpiMemory = undefined;

fn idHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    const id = chip.readId();
    if (id == null) {
        _ = try parameters.writer.write("read id error\n");
        return 1;
    }
    try parameters.writer.print("0x{x:0>8}\n", .{id.?});
    return 0;
}

fn resetHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    if (!chip.reset()) {
        _ = try parameters.writer.write("reset error\n");
        return 1;
    }
    return 0;
}

fn wrenHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    if (!chip.wren()) {
        _ = try parameters.writer.write("wren error\n");
        return 1;
    }
    return 0;
}

fn readHandlerCommmon(fast: bool, parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    const address = std.fmt.parseInt(usize, parameters.argv[0], 0) catch {
        try parameters.writer.print("invalid address {s}\n", .{parameters.argv[0]});
        return 1;
    };
    const size = std.fmt.parseInt(usize, parameters.argv[1], 0) catch {
        try parameters.writer.print("invalid size {s}\n", .{parameters.argv[1]});
        return 3;
    };
    const data = parameters.allocator.alloc(u8, size) catch {
        _ = try parameters.writer.write("could not allocate memory\n");
        return 4;
    };
    defer parameters.allocator.free(data);
    if (fast) {
        if (!chip.fastRead(address, data)) {
            _ = try parameters.writer.write("fast read error\n");
            return 5;
        }
    } else {
        if (!chip.read(address, data)) {
            _ = try parameters.writer.write("read error\n");
            return 5;
        }
    }
    try utils.printHex(data, parameters.writer);
    return 0;
}

fn readHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    return readHandlerCommmon(false, parameters);
}

fn fastReadHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    return readHandlerCommmon(true, parameters);
}

fn writeHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    const address = std.fmt.parseInt(usize, parameters.argv[0], 0) catch {
        try parameters.writer.print("invalid address {s}\n", .{parameters.argv[0]});
        return 1;
    };
    if (parameters.argv[1].len & 1 != 0) {
        _ = try parameters.writer.write("invalid data length\n");
        return 2;
    }
    const write_buffer = parameters.allocator.alloc(u8, parameters.argv[1].len / 2) catch {
        _ = try parameters.writer.write("could not allocate memory\n");
        return 3;
    };
    defer parameters.allocator.free(write_buffer);
    const bytes = std.fmt.hexToBytes(write_buffer, parameters.argv[1]) catch {
        _ = try parameters.writer.write("invalid data\n");
        return 4;
    };
    if (!chip.wren()) {
        _ = try parameters.writer.write("wren error\n");
        return 5;
    }
    if (!chip.write(address, bytes)) {
        _ = try parameters.writer.write("write error\n");
        return 6;
    }
    return 0;
}

fn eraseHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    const address = std.fmt.parseInt(usize, parameters.argv[1], 0) catch {
        try parameters.writer.print("invalid address {s}\n", .{parameters.argv[1]});
        return 1;
    };
    if (!chip.wren()) {
        _ = try parameters.writer.write("wren error\n");
        return 5;
    }
    if (!std.mem.eql(u8, parameters.argv[0], "chip")) {
        if (!chip.eraseChip()) {
            _ = try parameters.writer.write("erase error\n");
            return 2;
        }
        return 0;
    }
    if (!std.mem.eql(u8, parameters.argv[0], "sector")) {
        if (!chip.eraseSector(address)) {
            _ = try parameters.writer.write("erase error\n");
            return 2;
        }
        return 0;
    }
    if (!std.mem.eql(u8, parameters.argv[0], "block32")) {
        if (!chip.eraseBlock32k(address)) {
            _ = try parameters.writer.write("erase error\n");
            return 2;
        }
        return 0;
    }
    if (!std.mem.eql(u8, parameters.argv[0], "block64")) {
        if (!chip.eraseBlock64k(address)) {
            _ = try parameters.writer.write("erase error\n");
            return 2;
        }
        return 0;
    }
    _ = try parameters.writer.write("unknown erase type\n");
    return 3;
}

pub fn registerCommands(sh: *shell.Shell, spi_chip_init: *const spi_memory.SpiMemoryInit) shell.ShellError!void {
    chip.init(spi_chip_init);
    try sh.registerCommand(&reset_command);
    try sh.registerCommand(&id_command);
    try sh.registerCommand(&wren_command);
    try sh.registerCommand(&read_command);
    try sh.registerCommand(&fast_read_command);
    try sh.registerCommand(&write_command);
    try sh.registerCommand(&erase_command);
}
