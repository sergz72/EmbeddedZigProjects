const crm = @import("crm");

pub const PWC_BASE = 0x40007000;

pub const PwcPvmsel = enum(u3) {
    unused = 0,
    _2p3v = 1,
    _2p4v = 2,
    _2p5v = 3,
    _2p6v = 4,
    _2p7v = 5,
    _2p8v = 6,
    _2p9v = 7
};

pub const PwcCtrl = packed struct(u32) {
    vrsel: bool = false,
    lpsel: bool = false,
    clswef: bool = false,
    clsef: bool = false,
    pvmen: bool = false,
    pvmsel: PwcPvmsel = .unused,
    bpwen: bool = false,
    reserved5: u23 = 0
};

pub const PwcCtrlSts = packed struct(u32) {
    swef: bool = false,
    sef: bool = false,
    pvmof: bool = false,
    reserved: u5 = 0,
    swpen: bool = false,
    reserved5: u23 = 0
};

pub const Pwc = extern struct {
    ctrl: PwcCtrl,
    ctrlsts: PwcCtrlSts,

    pub fn enable() void {
        crm.crm.apb1en.pwc = true;
    }

    pub fn setBatteryPoweredDomainWriteAccess(self: *volatile Pwc, en: bool) void {
        self.ctrl.bpwen = en;
    }
};

pub const pwc: *volatile Pwc = @ptrFromInt(PWC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x14, @sizeOf(Pwc));
}
