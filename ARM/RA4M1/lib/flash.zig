const FLASH_BASE: usize = 0x4001C100;
const DFLCTL_BASE: usize = 0x407EC090;

pub const Flash = extern struct {
    //c100
    fcachee: u16,
    reserved: u16,
    //c104
    fcacheiv: u16,
};

pub const flash: *volatile Flash = @ptrFromInt(FLASH_BASE);
pub const dflctl: *volatile u8 = @ptrFromInt(DFLCTL_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(6, @sizeOf(Flash));
}
