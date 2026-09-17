const GPT_BASE: usize = 0x40078000;
const GPT_OPS_BASE: usize = 0x40078FF0;

pub const GptWp = packed struct(u32) {
    wp: bool = false,
    reserved: u7 = 0,
    prkey: u8 = 0xA5,
    reserved2: u16 = 0
};

pub const GptUddtyc = packed struct(u32) {
    ud: bool = true,
    udf: bool = false,
    reserved: u14 = 0,
    oadty: u2 = 0,
    oadtyf: bool = false,
    oadtyr: bool = false,
    reserved2: u4 = 0,
    obdty: u2 = 0,
    obdtyf: bool = false,
    obdtyr: bool = false,
    reserved3: u4 = 0
};

pub const GptTpcs = enum(u3) {
    div1 = 0,
    div4 = 1,
    div16 = 2,
    div64 = 3,
    div256 = 4,
    div1024 = 5
};

pub const GptCr = packed struct(u32) {
    cst: bool = false,
    reserved: u15 = 0,
    md: u3 = 0,
    reserved2: u5 = 0,
    tpcs: GptTpcs = .div1,
    reserved3: u5 = 0
};

pub const Gpt = extern struct {
    gtwp: GptWp,
    gtstr: u32,
    gtstp: u32,
    gtclr: u32,
    gtssr: u32,
    gtpsr: u32,
    gtcsr: u32,
    gtuptr: u32,
    gtdnsr: u32,
    gticasr: u32,
    gticbsr: u32,
    gtcr: GptCr,
    gtuddtyc: GptUddtyc,
    gtior: u32,
    gtintad: u32,
    gtst: u32,
    gtber: u32,
    reserved: u32,
    gtcnt: u32,
    gtccr: [6]u32,
    gtpr: u32,
    gtpbr: u32,
    reserved2: [7]u32,
    gtdtcr: u32,
    gtdvu: u32,
    reserved3: [28]u32
};

pub const gpt32: *volatile [2]Gpt = @ptrFromInt(GPT_BASE);
pub const gpt16: *volatile [6]Gpt = @ptrFromInt(GPT_BASE + 0x200);
pub const gpt_ops: *volatile u32 = @ptrFromInt(GPT_OPS_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x100, @sizeOf(Gpt));
}
