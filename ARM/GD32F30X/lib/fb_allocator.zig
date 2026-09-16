const std = @import("std");

extern var _end: anyopaque;
extern var _heap_end: anyopaque;

var allocator = std.heap.FixedBufferAllocator{
    .buffer = undefined,
    .end_index = 0
};

pub fn build_allocator() std.mem.Allocator {
    const start_addr = @intFromPtr(&_end);
    const end_addr = @intFromPtr(&_heap_end);

    const heap_len = end_addr - start_addr;

    const raw_ptr: [*]u8 = @ptrCast(&_end);

    allocator.buffer = raw_ptr[0..heap_len];
    return allocator.allocator();
}

pub fn get_free_size() usize {
    return allocator.buffer.len - allocator.end_index;
}