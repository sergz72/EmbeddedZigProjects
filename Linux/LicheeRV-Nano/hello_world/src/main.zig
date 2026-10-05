const std = @import("std");

pub fn main(init: std.process.Init) !void {
    _ = init;
    // Prints to stderr, unbuffered, ignoring potential errors.
    std.debug.print("Hello, World!\n", .{});
}
