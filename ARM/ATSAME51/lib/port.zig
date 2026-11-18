const PORTS_BASE = 0x41008000;

const PORT_GROUP_NUMBER = 3;

pub const PortWrconfig = bitpack struct(u32) {
    pinmask: u16 = 0,
    pmuxen: bool = false,
    inen: bool = false,
    pullen: bool = false,
    reserved0: u3 = 0,
    drvstr: bool = false,
    reserved1: u1 = 0,
    pmux: u4 = 0,
    wrpmux: bool = false,
    reserved2: u1 = 0,
    wrpincfg: bool = false,
    hwsel: bool = false,
};

pub const PortEvact = enum(u2) {
    out = 0,
    set = 1,
    clr = 2,
    tgl = 3,
};

pub const PortEvctrl = bitpack struct(u32) {
    pid0: u5 = 0,
    evact0: PortEvact = .out,
    portei0: bool = false,
    pid1: u5 = 0,
    evact1: PortEvact = .out,
    portei1: bool = false,
    pid2: u5 = 0,
    evact2: PortEvact = .out,
    portei2: bool = false,
    pid3: u5 = 0,
    evact3: PortEvact = .out,
    portei3: bool = false,
};

pub const PortFunction = enum(u4) {
    A = 0,
    B = 1,
    C = 2,
    D = 3,
    E = 4,
    F = 5,
    G = 6,
    H = 7,
    I = 8,
    J = 9,
    K = 10,
    L = 11,
    M = 12,
    N = 13,
};

pub const PortPmux = bitpack struct(u8) {
    pmuxe: PortFunction = .A,
    pmuxo: PortFunction = .A,
};

pub const PortPincfg = bitpack struct(u8) {
    pmuxen: bool = false,
    inen: bool = false,
    pullen: bool = false,
    reserved0: u3 = 0,
    drvstr: bool = false,
    reserved1: u1 = 0,
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
    wrconfig: PortWrconfig,
    evctrl: PortEvctrl,
    pmux: [16]PortPmux,
    pincfg: [32]PortPincfg,
    reserved: [8]u32,

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
    try std.testing.expectEqual(0x80, @sizeOf(Port));
}
