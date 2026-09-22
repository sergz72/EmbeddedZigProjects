const std = @import("std");

pub const shell_result_ok: isize = 0;
pub const shell_error_too_many_commands: isize = 1;

pub const ShellCommand = struct {
    name: []const u8,
    help: []const u8,
    parameter_mask: usize,
    handler: *const fn (argc: usize, argv: [][]const u8, writer: *std.Io.Writer) std.Io.Writer.Error!isize,
};

pub const ShellInit = struct {
    max_commands: usize,
    max_parameters: usize,
    max_parameter_length: usize,
    max_command_length: usize,
    history_length: usize
};

pub const Shell = struct {
    init_data: *const ShellInit,
    writer: *std.Io.Writer,
    commands: []*const ShellCommand,
    argc: usize,
    argv: [][]const u8,
    history: [][]u8,
    history_size: usize,
    history_offset: usize,
    history_buffer: []u8,
    next_command_idx: usize,
    command: [128]u8,
    command_idx: usize,
    command_ready: bool,
    echo_func: *const fn(u8) void,

    pub fn init(init_data: *const ShellInit, allocator: std.mem.Allocator, writer: *std.Io.Writer,
        echo_func: *const fn(u8) void) !*Shell {
        const commands = try allocator.alloc(*const ShellCommand, init_data.max_commands);
        const argv = try allocator.alloc([]const u8, init_data.max_parameters);
        const history = try allocator.alloc([]u8, init_data.history_length);
        const history_buffer = try allocator.alloc(u8, init_data.history_length * init_data.max_command_length);
        const sh = try allocator.create(Shell);
        sh.* = Shell {
            .init_data = init_data,
            .writer = writer,
            .commands = commands,
            .argv = argv,
            .history = history,
            .next_command_idx = 0,
            .history_offset = 0,
            .history_size = 0,
            .history_buffer = history_buffer,
            .argc = 0,
            .command_idx = 0,
            .command_ready = false,
            .echo_func = echo_func,
            .command = undefined
        };
        return sh;
    }

    pub fn process_char(self: *Shell, c: u8) void {
        @setRuntimeSafety(false);
        if (!self.command_ready) {
            if (c == '\r') {
                self.echo_func(c);
                self.command_ready = true;
            } else if (self.command_idx < self.command.len) {
                self.echo_func(c);
                self.command[self.command_idx] = c;
                self.command_idx += 1;
            }
        }
    }

    pub fn handler(self: *Shell) !void {
        if (self.command_ready) {
            self.echo_func('\n');
            const rc = try self.execute(self.command[0..self.command_idx]);
            self.command_idx = 0;
            self.command_ready = false;
            try self.writer.print("shell returned {}\n", .{rc});
        }
    }

    pub fn register_command(self: *Shell, command: *const ShellCommand) isize {
        if (self.next_command_idx >= self.commands.len)
            return shell_error_too_many_commands;
        self.commands[self.next_command_idx] = command;
        self.next_command_idx += 1;
        return shell_result_ok;
    }

    pub fn execute(self: *Shell, command: []const u8) !isize {
        self.build_args(command);
        if (self.argc == 0)
            return 0;
        if (self.argc == 1 and std.mem.eql(u8, "help", self.argv[0])) {
            try self.print_help();
            return 0;
        }
        for (self.commands[0..self.next_command_idx]) |cmd| {
            if (std.mem.eql(u8, cmd.name, self.argv[0])) {
                if (cmd.parameter_mask & (@as(usize, 1) << @truncate(self.argc - 1)) != 0) {
                    return try cmd.handler(self.argc - 1, self.argv[1..], self.writer);
                } else {
                    _ = try self.writer.writeAll("incorrect number of parameters\n");
                    return -1;
                }
            }
        }
        _ = try self.writer.writeAll("unknown command\n");
        return 0;
    }

    fn print_help(self: *Shell) !void {
        _ = try self.writer.writeAll("usage:\n");
        for (self.commands[0..self.next_command_idx]) |cmd| {
            try self.writer.print("{s}\n", .{cmd.help});
        }
    }

    fn build_args(self: *Shell, command: []const u8) void {
        self.argc = 0;
        var start: isize = -1;
        for (0..command.len) |idx| {
            if (command[idx] <= ' ') {
                if (start >= 0) {
                    self.argv[self.argc] = command[@intCast(start)..idx];
                    self.argc += 1;
                    start = -1;
                }
            } else if (start < 0) {
                start = @intCast(idx);
            }
        }
        if (start >= 0) {
            self.argv[self.argc] = command[@intCast(start)..command.len];
            self.argc += 1;
        }
    }
};

test "build_args" {
    const shell_init = ShellInit{
        .max_commands = 50,
        .max_parameters = 10,
        .max_parameter_length = 50,
        .max_command_length = 100,
        .history_length = 20
    };

    const testing = std.testing;
    var allocator: std.heap.DebugAllocator(.{}) = .init;
    var sh = try Shell.init(&shell_init, allocator.allocator(),
        std.Io.File.stdout().writer(testing.io, &.{}).interface);
    sh.build_args("test command 123");
    try testing.expectEqual(@as(usize, 3), sh.argc);
    try testing.expectEqualStrings("test", sh.argv[0]);
    try testing.expectEqualStrings("command", sh.argv[1]);
    try testing.expectEqualStrings("123", sh.argv[2]);
}
