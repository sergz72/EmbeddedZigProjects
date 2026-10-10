const std = @import("std");
const shell = @import("shell");
const system_timer = @import("system_timer");

const ChaCha20IETF = std.crypto.stream.chacha.ChaCha20IETF;

pub const MemoryRegion = struct {
    base: usize,
    size: usize
};

const test_command = shell.ShellCommand{
    .name = "memtest",
    .help = "memtest [region_name]",
    .parameter_mask = 3,
    .handler = testHandler
};

var memory_regions: *const std.StaticStringMap(MemoryRegion) = undefined;
var random_number_generator: *const fn([]u32) bool = undefined;

fn testHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    if (parameters.argv.len == 0) {
        for (memory_regions.keys()) |k| {
            try parameters.writer.print("{s}\n", .{k});
        }
        return 0;
    }
    const region = memory_regions.get(parameters.argv[0]) orelse {
        _ = try parameters.writer.write("region not found\n");
        return 1;
    };
    return try testRegion(region, parameters.allocator, parameters.writer);
}

fn testRegion(region: MemoryRegion, allocator: std.mem.Allocator, writer: *std.Io.Writer) std.Io.Writer.Error!isize {
    var key: [32]u8 align(4) = undefined;
    var nonce: [12]u8 align(4) = undefined;
    const key32: []u32 = std.mem.bytesAsSlice(u32, &key);
    const nonce32: []u32 = std.mem.bytesAsSlice(u32, &nonce);
    if (!random_number_generator(key32) or !random_number_generator(nonce32)) {
        _  = try writer.write("failed to generate random key or nonce\n");
        return 1;
    }

    const buffer = allocator.alignedAlloc(u8, std.mem.Alignment.@"4", 1024) catch {
        _  = try writer.write("out of memory\n");
        return 2;
    };
    defer allocator.free(buffer);

    const byte_ptr: [*]u32 = @ptrFromInt(region.base);
    const mem32: []u32 = byte_ptr[0..region.size / 4];
    const mem16: []u16 = std.mem.bytesAsSlice(u16, mem32);
    const mem8: []u8 = std.mem.bytesAsSlice(u8, mem32);

    _ = try writer.write("Testing 8 bit access...\n");
    var idx: usize = 0;
    var counter: u32 = 0;
    system_timer.start1ms();
    while (idx < mem8.len) {
        const start_idx = idx;
        ChaCha20IETF.stream(buffer, counter, key, nonce);
        counter += 16;
        for (0..buffer.len) |i| {
            mem8[idx] = buffer[i];
            idx += 1;
        }
        idx = start_idx;
        for (0..buffer.len) |i| {
            if (mem8[idx] != buffer[i]) {
                _ = system_timer.stop();
                try writer.print("Failed at {}\n", .{idx});
                return 3;
            }
            idx += 1;
        }
    }
    const elapsed8 = system_timer.stop();

    const buffer16: []u16 = std.mem.bytesAsSlice(u16, buffer);

    try writer.print("OK, elapsed time = {}ms\nTesting 16 bit access...\n", .{elapsed8});
    idx = 0;
    counter = 0;
    system_timer.start1ms();
    while (idx < mem16.len) {
        const start_idx = idx;
        ChaCha20IETF.stream(buffer, counter, key, nonce);
        counter += 16;
        for (0..buffer16.len) |i| {
            mem16[idx] = buffer16[i];
            idx += 1;
        }
        idx = start_idx;
        for (0..buffer16.len) |i| {
            if (mem16[idx] != buffer16[i]) {
                _ = system_timer.stop();
                try writer.print("Failed at {}\n", .{idx});
                return 4;
            }
            idx += 1;
        }
    }
    const elapsed16 = system_timer.stop();

    const buffer32: []u32 = std.mem.bytesAsSlice(u32, buffer);

    try writer.print("OK, elapsed time = {}ms\nTesting 32 bit access...\n", .{elapsed16});
    idx = 0;
    counter = 0;
    system_timer.start1ms();
    while (idx < mem32.len) {
        const start_idx = idx;
        ChaCha20IETF.stream(buffer, counter, key, nonce);
        counter += 16;
        for (0..buffer32.len) |i| {
            mem32[idx] = buffer32[i];
            idx += 1;
        }
        idx = start_idx;
        for (0..buffer32.len) |i| {
            if (mem32[idx] != buffer32[i]) {
                _ = system_timer.stop();
                try writer.print("Failed at {}\n", .{idx});
                return 5;
            }
            idx += 1;
        }
    }

    const elapsed32 = system_timer.stop();
    try writer.print("OK, elapsed time = {}ms\n", .{elapsed32});

    return 0;
}

pub fn registerCommands(sh: *shell.Shell, regions: *const std.StaticStringMap(MemoryRegion),
                        generator: *const fn([]u32) bool) shell.ShellError!void {
    memory_regions = regions;
    random_number_generator = generator;
    try sh.registerCommand(&test_command);
}
