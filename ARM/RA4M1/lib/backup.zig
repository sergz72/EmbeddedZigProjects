const BACKUP_BASE: usize = 0x4001E400;

pub const Backup = extern struct {
    reserved: [31]u8,
    //41f
    vbtcr1: u8,
    reserved2: [144]u8,
    //4b0
    vbtcr2: u8,
    //4b1
    vbtsr: u8,
    //4b2
    vbtcmpcr: u8,
    reserved3: u8,
    //4b4
    vbtlvdicr: u8,
    reserved4: u8,
    //4b6
    vbtwctlr: u8,
    reserved5: u8,
    //4b8
    vbtwch0otsr: u8,
    //4b9
    vbtwch1otsr: u8,
    //4ba
    vbtwch2otsr: u8,
    //4bb
    vbtictlr: u8,
    //4bc
    vbtoctlr: u8,
    //4bd
    vbtwter: u8,
    //4be
    vbtwegr: u8,
    //4bf
    vbtwfr: u8,
    reserved6: [64]u8,
    //500
    vbtbkr: [512]u8,
};

pub const backup: *volatile Backup = @ptrFromInt(BACKUP_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x300, @sizeOf(Backup));
}
