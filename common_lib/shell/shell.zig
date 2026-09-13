const std = @import("std");

pub const shell_result_ok: isize = 0;
pub const shell_error_too_many_commands: isize = 1;

pub const ShellCommand = struct {
    name: []const u8,
    help: []const u8,
    parameter_mask: usize,
    handler: *const fn (args: [][]const u8, writer: std.Io.Writer) isize,
};

pub const ShellInit = struct {
    allocator: std.mem.Allocator,
    writer: std.Io.Writer,
    max_commands: usize,
    max_parameters: usize,
    max_parameter_length: usize,
    max_command_length: usize,
    history_length: usize
};

pub const Shell = struct {
    writer: std.Io.Writer,
    commands: []*const ShellCommand,
    argv: [][]u8,
    history: [][]u8,
    next_command_idx: usize,
    history_offset: usize,

    pub fn init(init_data: *const ShellInit) !*Shell {
        const commands = try init_data.allocator.alloc(*ShellCommand, init_data.max_commands);
        const argv = try init_data.allocator.alloc([init_data.max_parameter_length]u8, init_data.max_parameters);
        const history = try init_data.allocator.alloc([init_data.max_command_length]u8, init_data.history_length);
        return Shell {
            .commands = commands,
            .argv = argv,
            .writer = init_data.writer,
            .history = history,
            .next_command_idx = 0,
            .history_offset = 0
        };
    }

    pub fn register_commands(self: *Shell, commands: []*const ShellCommand) isize {
        if (self.next_command_idx + commands.len > self.commands.len)
            return shell_error_too_many_commands;
        @memcpy(self.commands[self.next_command_idx..], commands);
        self.next_command_idx += commands.len;
        return shell_result_ok;
    }

    pub fn execute(self: *Shell, command: []const u8) isize {
        _ = self;
        _ = command;
    }
};
