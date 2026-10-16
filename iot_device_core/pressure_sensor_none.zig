const std = @import("std");

pub fn init() void {
}

pub fn measurementStart(writer: *std.Io.Writer) void {
    _ = writer;
}

pub fn isMeasurementFinished(writer: *std.Io.Writer) bool {
    _ = writer;
    return true;
}