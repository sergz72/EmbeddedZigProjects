const crm = @import("crm");

const BPR_BASE = 0x40006C00;

pub const BprData = extern struct {
    data: u16,
    reserved: u16
};

pub const BprRtccal = packed struct(u16) {
    calval: u7 = 0,
    calout: bool = false,
    outen: bool = false,
    outsel: bool = false,
    ccos: bool = false,
    outm: bool = false,
    reserved: u4 = 0
};

pub const BprCtrl = packed struct(u16) {
    tpen: bool = false,
    tppol: bool = false,
    reserved: u14 = 0
};

pub const BprCtrlsts = packed struct(u16) {
    tpefclr: bool = false,
    tpifclr: bool = false,
    tpien: bool = false,
    reserved: u5 = 0,
    tpef: bool = false,
    tpif: bool = false,
    reserved2: u6 = 0
};

pub const Bpr = extern struct {
    reserved: u32,
    data: [10]BprData,
    rtccal: BprRtccal,
    reserved2: u16,
    ctrl: BprCtrl,
    reserved3: u16,
    ctrlsts: BprCtrlsts,
    reserved4: [5]u16,
    data2: [32]BprData,

    pub fn enable() void {
        crm.crm.apb1en.bpr = true;
    }

    pub fn reset() void {
        crm.crm.bpdc.bpdrst = true;
        crm.crm.bpdc.bpdrst = false;
    }
};

pub const bpr: *volatile Bpr = @ptrFromInt(BPR_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0xC0, @sizeOf(Bpr));
}
