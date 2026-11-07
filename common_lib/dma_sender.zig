const std = @import("std");

pub const DmaSender = struct {
    dma_start: *const fn(data: []const u8) usize,
    delayms: *const fn(ms: usize) void,
    buffer: []u8 = &.{},
    write_idx: usize = 0,
    read_idx: usize = 0,
    tx_length: std.atomic.Value(usize) = std.atomic.Value(usize).init(0),
    current_transfer_length: usize = 0,

    // called from an interrupt when the DMA transfer is complete
    pub fn dmaDone(self: *DmaSender) void {
        self.read_idx += self.current_transfer_length;
        if (self.read_idx >= self.buffer.len) {
            self.read_idx -= self.buffer.len;
        }
        _ = self.tx_length.fetchSub(self.current_transfer_length, .seq_cst);
        const tx_length = self.tx_length.load(.seq_cst);
        if (tx_length == 0) {
           self.current_transfer_length = 0;
        } else {
            self.dmaStart();
        }
    }

    fn dmaStart(self: *DmaSender) void {
        const tx_length = self.tx_length.load(.seq_cst);
        const l = @min(tx_length, self.buffer.len - self.read_idx);
        self.current_transfer_length = self.dma_start(self.buffer[self.read_idx..][0..l]);
    }

    pub fn init(self: *DmaSender, buffer_size: usize, allocator: std.mem.Allocator) error{OutOfMemory}!void {
        self.buffer = try allocator.alloc(u8, buffer_size);
    }

    pub fn sendChar(self: *DmaSender, c: u8) void {
        while (true) {
            if (self.tx_length.load(.seq_cst) < self.buffer.len) {
                self.buffer[self.write_idx] = c;
                self.write_idx += 1;
                if (self.write_idx >= self.buffer.len) {
                    self.write_idx = 0;
                }
                _ = self.tx_length.fetchAdd(1, .seq_cst);
                break;
            } else {
                if (self.current_transfer_length == 0) {
                    self.dmaStart();
                }
                self.delayms(1);
            }
        }
    }

    pub fn start(self: *DmaSender) void {
        if (self.current_transfer_length == 0 and self.tx_length.load(.seq_cst) != 0) {
            self.dmaStart();
        }
    }

    pub fn send(self: *DmaSender, data: []const u8) void {
        for (data) |d| {
            self.sendChar(d);
        }
    }

    pub fn deinit(self: *DmaSender, allocator: std.mem.Allocator) void {
        allocator.free(self.buffer);
    }
};

var test_sender: DmaSender = DmaSender{
    .dma_start = &testDmaStart,
    .delayms = &testDelayms,
};

var test_data_count: [5]usize = undefined;
var test_data_count_idx: usize = undefined;

fn testDmaStart(data: []const u8) usize {
    test_data_count[test_data_count_idx] = data.len;
    test_data_count_idx += 1;
    return data.len;
}

fn testDelayms(ms: usize) void {
    _ = ms;
}

test "sender test" {
    test_data_count_idx = 0;
    try test_sender.init(10, std.testing.allocator);
    test_sender.sendChar('a');
    test_sender.sendChar('b');
    test_sender.sendChar('c');
    try std.testing.expect(test_sender.tx_length.load(.seq_cst) == 3);
    try std.testing.expectEqual('a', test_sender.buffer[0]);
    try std.testing.expectEqual('b', test_sender.buffer[1]);
    try std.testing.expectEqual('c', test_sender.buffer[2]);
    test_sender.start();
    test_sender.dmaDone();
    try std.testing.expectEqual(0, test_sender.tx_length.load(.seq_cst));
    try std.testing.expectEqual(3, test_sender.write_idx);
    try std.testing.expectEqual(3, test_sender.read_idx);
    test_sender.send("hijklmnopq");
    test_sender.start();
    test_sender.dmaDone();
    test_sender.dmaDone();
    try std.testing.expectEqual(0, test_sender.tx_length.load(.seq_cst));
    try std.testing.expectEqual(3, test_sender.write_idx);
    try std.testing.expectEqual(3, test_sender.read_idx);
    try std.testing.expectEqual(3, test_data_count_idx);
    try std.testing.expectEqual(3, test_data_count[0]);
    try std.testing.expectEqual(7, test_data_count[1]);
    try std.testing.expectEqual(3, test_data_count[2]);
    test_sender.deinit(std.testing.allocator);
}