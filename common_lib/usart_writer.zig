const std = @import("std");

fn dummyWrite(byte: u8) void {
    _ = byte;
}

fn usartWriteByte(byte: u8) void {
    if (byte == '\n') {
        usart_writer.writeCharFunc('\r');
    }
    usart_writer.writeCharFunc(byte);
}

fn drain(w: *std.Io.Writer, data: []const []const u8, splat: usize) std.Io.Writer.Error!usize {
    _ = w;
    var n: usize = 0;
    for (data[0 .. data.len - 1]) |chunk| {
        for (chunk) |b| usartWriteByte(b);
        n += chunk.len;
    }
    const last = data[data.len - 1];
    for (0..splat) |_| {
        for (last) |b| usartWriteByte(b);
        n += last.len;
    }
    return n;
}

pub const UsartWriter = struct {
    writeCharFunc: *const fn (u8) void,
    writer: std.Io.Writer
};

pub var usart_writer = UsartWriter{
    .writer =.{
        .vtable = &.{ .drain = drain },
        .buffer = &.{}
    },
    .writeCharFunc = dummyWrite
};