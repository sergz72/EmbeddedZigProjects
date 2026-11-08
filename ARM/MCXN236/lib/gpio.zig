const GPIO0_BASE = 0x40096000;
const GPIO1_BASE = 0x40098000;
const GPIO2_BASE = 0x4009A000;
const GPIO3_BASE = 0x4009C000;
const GPIO4_BASE = 0x4009E000;
const GPIO5_BASE = 0x40040000;

pub const Feature = enum(u16) {
    basic = 0,
    with_protection_registers = 1,
};

pub const Verid = packed struct(u32) {
    feature: Feature,
    minor: u8,
    major: u8,
};

pub const Param = packed struct(u32) {
    irqnum: u4,
    reserved0: u28,
};

pub const Lock = packed struct(u32) {
    pcns: bool = false,
    icns: bool = false,
    pcnp: bool = false,
    icnp: bool = false,
    reserved0: u28 = 0,
};

pub const Icns = packed struct(u32) {
    nse0: bool = false,
    nse1: bool = false,
    reserved0: u30 = 0,
};

pub const Icnp = packed struct(u32) {
    npe0: bool = false,
    npe1: bool = false,
    reserved0: u30 = 0,
};

pub const Icr = packed struct(u32) {
    reserved0: u16 = 0,
    irqc: u4 = 0,
    irqs: bool = false,
    reserved1: u2 = 0,
    lk: bool = false,
    isf: bool = false,
    reserved2: u7 = 0,
};

pub const Giclr = packed struct(u32) {
    giwe0: bool = false,
    giwe1: bool = false,
    giwe2: bool = false,
    giwe3: bool = false,
    giwe4: bool = false,
    giwe5: bool = false,
    giwe6: bool = false,
    giwe7: bool = false,
    giwe8: bool = false,
    giwe9: bool = false,
    giwe10: bool = false,
    giwe11: bool = false,
    giwe12: bool = false,
    giwe13: bool = false,
    giwe14: bool = false,
    giwe15: bool = false,
    giwd: u16 = 0,
};

pub const Gichr = packed struct(u32) {
    giwe16: bool = false,
    giwe17: bool = false,
    giwe18: bool = false,
    giwe19: bool = false,
    giwe20: bool = false,
    giwe21: bool = false,
    giwe22: bool = false,
    giwe23: bool = false,
    giwe24: bool = false,
    giwe25: bool = false,
    giwe26: bool = false,
    giwe27: bool = false,
    giwe28: bool = false,
    giwe29: bool = false,
    giwe30: bool = false,
    giwe31: bool = false,
    giwd: u16 = 0,
};

pub const Gpio = extern struct {
    verid: Verid,
    param: Param,
    reserved0: u32,
    lock: Lock,
    pcns: u32,
    icns: Icns,
    pcnp: u32,
    icnp: Icnp,
    reserved1: [8]u32,
    pdor: u32,
    psor: u32,
    pcor: u32,
    ptor: u32,
    pdir: u32,
    pddr: u32,
    pidr: u32,
    reserved2: u32,
    pdr: [32]u8,
    icr: [32]Icr,
    giclr: Giclr,
    gichr: Gichr,
    reserved4: [6]u32,
    isfr: [2]u32,
};

pub const gpio0: *volatile Gpio = @ptrFromInt(GPIO0_BASE);
pub const gpio1: *volatile Gpio = @ptrFromInt(GPIO1_BASE);
pub const gpio2: *volatile Gpio = @ptrFromInt(GPIO2_BASE);
pub const gpio3: *volatile Gpio = @ptrFromInt(GPIO3_BASE);
pub const gpio4: *volatile Gpio = @ptrFromInt(GPIO4_BASE);
pub const gpio5: *volatile Gpio = @ptrFromInt(GPIO5_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x128, @sizeOf(Gpio));
}
