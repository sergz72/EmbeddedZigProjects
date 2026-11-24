const SWPMI_BASE = 0x40008400;

pub const SwpmiCr = bitpack struct(u32) {
    rxdma: bool = false,
    txdma: bool = false,
    rxmode: bool = false,
    txmode: bool = false,
    lpbk: bool = false,
    swpact: bool = false,
    reserved0: u4 = 0,
    deact: bool = false,
    swpten: bool = false,
    reserved1: u20 = 0,
};

pub const SwpmiIsr = bitpack struct(u32) {
    rxbff: bool,
    txbef: bool,
    rxberf: bool,
    rxovrf: bool,
    txunrf: bool,
    rxne: bool,
    txe: bool,
    tcf: bool,
    srf: bool,
    susp: bool,
    deactf: bool,
    rdyf: bool,
    reserved0: u20,
};

pub const SwpmiIcr = bitpack struct(u32) {
    crxbff: bool = false,
    ctxbef: bool = false,
    crxberf: bool = false,
    crxovrf: bool = false,
    ctxunrf: bool = false,
    reserved0: u2 = 0,
    ctcf: bool = false,
    csrf: bool = false,
    reserved1: u2 = 0,
    crdyf: bool = false,
    reserved2: u20 = 0,
};

pub const SwpmiIer = bitpack struct(u32) {
    rxbfie: bool = false,
    txbeie: bool = false,
    rxberie: bool = false,
    rxovrie: bool = false,
    txunrie: bool = false,
    rie: bool = false,
    tie: bool = false,
    tcie: bool = false,
    srie: bool = false,
    reserved0: u2 = 0,
    rdyie: bool = false,
    reserved1: u20 = 0,
};

pub const SwpmiOr = bitpack struct(u32) {
    swp_tbyp: bool = false,
    reserved0: u1 = 0,
    swp_isel: u2 = 0,
    reserved1: u28 = 0,
};

pub const Swpmi = extern struct {
    cr: SwpmiCr,
    brr: u32,
    reserved0: u32,
    isr: SwpmiIsr,
    icr: SwpmiIcr,
    ier: SwpmiIer,
    rfl: u32,
    tdr: u32,
    rdr: u32,
    swpmi_or: SwpmiOr,
};

pub const swpmi: *volatile Swpmi = @ptrFromInt(SWPMI_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x28, @sizeOf(Swpmi));
}
