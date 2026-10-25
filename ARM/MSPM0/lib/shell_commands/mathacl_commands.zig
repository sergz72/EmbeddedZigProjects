const std = @import("std");
const shell = @import("shell");
const mathacl = @import("mathacl");

const udiv_command = shell.ShellCommand{
    .name = "udiv",
    .help = "udiv dividend divisor",
    .parameter_mask = 4,
    .handler = udivHandler
};

const sdiv_command = shell.ShellCommand{
    .name = "sdiv",
    .help = "sdiv dividend divisor",
    .parameter_mask = 4,
    .handler = sdivHandler
};

const udiv_system_command = shell.ShellCommand{
    .name = "udiv_system",
    .help = "udiv_system dividend divisor",
    .parameter_mask = 4,
    .handler = udivSystemHandler
};

const sdiv_system_command = shell.ShellCommand{
    .name = "sdiv_system",
    .help = "sdiv_system dividend divisor",
    .parameter_mask = 4,
    .handler = sdivSystemHandler
};

fn udivHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    const op1 = std.fmt.parseInt(usize, parameters.argv[0], 10) catch {
        try parameters.writer.print("invalid operand1 {s}\n", .{parameters.argv[0]});
        return 1;
    };
    const op2 = std.fmt.parseInt(usize, parameters.argv[1], 10) catch {
        try parameters.writer.print("invalid operand2 {s}\n", .{parameters.argv[1]});
        return 2;
    };
    const result = mathacl.mathacl.divremUnsigned(op1, op2) catch |err| {
        try parameters.writer.print("division error {s}\n", .{@errorName(err)});
        return 3;
    };
    try parameters.writer.print("result = {}, remainder ={}\n", .{result.quotient, result.remainder});
    return 0;
}

fn sdivHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    const op1 = std.fmt.parseInt(isize, parameters.argv[0], 10) catch {
        try parameters.writer.print("invalid operand1 {s}\n", .{parameters.argv[0]});
        return 1;
    };
    const op2 = std.fmt.parseInt(isize, parameters.argv[1], 10) catch {
        try parameters.writer.print("invalid operand2 {s}\n", .{parameters.argv[1]});
        return 2;
    };
    const result = mathacl.mathacl.divremSigned(op1, op2) catch |err| {
        try parameters.writer.print("division error {s}\n", .{@errorName(err)});
        return 3;
    };
    try parameters.writer.print("result = {}, remainder ={}\n", .{result.quotient, result.remainder});
    return 0;
}

fn udivSystemHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    const op1 = std.fmt.parseInt(usize, parameters.argv[0], 10) catch {
        try parameters.writer.print("invalid operand1 {s}\n", .{parameters.argv[0]});
        return 1;
    };
    const op2 = std.fmt.parseInt(usize, parameters.argv[1], 10) catch {
        try parameters.writer.print("invalid operand2 {s}\n", .{parameters.argv[1]});
        return 2;
    };
    const q = op1 / op2;
    const r = op1 % op2;
    try parameters.writer.print("result = {}, remainder ={}\n", .{q, r});
    return 0;
}

fn sdivSystemHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    const op1 = std.fmt.parseInt(isize, parameters.argv[0], 10) catch {
        try parameters.writer.print("invalid operand1 {s}\n", .{parameters.argv[0]});
        return 1;
    };
    const op2 = std.fmt.parseInt(isize, parameters.argv[1], 10) catch {
        try parameters.writer.print("invalid operand2 {s}\n", .{parameters.argv[1]});
        return 2;
    };
    const q = @divTrunc(op1, op2);
    const r = @rem(op1, op2);
    try parameters.writer.print("result = {}, remainder ={}\n", .{q, r});
    return 0;
}

pub fn registerCommands(sh: *shell.Shell) shell.ShellError!void {
    try sh.registerCommand(&udiv_command);
    try sh.registerCommand(&sdiv_command);
    try sh.registerCommand(&udiv_system_command);
    try sh.registerCommand(&sdiv_system_command);
}
