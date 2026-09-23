const FLASH_BASE: usize = 0x40022000;

pub const Flash = extern struct {
    reserved2: u32,
    keyr: u32,
    obkeyr: u32,
    statr: u32,
    ctlr: u32,
    addr: u32,
    reserved: u32,
    obr: u32,
    wpr: u32,
    flash_modekeyr: u32
};

pub const flash: *volatile Flash = @ptrFromInt(FLASH_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x28, @sizeOf(Flash));
}
