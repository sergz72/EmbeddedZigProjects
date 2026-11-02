const std = @import("std");
const system_timer = @import("system_timer");

pub const DmaSender = struct {
    dma_start: *const fn(data: []const u8) void,
    buffer: []u8 = &.{},
    write_idx: usize = 0,
    read_idx: usize = 0,
    tx_length = std.atomic.Value(usize).init(0),
    current_transfer: []u8 = &.{},

    // called from an interrupt when the DMA transfer is complete
    pub fn dmaDone(self: *DmaSender) void {
        self.read_idx += self.current_transfer.len;
        if (self.read_idx >= self.buffer.len) {
            self.read_idx -= self.buffer.len;
        }
        _ = self.tx_length.fetchSub(self.current_transfer.len);
        const tx_length = self.tx_length.load();
        if (tx_length == 0) {
           self.current_transfer = &.{};
        } else {
            self.dmaStart();
        }
    }

    fn dmaStart(self: *DmaSender) void {
        const tx_length = self.tx_length.load();
        const l = @min(tx_length, self.buffer.len - self.read_idx);
        self.current_transfer = self.buffer[self.read_idx..][0..l];
        self.dma_start(self.current_transfer);
    }

    pub fn init(self: *DmaSender, buffer_size: usize, allocator: *std.mem.Allocator) error{OutOfMemory}!void {
        self.buffer = try allocator.alloc(u8, buffer_size);
    }

    pub fn send(self: *DmaSender, data: []const u8) void {
        for (data) |d| {
            if (self.tx_length.load() < self.buffer.len) {
                self.buffer[self.write_idx] = d;
                self.write_idx += 1;
                _ = self.tx_length.fetchAdd(1);
            } else {
                if (self.current_transfer.len == 0) {
                    self.dmaStart();
                }
                system_timer.delayms(1);
            }
        }
        if (self.current_transfer.len == 0 and self.tx_length.load() != 0) {
            self.dmaStart();
        }
    }
};
