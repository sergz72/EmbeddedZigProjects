const PORT_BASE: usize = 0x40040000;
const PFS_BASE: usize = 0x40040800;

const Port = extern struct {
    podr: u16,
    pdr: u16,
    eidr: u16,
    pidr: u16,
    porr: u16,
    posr: u16,
    eorr: u16,
    eosr: u16,
    reserved: [8]u16
};

const Pfs = packed struct(u32) {
    podr: bool = false,
    pidr: bool = false,
    pdr: bool = false,
    reserved: u1 = 0,
    pcr: bool = false,
    reserved2: u1 = 0,
    ncodr: bool = false,
    reserved3: u3 = 0,
    dscr: bool = false,
    dscr1: bool = false,
    eor: bool = false,
    eof: bool = false,
    isel: bool = false,
    asel: bool = false,
    pmr: bool = false,
    reserved4: u7 = 0,
    psel: u5 = 0,
    reserved5: u3 = 0
};

pub const port: *volatile [9]Port = @ptrFromInt(PORT_BASE);
pub const pfs: *volatile [9][16]Pfs = @ptrFromInt(PFS_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x20, @sizeOf(Port));
    const base_addr = @intFromPtr(pfs);
    const elem_addr = @intFromPtr(&pfs[1][0]);
    const offset = elem_addr - base_addr;
    try std.testing.expectEqual(0x40, offset);
}
