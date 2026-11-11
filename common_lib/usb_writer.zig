const std = @import("std");

fn dummyWrite(byte: u8) void {
    _ = byte;
}

fn dummyFlush() void {
}

fn usbWriteByte(byte: u8) void {
    if (byte == '\n') {
        usb_writer.writeCharFunc('\r');
    }
    usb_writer.writeCharFunc(byte);
}

fn drain(w: *std.Io.Writer, data: []const []const u8, splat: usize) std.Io.Writer.Error!usize {
    _ = w;
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
    usb_writer.writeFlushFunc();
    return n;
}

pub const UsbWriter = struct {
    writeCharFunc: *const fn (u8) void,
    writeFlushFunc: *const fn () void,
    writer: std.Io.Writer
};

pub var usb_writer = UsbWriter{
    .writer =.{
        .vtable = &.{ .drain = drain },
        .buffer = &.{}
    },
    .writeCharFunc = dummyWrite,
    .writeFlushFunc = dummyFlush
};