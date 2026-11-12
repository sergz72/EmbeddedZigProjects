const CTIMER0_BASE = 0x4000C000;
const CTIMER1_BASE = 0x4000D000;
const CTIMER2_BASE = 0x4000E000;
const CTIMER3_BASE = 0x4000F000;
const CTIMER4_BASE = 0x40010000;

pub const Ir = bitpack struct(u32) {
    mr0int: bool = false,
    mr1int: bool = false,
    mr2int: bool = false,
    mr3int: bool = false,
    cr0int: bool = false,
    cr1int: bool = false,
    cr2int: bool = false,
    cr3int: bool = false,
    reserved0: u24 = 0,
};

pub const Tcr = bitpack struct(u32) {
    cen: bool = false,
    crst: bool = false,
    reserved0: u2 = 0,
    agcen: bool = false,
    atcen: bool = false,
    reserved1: u26 = 0,
};

pub const Mcr = bitpack struct(u32) {
    mr0i: bool = false,
    mr0r: bool = false,
    mr0s: bool = false,
    mr1i: bool = false,
    mr1r: bool = false,
    mr1s: bool = false,
    mr2i: bool = false,
    mr2r: bool = false,
    mr2s: bool = false,
    mr3i: bool = false,
    mr3r: bool = false,
    mr3s: bool = false,
    reserved0: u12 = 0,
    mr0rl: bool = false,
    mr1rl: bool = false,
    mr2rl: bool = false,
    mr3rl: bool = false,
    reserved1: u4 = 0,
};

pub const Ccr = bitpack struct(u32) {
    cap0re: bool = false,
    cap0fe: bool = false,
    cap0i: bool = false,
    cap1re: bool = false,
    cap1fe: bool = false,
    cap1i: bool = false,
    cap2re: bool = false,
    cap2fe: bool = false,
    cap2i: bool = false,
    cap3re: bool = false,
    cap3fe: bool = false,
    cap3i: bool = false,
    reserved0: u20 = 0,
};

pub const Emc = enum(u2) {
    do_nothing = 0,
    clear = 1,
    set = 2,
    toggle = 3
};

pub const Emr = bitpack struct(u32) {
    em0: bool = false,
    em1: bool = false,
    em2: bool = false,
    em3: bool = false,
    emc0: Emc = .do_nothing,
    emc1: Emc = .do_nothing,
    emc2: Emc = .do_nothing,
    emc3: Emc = .do_nothing,
    reserved0: u20 = 0,
};

pub const Ctmode = enum(u2) {
    timer = 0,
    counter_rising_edge = 1,
    counter_falling_edge = 2,
    counter_dual_edge = 3,
};

pub const Selcc = enum(u3) {
    channel_0_rising = 0,
    channel_0_falling = 1,
    channel_1_rising = 2,
    channel_1_falling = 3,
    channel_2_rising = 4,
    channel_2_falling = 5,
    channel_3_rising = 6,
    channel_3_falling = 7
};

pub const Ctcr = bitpack struct(u32) {
    ctmode: Ctmode = .timer,
    cinsel: u2 = 0,
    encc: bool = false,
    selcc: Selcc = .channel_0_rising,
    reserved0: u24 = 0,
};

pub const Pwmc = bitpack struct(u32) {
    pwmen0: bool = false,
    pwmen1: bool = false,
    pwmen2: bool = false,
    pwmen3: bool = false,
    reserved0: u28 = 0,
};

pub const Ctimer = extern struct {
    ir: Ir,
    tcr: Tcr,
    tc: u32,
    pr: u32,
    pc: u32,
    mcr: Mcr,
    mr: [4]u32,
    ccr: Ccr,
    cr: [4]u32,
    emr: Emr,
    reserved2: [12]u32,
    ctcr: Ctcr,
    pwmc: Pwmc,
    msr: [4]u32,
};

pub const ctimer0: *volatile Ctimer = @ptrFromInt(CTIMER0_BASE);
pub const ctimer1: *volatile Ctimer = @ptrFromInt(CTIMER1_BASE);
pub const ctimer2: *volatile Ctimer = @ptrFromInt(CTIMER2_BASE);
pub const ctimer3: *volatile Ctimer = @ptrFromInt(CTIMER3_BASE);
pub const ctimer4: *volatile Ctimer = @ptrFromInt(CTIMER4_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x88, @sizeOf(Ctimer));

}
