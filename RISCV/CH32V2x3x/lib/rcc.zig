const cpu = @import("cpu");

const RCC_BASE: usize = 0x40021000;

pub const RccCtlr = packed struct(u32) {
    hsion: bool,
    hsirdy: bool,
    reserved: u1,
    hsitrim: u5,
    hsical: u8,
    hseon: bool,
    hserdy: bool,
    hsebyp: bool,
    csson: bool,
    reserved2: u4,
    pllon: bool,
    pllrdy: bool,
    pll2on: bool,
    pll2rdy: bool,
    pll3on: bool,
    pll3rdy: bool,
    reserved3: u2
};

pub const RccCfgr0Sw = enum(u2) {
    hsi = 0,
    hse = 1,
    pll = 2
};

pub const RccCfgrHpre = enum(u4) {
    off = 0,
    div2 = 8,
    div4 = 9,
    div8 = 10,
    div16 = 11,
    div64 = 12,
    div128 = 13,
    div256 = 14,
    div512 = 15
};

pub const RccCfgrPpre = enum(u3) {
    off = 0,
    div2 = 4,
    div4 = 5,
    div8 = 6,
    div16 = 7
};

pub const RccCfgrAdcpre = enum(u2) {
    div2 = 0,
    div4 = 1,
    div6 = 2,
    div8 = 3
};

pub const RccCfgrUsbpre = enum(u2) {
    off = 0,
    div2 = 1,
    div3 = 2,
    div5 = 3
};

pub const RccCfgrMco = enum(u4) {
    off = 0,
    sysclk = 4,
    hsi = 5,
    hse = 6,
    plldiv2 = 7,
    pll2 = 8,
    pll3div2 = 9,
    xt1 = 10,
    pll3 = 11
};

pub const RccCfgr0 = packed struct(u32) {
    sw: RccCfgr0Sw = RccCfgr0Sw.hsi,
    sws: RccCfgr0Sw = RccCfgr0Sw.hsi,
    hpre: RccCfgrHpre = RccCfgrHpre.off,
    ppre1: RccCfgrPpre = RccCfgrPpre.off,
    ppre2: RccCfgrPpre = RccCfgrPpre.off,
    adcpre: RccCfgrAdcpre = RccCfgrAdcpre.div2,
    pllsrc_hse_or_prediv1: bool  = false,
    pllxtpre: bool = false,
    pllmul: u4 = 0,
    usbpre: RccCfgrUsbpre = RccCfgrUsbpre.off,
    mco: RccCfgrMco = RccCfgrMco.off,
    ethpre2: bool = false,
    reserved: u1 = 0,
    adc_duty_sel75: bool = false,
    adc_duty_gt50: bool = false
};

pub const RccCfgr2 = packed struct(u32) {
    prediv1: u4 = 0,
    prediv2: u4 = 0,
    pll2mul: u4 = 0,
    pll3mul: u4 = 0,
    prediv1_src_pll2: bool = false,
    i2s2src_pll3: bool = false,
    i2s3src_pll3: bool = false,
    rngsrc_pll3: bool = false,
    eth1gsrc: u2 = 0,
    eth1g_125m_en: bool = false,
    reserved: u1 = 0,
    usbhsdiv: u3 = 0,
    usbhspllsrc_his: bool = false,
    usbhsclk: u2 = 0,
    usbhspll: bool = false,
    usbhssrc_phy: bool = false
};

pub const RccCfgrAhbpcEnr = packed struct(u32) {
    dma1en: bool = false,
    dma2en: bool = false,
    sramen: bool = true,
    reserved: u3 = 0,
    crcen: bool = false,
    reserved2: u1 = 0,
    fmcen: bool = false,
    rngen: bool = false,
    sdioen: bool = false,
    usbhsen: bool = false,
    otg_fsen: bool = false,
    dvpen: bool = false,
    ethmacen: bool = false,
    ethmactxen: bool = false,
    ethmacrxen_blec: bool = false,
    bles: bool = false,
    reserved3: u14 = 0
};

pub const RccCfgrApb2pcEnr = packed struct(u32) {
    afioen: bool = false,
    reserved: u1 = 0,
    iopaen: bool = false,
    iopben: bool = false,
    iopcen: bool = false,
    iopden: bool = false,
    iopeen: bool = false,
    reserved3: u2 = 0,
    adc1en: bool = false,
    adc2en: bool = false,
    tim1en: bool = false,
    spi1en: bool = false,
    tim8en: bool = false,
    usart1en: bool = false,
    reserved4: u4 = 0,
    tim9en: bool = false,
    tim10en: bool = false,
    reserved6: u11 = 0
};

pub const RccCfgrApb1pcEnr = packed struct(u32) {
    tim2en: bool = false,
    tim3en: bool = false,
    tim4en: bool = false,
    tim5en: bool = false,
    tim6en: bool = false,
    tim7en: bool = false,
    usart6en: bool = false,
    usart7en: bool = false,
    usart8en: bool = false,
    reserved: u2 = 0,
    wwdgen: bool = false,
    reserved2: u2 = 0,
    spi2en: bool = false,
    spi3en: bool = false,
    reserved3: u1 = 0,
    usart2en: bool = false,
    usart3en: bool = false,
    usart4en: bool = false,
    usart5en: bool = false,
    i2c1en: bool = false,
    i2c2en: bool = false,
    usbden: bool = false,
    reserved4: u1 = 0,
    can1en: bool = false,
    can2en: bool = false,
    bkpen: bool = false,
    pwren: bool = false,
    dacen: bool = false,
    reserved5: u2 = 0
};

pub const RccCfgrRtcsel = enum(u2) {
    off = 0,
    lse = 1,
    lsi = 2,
    hse = 3
};

pub const RccCfgrBdctlr = packed struct(u32) {
    lseon: bool = false,
    lserdy: bool = false,
    lsebyp: bool = false,
    reserved: u5 = 0,
    rtcsel: RccCfgrRtcsel = .off,
    reserved2: u5 = 0,
    rtcen: bool = false,
    bdrst: bool = false,
    reserved3: u15 = 0,
};

pub const RccRstsckr = packed struct(u32) {
    lsion: bool = false,
    lsirdy: bool = false,
    reserved1: u22 = 0,
    rmvf: bool = false,
    reserved2: u1 = 0,
    pinrstf: bool = true,
    porrstf: bool = true,
    sftrstf: bool = false,
    iwdgrstf: bool = false,
    wwdgrstf: bool = false,
    reserved: u1 = 0
};

pub const Rcc = extern struct {
    ctlr: RccCtlr,
    cfgr0: RccCfgr0,
    intr: u32,
    apb2prstr: u32,
    apb1prstr: u32,
    ahbpcenr: RccCfgrAhbpcEnr,
    apb2pcenr: RccCfgrApb2pcEnr,
    apb1pcenr: RccCfgrApb1pcEnr,
    bdctlr: RccCfgrBdctlr,
    rstsckr: RccRstsckr,
    ahbrstr: u32,
    cfgr2: RccCfgr2,

    pub fn enableLsi(self: *volatile Rcc) void {
        self.rstsckr.lsion = true;
        while (!self.rstsckr.lsirdy) {
            asm volatile("nop");
        }
    }

    pub fn rtcEnable(self: *volatile Rcc) void {
        self.bdctlr.lseon = true;
        while (!self.bdctlr.lserdy) {
            asm volatile ("nop");
        }
        self.bdctlr.rtcsel = .lse;
        self.bdctlr.rtcen = true;
    }

    pub fn usbFsClkConfig(self: *volatile Rcc) bool {
        switch (cpu.cpu.current_frequency) {
            144000000 => {
                self.cfgr0.usbpre = .div3;
                return true;
            },
            96000000 => {
                self.cfgr0.usbpre = .div2;
                return true;
            },
            48000000 => {
                self.cfgr0.usbpre = .off;
                return true;
            },
            else => return false
        }
    }

    fn hseOn(self: *volatile Rcc) void {
        self.ctlr.hseon = true;
        while (!self.ctlr.hserdy) {
            asm volatile ("nop");
        }
    }

    fn pllOn(self: *volatile Rcc) void {
        self.ctlr.pllon = true;
        while (!self.ctlr.pllrdy) {
            asm volatile ("nop");
        }
        self.cfgr0.sw = .pll;
        while (self.cfgr0.sws != .pll) {
            asm volatile ("nop");
        }
    }

    pub fn setSystemClockToHSE(self: *volatile Rcc) void {
        self.hseOn();
        self.cfgr0.sw = .hse;
        while (self.cfgr0.sws != .hse) {
            asm volatile ("nop");
        }
    }

    pub fn setSystemClockTo48MHz(self: *volatile Rcc) void {
        self.hseOn();
        self.cfgr0.pllsrc_hse_or_prediv1 = true;
        self.cfgr0.pllmul = 4; // MUL6 - 8MHz * 6 = 48MHz
        self.pllOn();
        cpu.cpu.setAll(48000000);
    }

    pub fn getResetCause(self: *volatile Rcc) []const u8 {
        const sts = self.rstsckr;
        self.rstsckr.rmvf = true; // Clear reset flags after reading
        if (sts.wwdgrstf) return "WWDG Reset";
        if (sts.iwdgrstf) return "IWDG Reset";
        if (sts.sftrstf) return "Software Reset";
        if (sts.porrstf) return "POR Reset";
        if (sts.pinrstf) return "NRST Reset";
        return "Unknown Reset Cause";
    }
};

pub const rcc: *volatile Rcc = @ptrFromInt(RCC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x28, @sizeOf(Rcc));
}
