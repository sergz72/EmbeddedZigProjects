const std = @import("std");
const simple_allocator = @import("simple_allocator");

extern var _end: anyopaque;
extern var _heap_end: anyopaque;

pub fn build_allocator() std.mem.Allocator {
    var a = simple_allocator.SimpleAllocator.init(&_end, &_heap_end, 16);
    return a.allocator();
}
