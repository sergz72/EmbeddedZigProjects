pub const WWDT_BASE = 0x40002C00;

pub const WwdtCtrl = packed struct(u32) {
    cnt: u7 = 0x7F,
    wwdten: bool = false,
    reserved1: u24 = 0
};

pub const WwdtDiv = enum(u2) {
    div4096 = 0,
    div8192 = 1,
    div16384 = 2,
    div32768 = 3
};

pub const WwdtCfg = packed struct(u32) {
    win: u7 = 0x7F,
    div: WwdtDiv,
    rldien: bool = false,
    reserved1: u22 = 0
};

pub const WwdtSts = packed struct(u32) {
    rldf: bool = false,
    reserved1: u31 = 0
};

pub const Wwdt = extern struct {
    ctrl: WwdtCtrl,
    cfg: WwdtCfg,
    sts: WwdtSts
};

pub const wwdt: *volatile Wwdt = @ptrFromInt(WWDT_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x0C, @sizeOf(Wwdt));
}
