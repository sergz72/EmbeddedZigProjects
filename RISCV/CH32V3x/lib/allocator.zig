const std = @import("std");
const simple_allocator = @import("simple_allocator");

extern var _end: anyopaque;
extern var _heap_end: anyopaque;

var allocator = simple_allocator.SimpleAllocator{
    .control_array = undefined,
    .data_array = undefined,
    .item_alignment = 4,
};

pub fn build_allocator() std.mem.Allocator {
    simple_allocator.SimpleAllocator.init(&allocator, &_end, &_heap_end);
    return allocator.allocator();
}
