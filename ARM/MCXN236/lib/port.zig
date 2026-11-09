const PORT0_BASE = 0x40116000;
const PORT1_BASE = 0x40117000;
const PORT2_BASE = 0x40118000;
const PORT3_BASE = 0x40119000;
const PORT4_BASE = 0x4011A000;
const PORT5_BASE = 0x40042000;

pub const Verid = packed struct(u32) {
    feature: u16,
    minor: u8,
    major: u8,
};

pub const Gpclr = packed struct(u32) {
    gpwd: u16 = 0,
    gpwe0: bool = false,
    gpwe1: bool = false,
    gpwe2: bool = false,
    gpwe3: bool = false,
    gpwe4: bool = false,
    gpwe5: bool = false,
    gpwe6: bool = false,
    gpwe7: bool = false,
    gpwe8: bool = false,
    gpwe9: bool = false,
    gpwe10: bool = false,
    gpwe11: bool = false,
    gpwe12: bool = false,
    gpwe13: bool = false,
    gpwe14: bool = false,
    gpwe15: bool = false,
};

pub const Gpchr = packed struct(u32) {
    gpwd: u16 = 0,
    gpwe16: bool = false,
    gpwe17: bool = false,
    gpwe18: bool = false,
    gpwe19: bool = false,
    gpwe20: bool = false,
    gpwe21: bool = false,
    gpwe22: bool = false,
    gpwe23: bool = false,
    gpwe24: bool = false,
    gpwe25: bool = false,
    gpwe26: bool = false,
    gpwe27: bool = false,
    gpwe28: bool = false,
    gpwe29: bool = false,
    gpwe30: bool = false,
    gpwe31: bool = false,
};

pub const Config = packed struct(u32) {
    range: bool = false,
    reserved0: u31 = 0,
};

pub const Edfr = packed struct(u32) {
    edf0: bool,
    edf1: bool,
    edf2: bool,
    edf3: bool,
    edf4: bool,
    edf5: bool,
    edf6: bool,
    edf7: bool,
    reserved0: u4,
    edf12: bool,
    edf13: bool,
    edf14: bool,
    edf15: bool,
    edf16: bool,
    edf17: bool,
    edf18: bool,
    edf19: bool,
    edf20: bool,
    edf21: bool,
    edf22: bool,
    edf23: bool,
    edf24: bool,
    edf25: bool,
    edf26: bool,
    edf27: bool,
    edf28: bool,
    edf29: bool,
    reserved1: u2,
};

pub const Edier = packed struct(u32) {
    edie0: bool = false,
    edie1: bool = false,
    edie2: bool = false,
    edie3: bool = false,
    edie4: bool = false,
    edie5: bool = false,
    edie6: bool = false,
    edie7: bool = false,
    reserved0: u4 = 0,
    edie12: bool = false,
    edie13: bool = false,
    edie14: bool = false,
    edie15: bool = false,
    edie16: bool = false,
    edie17: bool = false,
    edie18: bool = false,
    edie19: bool = false,
    edie20: bool = false,
    edie21: bool = false,
    edie22: bool = false,
    edie23: bool = false,
    edie24: bool = false,
    edie25: bool = false,
    edie26: bool = false,
    edie27: bool = false,
    edie28: bool = false,
    edie29: bool = false,
    reserved1: u2 = 0,
};

pub const Edcr = packed struct(u32) {
    edhc: bool = false,
    edlc: bool = false,
    reserved0: u30 = 0,
};

pub const Calib0 = packed struct(u32) {
    ncal: u6 = 0,
    reserved0: u10 = 0,
    pcal: u6 = 0,
    reserved1: u10 = 0,
};

pub const Calib1 = packed struct(u32) {
    ncal: u6 = 0,
    reserved0: u10 = 0,
    pcal: u6 = 0,
    reserved1: u10 = 0,
};

pub const Pcr = packed struct(u32) {
    ps: bool = false,
    pe: bool = false,
    reserved0: u1 = 0,
    sre: bool = false,
    reserved1: u1 = 0,
    ode: bool = false,
    dse: bool = false,
    reserved2: u1 = 0,
    mux: u4 = 0,
    ibe: bool = false,
    inv: bool = false,
    reserved3: u1 = 0,
    lk: bool = false,
    reserved4: u16 = 0,
};

pub const Port = extern struct {
    verid: Verid,
    reserved0: [3]u32,
    gpclr: Gpclr,
    gpchr: Gpchr,
    reserved1: [2]u32,
    config: Config,
    reserved2: [7]u32,
    edfr: Edfr,
    edier: Edier,
    edcr: Edcr,
    reserved3: [5]u32,
    calib0: Calib0,
    calib1: Calib1,
    reserved4: [6]u32,
    pcr: [30]Pcr,
};

pub const port0: *volatile Port = @ptrFromInt(PORT0_BASE);
pub const port1: *volatile Port = @ptrFromInt(PORT1_BASE);
pub const port2: *volatile Port = @ptrFromInt(PORT2_BASE);
pub const port3: *volatile Port = @ptrFromInt(PORT3_BASE);
pub const port4: *volatile Port = @ptrFromInt(PORT4_BASE);
pub const port5: *volatile Port = @ptrFromInt(PORT5_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0xF8, @sizeOf(Port));

}
