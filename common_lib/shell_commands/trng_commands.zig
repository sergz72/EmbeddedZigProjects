const std = @import("std");
const shell = @import("shell");

const init_command = shell.ShellCommand{
    .name = "trng_init",
    .help = "trng_gen seed",
    .parameter_mask = 2,
    .handler = initHandler
};

const gen_command = shell.ShellCommand{
    .name = "trng_gen",
    .help = "trng_gen number_of_words",
    .parameter_mask = 2,
    .handler = genHandler
};

pub const Rng = struct {
    gen: *const fn([]u32) bool,
    init: *const fn(usize) void
};

var rng: *const Rng = undefined;

fn initHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    const seed = std.fmt.parseInt(usize, parameters.argv[0], 10) catch {
        try parameters.writer.print("invalid seed {s}\n", .{parameters.argv[0]});
        return 1;
    };
    rng.init(seed);
    return 0;
}

fn genHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    const number_of_words = std.fmt.parseInt(u8, parameters.argv[0], 10) catch {
        try parameters.writer.print("invalid number of words {s}\n", .{parameters.argv[0]});
        return 1;
    };
    const buffer = parameters.allocator.alloc(u32, number_of_words) catch {
        _ = try parameters.writer.write("out of memory\n");
        return 2;
    };
    defer parameters.allocator.free(buffer);
    if (!rng.gen(buffer)) {
        _ = try parameters.writer.write("failed to generate random numbers\n");
        return 3;
    }
    for (buffer, 0..) |b, idx| {
        try parameters.writer.print("{X:0>8} ", .{b});
        if (idx & 7 == 7) {
            _  = try parameters.writer.write("\n");
        }
    }
    _  = try parameters.writer.write("\n");
    return 0;
}

pub fn registerCommands(sh: *shell.Shell, generator: *const Rng) shell.ShellError!void {
    rng = generator;
    try sh.registerCommand(&gen_command);
    try sh.registerCommand(&init_command);
}
