pub const GprcmPwren = packed struct(u32) {
    enable: bool = false,
    reserved: u23 = 0,
    key: u8 = 0x26
};

pub const GprcmRstctl = packed struct(u32) {
    resetassert: bool = false,
    resetstkyclr: bool = false,
    reserved: u22 = 0,
    key: u8 = 0xB1
};

pub const Clksel3 = packed struct(u32) {
    reserved: u1 = 0,
    lfclksel: bool = false,
    mfclksel: bool = false,
    busclksel: bool = false,
    reserved2: u28 = 0
};

pub const ClkDivRatio = enum(u3) {
    div1 = 0,
    div2 = 1,
    div3 = 2,
    div4 = 3,
    div5 = 4,
    div6 = 5,
    div7 = 6,
    div8 = 7
};

pub const ClkDiv = packed struct(u32) {
    ratio: ClkDivRatio = .div1,
    reserved: u29 = 0
};

pub fn powerStartupDelay() void {
    for (0..16) |_| {
        asm volatile("nop");
    }
}