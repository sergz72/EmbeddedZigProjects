const PM_BASE = 0x40000400;

pub const PmCtrla = bitpack struct(u8) {
    reserved0: u2 = 0,
    ioret: bool = false,
    reserved1: u5 = 0,
};

pub const PmSleepcfg = enum(u8) {
    idle = 2,
    standby = 4,
    hibernate = 5,
    backup = 6,
    off = 7,
};

pub const PmInt = bitpack struct(u8) {
    sleeprdy: bool = false,
    reserved0: u7 = 0,
};

pub const PmRamcfg = enum(u2) {
    ret = 0,
    partial = 1,
    off = 2,
};

pub const PmFastwkup = enum(u2) {
    no = 0,
    nvm = 1,
    mainvreg = 2,
    both = 3,
};

pub const PmStdbycfg = bitpack struct(u8) {
    ramcfg: PmRamcfg = .ret,
    reserved0: u2 = 0,
    fastwkup: PmFastwkup = .no,
    reserved1: u2 = 0,
};
    
pub const PmHibcfg = bitpack struct(u8) {
    ramcfg: PmRamcfg = .ret,
    bramcfg: PmRamcfg = .ret,
    reserved0: u4 = 0,
};

pub const PmBkupcfg = bitpack struct(u8) {
    bramcfg: PmRamcfg = .ret,
    reserved0: u6 = 0,
};

pub const PmPwsakdly = bitpack struct(u8) {
    dlyval: u7 = 0,
    ignack: bool = false,
};

pub const Pm = extern struct {
    ctrla: PmCtrla,
    sleepcfg: PmSleepcfg,
    reserved0: u16,
    intenclr: PmInt,
    intenset: PmInt,
    intflag: PmInt,
    reserved1: u8,
    stdbycfg: PmStdbycfg,
    hibcfg: PmHibcfg,
    bkupcfg: PmBkupcfg,
    reserved2: [7]u8,
    pwsakdly: PmPwsakdly,
    reserved3: u8,

    pub fn enterStandby(self: *volatile Pm) void {
        self.sleepcfg = .standby;
        while (self.sleepcfg != .standby) {
            asm volatile("nop");
        }
        asm volatile("dsb");
        asm volatile("wfi");
        self.sleepcfg = .idle;
        while (self.sleepcfg != .idle) {
            asm volatile("nop");
        }
    }
};

pub const pm: *volatile Pm = @ptrFromInt(PM_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x14, @sizeOf(Pm));
}
