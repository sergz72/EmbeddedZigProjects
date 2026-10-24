const std = @import("std");

pub fn printHex(buffer: []const u8, writer: *std.Io.Writer) std.Io.Writer.Error!void {
    var data = buffer;
    var size = buffer.len;
    while (size != 0) {
        if (size >= 16) {
            try writer.print(
                "{x:0>2} {x:0>2} {x:0>2} {x:0>2} {x:0>2} {x:0>2} {x:0>2} {x:0>2} {x:0>2} {x:0>2} {x:0>2} {x:0>2} {x:0>2} {x:0>2} {x:0>2} {x:0>2}\n",
                .{data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7],
                  data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15]});
            data = data[16..];
            size -= 16;
        } else {
            for (data[0..size]) |b| {
                try writer.print("{x:0>2} ", .{b});
            }
            _ = try writer.write("\n");
            size = 0;
        }
    }
}

pub fn bytesToHex(input: []u8, result: []u8) usize {
    const charset = "0123456789abcdef";
    var idx: usize = 0;
    for (input) |b| {
        result[idx] = charset[b >> 4];
        idx += 1;
        result[idx] = charset[b & 15];
        idx += 1;
        result[idx] = ' ';
        idx += 1;
    }
    return idx;
}
