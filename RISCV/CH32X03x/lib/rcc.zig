const RCC_BASE: usize = 0x40021000;

pub const RccCtlr = packed struct(u32) {
    hsion: bool,
    hsirdy: bool,
    reserved: u1,
    hsitrim: u5,
    hsical: u8,
    reserved2: u16
};

pub const RccCfgrHpre = enum(u4) {
    off = 0,
    div2 = 1,
    div3 = 2,
    div4 = 3,
    div5 = 4,
    div6 = 5,
    div7 = 6,
    div8 = 7,
    div16 = 11,
    div32 = 12,
    div64 = 13,
    div128 = 14,
    div256 = 15
};

pub const RccCfgrMco = enum(u3) {
    off = 0,
    sysclk = 4,
    hsi = 5
};

pub const RccCfgr0 = packed struct(u32) {
    reserved: u4 = 0,
    hpre: RccCfgrHpre = RccCfgrHpre.div6,
    reserved2: u16 = 0,
    mco: RccCfgrMco = RccCfgrMco.off,
    reserved3: u5 = 0
};

pub const RccCfgrAhbpcEnr = packed struct(u32) {
    dma1en: bool = false,
    reserved: u1 = 0,
    sramen: bool = true,
    reserved2: u9 = 0,
    usbfsen: bool = true,
    reserved3: u4 = 0,
    usbpd: bool = true,
    reserved4: u14 = 0
};

pub const RccCfgrApb2pcEnr = packed struct(u32) {
    afioen: bool = false,
    reserved: u1 = 0,
    iopaen: bool = false,
    iopben: bool = false,
    iopcen: bool = false,
    reserved3: u4 = 0,
    adc1en: bool = false,
    reserved4: u1 = 0,
    tim1en: bool = false,
    spi1en: bool = false,
    reserved5: u1 = 0,
    usart1en: bool = false,
    reserved6: u17 = 0
};

pub const RccCfgrApb1pcEnr = packed struct(u32) {
    tim2en: bool = false,
    tim3en: bool = false,
    reserved: u9 = 0,
    wwdgen: bool = false,
    reserved2: u5 = 0,
    usart2en: bool = false,
    usart3en: bool = false,
    usart4en: bool = false,
    reserved3: u1 = 0,
    i2c1en: bool = false,
    reserved4: u6 = 0,
    pwren: bool = false,
    reserved5: u3 = 0
};

pub const Rcc = extern struct {
    ctlr: RccCtlr,
    cfgr0: RccCfgr0,
    reserved: u32,
    apb2prstr: u32,
    apb1prstr: u32,
    ahbpcenr: RccCfgrAhbpcEnr,
    apb2pcenr: RccCfgrApb2pcEnr,
    apb1pcenr: RccCfgrApb1pcEnr,
    reserved2: u32,
    rstsckr: u32,
    ahbrstr: u32
};

pub const rcc: *volatile Rcc = @ptrFromInt(RCC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x28, @sizeOf(Rcc));
}
