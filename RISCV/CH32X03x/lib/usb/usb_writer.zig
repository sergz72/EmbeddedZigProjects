const std = @import("std");
const usb_cdc = @import("usb_cdc");

var buffer: [1024]u8 = undefined;
var buffer_idx: usize = undefined;

fn usbWriteByte(byte: u8) void {
    if (byte == '\n') {
        buffer[buffer_idx] = '\r';
        buffer_idx += 1;
    }
    buffer[buffer_idx] = byte;
    buffer_idx += 1;
}

pub fn usbWrite(byte: u8) void {
    var b = byte;
    usb_cdc.CDC_Transmit(&b, 1);
}

fn drain(w: *std.Io.Writer, data: []const []const u8, splat: usize) std.Io.Writer.Error!usize {
    _ = w;
    buffer_idx = 0;
    var n: usize = 0;
    for (data[0 .. data.len - 1]) |chunk| {
        for (chunk) |b| usbWriteByte(b);
        n += chunk.len;
    }
    const last = data[data.len - 1];
    for (0..splat) |_| {
        for (last) |b| usbWriteByte(b);
        n += last.len;
    }
    usb_cdc.CDC_Transmit(&buffer, buffer_idx);
    return n;
}

pub var usb_writer: std.Io.Writer = .{
    .vtable = &.{ .drain = drain },
    .buffer = &.{}
};
