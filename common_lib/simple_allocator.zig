const std = @import("std");
const Allocator = std.mem.Allocator;
const builtin = @import("builtin");

const ShiftCount = if (builtin.target.ptrBitWidth() == 64) u6 else u5;

pub const SimpleAllocator = struct {
    control_array: []u8,
    data_array: []u8,
    item_alignment: ShiftCount,
    item_size: usize = undefined,
    item_lo_mask: usize = undefined,
    first_free_index: usize = 0,

    pub fn init_buffer(instance: *SimpleAllocator, buffer: []u8) void {
        instance.item_size = @as(usize, 1) << instance.item_alignment;
        instance.item_lo_mask = instance.item_size - 1;
        const item_hi_mask = ~instance.item_lo_mask;

        const heap_size_items = buffer.len >> instance.item_alignment;
        const heap_size = buffer.len & item_hi_mask;
        const data_size = heap_size - heap_size_items;
        const data_size_items = data_size >> instance.item_alignment;
        var data_offset = data_size_items;
        if (data_offset & instance.item_lo_mask != 0)
            data_offset = (data_offset & item_hi_mask) + instance.item_size;
        const data_size_corrected = data_size_items << instance.item_alignment;
        if (data_offset + data_size_corrected > buffer.len) {
            while (true) {}
        }

        const control_array: []u8 = buffer[0..data_size_items];
        @memset(control_array, 0);
        const data_array: []u8 = buffer[data_offset..data_offset+data_size_corrected];

        instance.control_array = control_array;
        instance.data_array = data_array;
        instance.first_free_index = 0;
    }

    pub fn init(instance: *SimpleAllocator, start_ptr: *anyopaque, end_ptr: *anyopaque) void {
        const start_addr = @intFromPtr(start_ptr);
        const end_addr = @intFromPtr(end_ptr);

        const heap_len = end_addr - start_addr;

        const raw_ptr: [*]u8 = @ptrCast(start_ptr);

        const heap_slice: []u8 = raw_ptr[0..heap_len];

        init_buffer(instance, heap_slice);
    }

    pub fn allocator(self: *SimpleAllocator) Allocator {
        return .{
            .ptr = self,
            .vtable = &.{
                .alloc = alloc,
                .resize = Allocator.noResize,
                .remap = Allocator.noRemap,
                .free = free,
            },
        };
    }

    pub fn get_free_size(self: *const SimpleAllocator) usize {
        var free_size: usize = 0;
        for (0..self.control_array.len) |idx| {
            if (self.control_array[idx] == 0)
                free_size += self.item_size;
        }
        return free_size;
    }

    pub fn alloc(ctx: *anyopaque, n: usize, alignment: std.mem.Alignment, ra: usize) ?[*]u8 {
        _ = ra;
        if (n == 0) return null;
        const self: *SimpleAllocator = @ptrCast(@alignCast(ctx));
        var item_count = n >> self.item_alignment;
        if ((n & self.item_lo_mask) != 0)
            item_count += 1;
        if (item_count > 254) return null;
        var ptr_align = alignment.toByteUnits();
        if (ptr_align < self.item_size)
            ptr_align = self.item_size;
        const start_addr = @intFromPtr(self.data_array.ptr);
        const first_free_addr = start_addr + self.first_free_index;
        const aligned_addr = std.mem.alignForward(usize, first_free_addr, ptr_align);
        const aligned_idx = (aligned_addr - start_addr) >> self.item_alignment;
        if (aligned_idx + item_count > self.control_array.len) return null;
        var count_free: usize = 0;
        var start: usize = undefined;
        for (aligned_idx..self.control_array.len) |idx| {
            if (self.control_array[idx] == 0) {
                if (count_free == 0) {
                    start = idx;
                }
                count_free += 1;
                if (count_free == item_count) {
                    self.control_array[start] = @truncate(item_count);
                    @memset(self.control_array[start+1..start+item_count], 0xFF);
                    const data_ptr: [*]u8 = @ptrFromInt(start_addr + (start << self.item_alignment));
                    start += item_count;
                    while ((start < self.control_array.len) and (self.control_array[start] != 0))
                        start += 1;
                    self.first_free_index = start;
                    return data_ptr;
                }
            } else {
                count_free = 0;
            }
        }
        return null;
    }

    pub fn free_mem(self: *SimpleAllocator, buf: []u8) bool {
        const buf_address = @intFromPtr(buf.ptr);
        // buffer address is misaligned
        if (buf_address & self.item_lo_mask != 0)
            return false;
        const start = @intFromPtr(self.data_array.ptr);
        // buffer address is out of range
        if ((buf_address < start) or (buf_address >= start + self.data_array.len))
            return false;
        const idx = (buf_address - start) >> self.item_alignment;
        const l = self.control_array[idx];
        // control byte (length) cannot be 0 or 0xFF
        if ((l == 0) or (l == 0xFF) or ((idx + l) > self.control_array.len))
            return false;
        // mark as free
        @memset(self.control_array[idx..idx+l], 0);
        if (idx < self.first_free_index)
            self.first_free_index = idx;
        return true;
    }

    pub fn free(
        ctx: *anyopaque,
        buf: []u8,
        alignment: std.mem.Alignment,
        ra: usize,
    ) void {
        _ = ra;
        _ = alignment;
        const self: *SimpleAllocator = @ptrCast(@alignCast(ctx));
        _ = self.free_mem(buf);
    }
};

test "alloc test" {
    const testing = std.testing;
    const buffer= try testing.allocator.alignedAlloc(u8, std.mem.Alignment.@"16", 29*1024);
    defer testing.allocator.free(buffer);
    const sa = SimpleAllocator.init_buffer(buffer, 16);
    const io = testing.io;
    var io_source: std.Random.IoSource = .{ .io = io };
    const rand = io_source.interface();
    try allocator_tests(testing.allocator, sa, rand);
}

fn allocator_tests(allocator: std.mem.Allocator, test_allocator: SimpleAllocator, rand: std.Random) !void {
    var object_list = try std.ArrayList([]u8).initCapacity(allocator, 1024);
    defer object_list.deinit(allocator);
    var total_allocated: usize = 0;
    std.debug.print("Free size {}\n", .{test_allocator.get_free_size()});
    var a = test_allocator;
    var v: u8 = 1;
    var counter: usize = 0;
    while (true) {
        const l = rand.intRangeAtMost(usize, 1, 512);
        const object_ptr = SimpleAllocator.alloc(&a, l, std.mem.Alignment.@"1", 0) orelse break;
        total_allocated += l;
        const object: []u8 = object_ptr[0..l];
        @memset(object, v);
        v += 1;
        try object_list.append(allocator, object);
        counter += 1;
        if ((counter % 3) == 0) {
            const idx = rand.intRangeAtMost(usize, 0, object_list.items.len - 1);
            const o = object_list.items[idx];
            if (!a.free_mem(o)) {
                std.debug.print("object {*} cannot be freed\n", .{o.ptr});
            } else {
                _ = object_list.orderedRemove(idx);
            }
        }
    }
    std.debug.print("Allocated {} objects with total size {}\n", .{object_list.items.len, total_allocated});
    std.debug.print("Free size {}\n", .{test_allocator.get_free_size()});
    for (object_list.items) |o| {
        if (!a.free_mem(o)) {
            std.debug.print("object {*} cannot be freed\n", .{o.ptr});
        }
    }
    std.debug.print("Free size {}\n", .{test_allocator.get_free_size()});
}