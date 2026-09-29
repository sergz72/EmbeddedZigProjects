const std = @import("std");
const simple_allocator = @import("simple_allocator");

extern var _end: anyopaque;
extern var _heap_end: anyopaque;

var allocator = simple_allocator.SimpleAllocator{
    .control_array = undefined,
    .data_array = undefined,
    .item_alignment = 4,
};

pub fn buildAllocator() std.mem.Allocator {
    simple_allocator.SimpleAllocator.init(&allocator, &_end, &_heap_end);
    return allocator.allocator();
}

pub fn getFreeSize() usize {
    return allocator.get_free_size();
}
