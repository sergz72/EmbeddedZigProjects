const std = @import("std");

const COMMAND_SIZE = 128;

pub const ShellError = error {
    TooManyCommands
};

pub const ShellHandlerParameters = struct {
    argv: [][]const u8,
    allocator: std.mem.Allocator,
    writer: *std.Io.Writer
};

pub const ShellCommand = struct {
    name: []const u8,
    help: []const u8,
    parameter_mask: usize,
    handler: *const fn (parameters: ShellHandlerParameters) std.Io.Writer.Error!isize,
};

pub const ShellSourceInit = struct {
    writer: *std.Io.Writer,
    echo_func: *const fn(u8) void
};

pub const ShellInit = struct {
    max_commands: usize,
    max_parameters: usize,
    max_parameter_length: usize,
    max_command_length: usize,
    history_length: usize,
    source_init: []const ShellSourceInit
};

pub const ShellSource = struct {
    history: [][]u8,
    history_size: usize,
    history_offset: usize,
    history_buffer: []u8,
    command: [COMMAND_SIZE]u8,
    command_idx: usize,
    command_ready: bool,
    source_init: *const ShellSourceInit,

    fn init(self: *ShellSource, init_data: *const ShellInit, allocator: std.mem.Allocator, idx: usize) error{OutOfMemory}!void {
        const history = try allocator.alloc([]u8, init_data.history_length);
        const history_buffer = try allocator.alloc(u8, init_data.history_length * init_data.max_command_length);
        self.history = history;
        self.history_offset = 0;
        self.history_size = 0;
        self.history_buffer = history_buffer;
        self.command_idx = 0;
        self.command_ready = false;
        self.source_init = &init_data.source_init[idx];
    }

    fn processChar(self: *ShellSource, c: u8) void {
        @setRuntimeSafety(false);
        if (!self.command_ready) {
            if (c == '\r') {
                self.source_init.echo_func(c);
                self.command_ready = true;
            } else if (self.command_idx < self.command.len) {
                self.source_init.echo_func(c);
                self.command[self.command_idx] = c;
                self.command_idx += 1;
            }
        }
    }
};

pub const Shell = struct {
    init_data: *const ShellInit,
    argc: usize,
    argv: [][]const u8,
    allocator: std.mem.Allocator,
    commands: []*const ShellCommand,
    next_command_idx: usize,
    sources: []ShellSource,

    pub fn init(init_data: *const ShellInit, allocator: std.mem.Allocator) error{OutOfMemory}!*Shell {
        const commands = try allocator.alloc(*const ShellCommand, init_data.max_commands);
        const argv = try allocator.alloc([]const u8, init_data.max_parameters);
        const sources = try allocator.alloc(ShellSource, init_data.source_init.len);
        for (sources, 0..) |*source, idx| {
            try source.init(init_data, allocator, idx);
        }
        const sh = try allocator.create(Shell);
        sh.* = Shell {
            .init_data = init_data,
            .argc = 0,
            .argv = argv,
            .allocator = allocator,
            .commands = commands,
            .next_command_idx = 0,
            .sources = sources
        };
        return sh;
    }

    pub fn processChar(self: *Shell, source: usize, c: u8) void {
        @setRuntimeSafety(false);
        if (source >= self.sources.len) return;
        self.sources[source].processChar(c);
    }

    pub fn handler(self: *Shell) !void {
        for (self.sources, 0..) |*source, idx| {
            if (source.command_ready) {
                self.init_data.source_init[idx].echo_func('\n');
                const rc = try self.execute(source.command[0..source.command_idx], idx);
                source.command_idx = 0;
                source.command_ready = false;
                try self.init_data.source_init[idx].writer.print("shell returned {}\n", .{rc});
            }
        }
    }

    pub fn registerCommand(self: *Shell, command: *const ShellCommand) ShellError!void {
        if (self.next_command_idx >= self.commands.len)
            return ShellError.TooManyCommands;
        self.commands[self.next_command_idx] = command;
        self.next_command_idx += 1;
    }

    pub fn execute(self: *Shell, command: []const u8, source: usize) !isize {
        const writer = self.init_data.source_init[source].writer;
        if (!self.buildArgs(command)) {
            _ = try writer.writeAll("too many parameters\n");
            return 1;
        }
        if (self.argc == 0)
            return 0;
        if (self.argc == 1 and std.mem.eql(u8, "help", self.argv[0])) {
            try self.printHelp(writer);
            return 0;
        }
        for (self.commands[0..self.next_command_idx]) |cmd| {
            if (std.mem.eql(u8, cmd.name, self.argv[0])) {
                if (cmd.parameter_mask & (@as(usize, 1) << @truncate(self.argc - 1)) != 0) {
                    return try cmd.handler(.{
                        .writer = writer,
                        .allocator = self.allocator,
                        .argv = self.argv[1..self.argc]
                    });
                } else {
                    _ = try writer.writeAll("incorrect number of parameters\n");
                    return -1;
                }
            }
        }
        _ = try writer.writeAll("unknown command\n");
        return 2;
    }

    fn printHelp(self: *Shell, writer: *std.Io.Writer) !void {
        _ = try writer.writeAll("usage:\n");
        for (self.commands[0..self.next_command_idx]) |cmd| {
            try writer.print("{s}\n", .{cmd.help});
        }
    }

    fn buildArgs(self: *Shell, command: []const u8) bool {
        self.argc = 0;
        var start_idx: usize = 0;
        var start: bool = false;
        for (0..command.len) |idx| {
            if (command[idx] <= ' ') {
                if (start) {
                    if (self.argc >= self.init_data.max_parameters)
                        return false;
                    self.argv[self.argc] = command[start_idx..idx];
                    self.argc += 1;
                    start = false;
                }
            } else if (!start) {
                start = true;
                start_idx = idx;
            }
        }
        if (start) {
            if (self.argc >= self.init_data.max_parameters)
                return false;
            self.argv[self.argc] = command[start_idx..command.len];
            self.argc += 1;
        }
        return true;
    }
};

fn testEcho(ch: u8) void {
    _ = ch;
}

test "buildArgs" {
    const testing = std.testing;
    var writer = std.Io.File.stdout().writer(testing.io, &.{}).interface;
    const shell_init = ShellInit{
        .max_commands = 50,
        .max_parameters = 10,
        .max_parameter_length = 50,
        .max_command_length = 100,
        .history_length = 20,
        .source_init = &.{
            ShellSourceInit{
                .writer = &writer,
                .echo_func = &testEcho
            }
        }
    };
    var allocator: std.heap.DebugAllocator(.{}) = .init;
    var sh = try Shell.init(&shell_init, allocator.allocator());
    try testing.expect(sh.buildArgs("test command 123"));
    try testing.expectEqual(@as(usize, 3), sh.argc);
    try testing.expectEqualStrings("test", sh.argv[0]);
    try testing.expectEqualStrings("command", sh.argv[1]);
    try testing.expectEqualStrings("123", sh.argv[2]);
}
