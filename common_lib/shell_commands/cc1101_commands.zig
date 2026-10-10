const std = @import("std");
const shell = @import("shell");
const utils = @import("utils");
const cc1101 = @import("cc1101");

const init_command = shell.ShellCommand{
    .name = "cc1101_init",
    .help = "cc1101_init channel",
    .parameter_mask = 2,
    .handler = initHandler
};

const receive_command = shell.ShellCommand{
    .name = "cc1101_receive",
    .help = "cc1101_receive channel",
    .parameter_mask = 2,
    .handler = receiveHandler
};

const receive_start_command = shell.ShellCommand{
    .name = "cc1101_receive_start",
    .help = "cc1101_receive_start channel",
    .parameter_mask = 2,
    .handler = receiveStartHandler
};

const receive_stop_command = shell.ShellCommand{
    .name = "cc1101_receive_stop",
    .help = "cc1101_receive_stop channel",
    .parameter_mask = 2,
    .handler = receiveStopHandler
};

const power_down_command = shell.ShellCommand{
    .name = "cc1101_power_down",
    .help = "cc1101_power_down channel",
    .parameter_mask = 2,
    .handler = powerDownHandler
};

const xoff_command = shell.ShellCommand{
    .name = "cc1101_xoff",
    .help = "cc1101_xoff channel",
    .parameter_mask = 2,
    .handler = xoffHandler
};

const send_command = shell.ShellCommand{
    .name = "cc1101_send",
    .help = "cc1101_send channel address data",
    .parameter_mask = 8,
    .handler = sendHandler
};

var rx_buffer: [64 * 3 + 1]u8 = undefined;
var cc1101_cfg: []const cc1101.CC1101Cfg = undefined;
var cc1101_devices: []cc1101.CC1101 = undefined;

fn getChannel(arg: []const u8, writer: *std.Io.Writer) std.Io.Writer.Error!?usize {
    const channel = std.fmt.parseInt(usize, arg, 10) catch {
        _ = try writer.write("invalid channel\n");
        return null;
    };
    if (channel > cc1101_devices.len) {
        _ = try writer.write("channel number is out of range\n");
        return null;
    }
    return channel;
}

fn initHandler(argc: usize, argv: [][]const u8, writer: *std.Io.Writer) std.Io.Writer.Error!isize {
    _ = argc;
    const channel = try getChannel(argv[0], writer);
    if (channel == null)
        return 1;

    cc1101_devices[channel.?].validateAndInit(&cc1101_cfg[channel.?]) catch |err| {
        try writer.print("{s}\n", .{@errorName(err)});
        return 2;
    };
    return 0;
}

fn receiveHandler(argc: usize, argv: [][]const u8, writer: *std.Io.Writer) std.Io.Writer.Error!isize {
    _ = argc;
    const channel = try getChannel(argv[0], writer);
    if (channel == null)
        return 1;

    const rx_data = cc1101_devices[channel.?].receive() catch |err| {
        try writer.print("{s}\n", .{@errorName(err)});
        return 2;
    };

    if (rx_data.len == 0) {
        _ = try writer.write("no data received\n");
        return 3;
    }

    const idx = utils.bytesToHex(rx_data, &rx_buffer);
    rx_buffer[idx-1] = '\n';
    _ = try writer.write(rx_buffer[0..idx]);

    return 0;
}

fn receiveStartHandler(argc: usize, argv: [][]const u8, writer: *std.Io.Writer) std.Io.Writer.Error!isize {
    _ = argc;
    const channel = try getChannel(argv[0], writer);
    if (channel == null)
        return 1;

    cc1101_devices[channel.?].receiveStart() catch |err| {
        try writer.print("{s}\n", .{@errorName(err)});
        return 2;
    };

    return 0;
}

fn receiveStopHandler(argc: usize, argv: [][]const u8, writer: *std.Io.Writer) std.Io.Writer.Error!isize {
    _ = argc;
    const channel = try getChannel(argv[0], writer);
    if (channel == null)
        return 1;

    cc1101_devices[channel.?].receiveStop() catch |err| {
        try writer.print("{s}\n", .{@errorName(err)});
        return 2;
    };

    return 0;
}

fn powerDownHandler(argc: usize, argv: [][]const u8, writer: *std.Io.Writer) std.Io.Writer.Error!isize {
    _ = argc;
    const channel = try getChannel(argv[0], writer);
    if (channel == null)
        return 1;

    cc1101_devices[channel.?].powerDown() catch |err| {
        try writer.print("{s}\n", .{@errorName(err)});
        return 2;
    };

    return 0;
}

fn xoffHandler(argc: usize, argv: [][]const u8, writer: *std.Io.Writer) std.Io.Writer.Error!isize {
    _ = argc;
    const channel = try getChannel(argv[0], writer);
    if (channel == null)
        return 1;

    cc1101_devices[channel.?].xoff() catch |err| {
        try writer.print("{s}\n", .{@errorName(err)});
        return 2;
    };

    return 0;
}

fn sendHandler(argc: usize, argv: [][]const u8, writer: *std.Io.Writer) std.Io.Writer.Error!isize {
    _ = argc;
    const channel = try getChannel(argv[0], writer);
    if (channel == null)
        return 1;

    const address = std.fmt.parseInt(u8, argv[1], 10) catch {
        _ = try writer.write("invalidaddress\n");
        return 2;
    };

    if (argv[2].len & 1 != 0 or argv[2].len / 2 > rx_buffer.len) {
        _ = try writer.write("invalid data length\n");
        return 3;
    }
    const bytes = std.fmt.hexToBytes(&rx_buffer, argv[2]) catch {
        _ = try writer.write("invalid data\n");
        return 4;
    };

    cc1101_devices[channel.?].transmit(address, bytes) catch |err| {
        try writer.print("{s}\n", .{@errorName(err)});
        return 5;
    };

    return 0;
}

pub fn registerCommands(sh: *shell.Shell, cfg: []const cc1101.CC1101Cfg, devices: []cc1101.CC1101) shell.ShellError!void {
    cc1101_cfg = cfg;
    cc1101_devices = devices;
    try sh.registerCommand(&init_command);
    try sh.registerCommand(&receive_command);
    try sh.registerCommand(&receive_start_command);
    try sh.registerCommand(&receive_stop_command);
    try sh.registerCommand(&power_down_command);
    try sh.registerCommand(&xoff_command);
    try sh.registerCommand(&send_command);
}
