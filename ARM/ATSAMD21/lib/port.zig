const PORTS_BASE = 0x41004400;

const PORT_GROUP_NUMBER = 2;

pub const PortWrConfig = packed struct(u32) {
    pinmask: u16 = 0,
    pmuxen: bool = false,
    inen: bool = false,
    pullen: bool = false,
    reserved: u3 = 0,
    drvstr: bool = false,
    reserved2: u1 = 0,
    pmux: u4 = 0,
    wrpmux: bool = false,
    reserved3: u1 = 0,
    wrpincfg: bool = false,
    hwsel: bool = false
};

pub const PortFunction = enum(u4) {
    A = 0,
    B = 1,
    C = 2,
    D = 3,
    E = 4,
    G = 6,
    H = 7
};

pub const PortPmux = packed struct(u8) {
    pmuxe: PortFunction = .A,
    pmuxo: PortFunction = .A
};

pub const PortPinCfg = packed struct(u8) {
    pmuxen: bool = false,
    inen: bool = false,
    pullen: bool = false,
    reserved: u3 = 0,
    drvstr: bool = false,
    reserved2: u1 = 0
};

pub const Port = extern struct {
    dir: u32,
    dirclr: u32,
    dirset: u32,
    dirtgl: u32,
    out: u32,
    outclr: u32,
    outset: u32,
    outtgl: u32,
    in: u32,
    ctrl: u32,
    wrconfig: PortWrConfig,
    reserved: u32,
    pmux: [16]PortPmux,
    pincfg: [32]PortPinCfg,
    reserved1: [8]u32,

    pub fn setPmux(self: *volatile Port, pin: u5, pmux: PortFunction) void {
        if (pin & 1 != 0) {
            self.pmux[pin/2].pmuxo = pmux;
        } else {
            self.pmux[pin/2].pmuxe = pmux;
        }
    }
};

pub const ports: *volatile [PORT_GROUP_NUMBER]Port = @ptrFromInt(PORTS_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(128, @sizeOf(Port));
}
