const builtin = @import("builtin");
const common = if (builtin.is_test) @import("common.zig") else @import("common");

const BTIMER0_BASE: usize = 0x400B8000 + 0x400;
const BTIMER1_BASE: usize = 0x400BA000 + 0x400;
const BTIMER2_BASE: usize = 0x400BC000 + 0x400;
const BTIMER3_BASE: usize = 0x400BE000 + 0x400;

pub const BTimerCtrregs = extern struct {
    ctl0: u32,
    ld: u32,
    cnt: u32,
    reserved0: [61]u32,
};

pub const BTimerInt = extern struct {
    iidx: u32,
    reserved0: u32,
    imask: u32,
    reserved1: u32,
    ris: u32,
    reserved2: u32,
    mis: u32,
    reserved3: u32,
    iset: u32,
    reserved4: u32,
    iclr: u32,
};

pub const BTimerGprcm = extern struct {
    pwren: common.GprcmPwren,
    rstctl: common.GprcmRstctl,
    reserved0: [3]u32,
    stat: u32,
};

pub const BTimer = extern struct {
    fsub_0: u32,
    reserved1: [16]u32,
    fpub_0: u32,
    reserved2: [238]u32,
    gprcm: BTimerGprcm,
    reserved3: [512]u32,
    pdbgctl: u32,
    reserved4: u32,
    cpu_int: BTimerInt,
    reserved5: u32,
    gen_event: BTimerInt,
    reserved6: [25]u32,
    evt_mode: u32,
    reserved7: [7]u32,
    ctrregs: [2]BTimerCtrregs,

    pub inline fn enablePower(self: *volatile BTimer) void {
        self.gprcm.pwren = common.GprcmPwren{.enable = true};
    }

    pub inline fn reset(self: *volatile BTimer) void {
        self.gprcm.rstctl = common.GprcmRstctl{.resetassert = true, .resetstkyclr = true};
    }
};

pub const btimer0: *volatile BTimer = @ptrFromInt(BTIMER0_BASE);
pub const btimer1: *volatile BTimer = @ptrFromInt(BTIMER1_BASE);
pub const btimer2: *volatile BTimer = @ptrFromInt(BTIMER2_BASE);
pub const btimer3: *volatile BTimer = @ptrFromInt(BTIMER3_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(3840, @sizeOf(BTimer));
}
