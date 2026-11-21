const OTG_FS_DEVICE_BASE = 0x50000800;
const OTG_HS_DEVICE_BASE = 0x40040800;

pub const UsbPfivl = enum(u2) {
    _80p = 0,
    _85p = 1,
    _90p = 2,
    _95p = 3
};

pub const UsbSpeed = enum(u2) {
    reserved = 0,
    full = 3
};

pub const UsbDcfg = bitpack struct(u32) {
    dspd: UsbSpeed = .reserved,
    nzlsohsk: bool = false,
    reserved0: u1 = 0,
    dad: u7 = 0,
    pfivl: UsbPfivl = ._80p,
    reserved1: u2 = 0,
    erratim: bool = false,
    reserved2: u16
};

pub const UsbDctl = bitpack struct(u32) {
    rwusig: bool = false,
    sdis: bool = false,
    ginsts: bool = false,
    gonsts: bool = false,
    tctl: u3 = 0,
    sginak: bool = false,
    cginak: bool = false,
    sgonak: bool = false,
    cgonak: bool = false,
    poprgdne: bool = false,
    reserved0: u20 = 0,
};

pub const UsbDsts = bitpack struct(u32) {
    suspsts: bool,
    enumspd: u2,
    eerr: bool,
    reserved0: u4,
    fnsof: u14,
    reserved1: u10,
};

pub const UsbDiepmsk = bitpack struct(u32) {
    xfrcm: bool = false,
    epdm: bool = false,
    reserved0: u1 = 0,
    tom: bool = false,
    ittxfemsk: bool = false,
    inepnmm: bool = false,
    inepnem: bool = false,
    reserved1: u1 = 0,
    txfurm: bool = false,
    reserved2: u4 = 0,
    nakm: bool = false,
    reserved3: u18 = 0,
};

pub const UsbDoepmsk = bitpack struct(u32) {
    xfrcm: bool = false,
    epdm: bool = false,
    reserved0: u1 = 0,
    stupm: bool = false,
    otepdm: bool = false,
    reserved1: u27 = 0,
};

pub const UsbDaint = bitpack struct(u32) {
    iepint: u16,
    oepint: u16,
};

pub const UsbDaintmsk = bitpack struct(u32) {
    iepm: u16 = 0,
    oepint: u16 = 0,
};

pub const UsbDvbusdis = bitpack struct(u32) {
    vbusdt: u16 = 6103,
    reserved0: u16 = 0,
};

pub const UsbDvbuspulse = bitpack struct(u32) {
    dvbusp: u12 = 1464,
    reserved0: u20 = 0,
};

pub const UsbDiepempmsk = bitpack struct(u32) {
    ineptxfem: u16 = 0,
    reserved0: u16 = 0,
};

pub const UsbDiepctl = bitpack struct(u32) {
    mpsiz: u11 = 0,
    reserved0: u4 = 0,
    usbaep: bool = false,
    eonum_dpid: bool = false,
    naksts: bool = false,
    eptyp: u2 = 0,
    reserved1: u1 = 0,
    stall: bool = false,
    txfnum: u4 = 0,
    cnak: bool = false,
    snak: bool = false,
    sd0pid_sevnfrm: bool = false,
    soddfrm_sd1pid: bool = false,
    epdis: bool = false,
    epena: bool = false,
};

pub const UsbDiepint = bitpack struct(u32) {
    xfrc: bool = false,
    epdisd: bool = false,
    reserved0: u1 = 0,
    toc: bool = false,
    ittxfe: bool = false,
    reserved1: u1 = 0,
    inepne: bool = false,
    txfe: bool = true,
    reserved2: u24 = 0,
};

pub const UsbDieptsiz = bitpack struct(u32) {
    xfrsiz: u19 = 0,
    pktcnt: u10 = 0,
    mcnt: u2 = 0,
    reserved0: u1 = 0,
};

pub const UsbDtxfsts = bitpack struct(u32) {
    ineptfsav: u16,
    reserved0: u16,
};

pub const UsbDoepctl = bitpack struct(u32) {
    mpsiz: u11 = 0,
    reserved0: u4 = 0,
    usbaep: bool = false,
    eonum_dpid: bool = false,
    naksts: bool = false,
    eptyp: u2 = 0,
    snpm: bool = false,
    stall: bool = false,
    reserved1: u4 = 0,
    cnak: bool = false,
    snak: bool = false,
    sd0pid_sevnfrm: bool = false,
    soddfrm: bool = false,
    epdis: bool = false,
    epena: bool = false,
};

pub const UsbDoeptsiz = bitpack struct(u32) {
    xfrsiz: u19 = 0,
    pktcnt: u10 = 0,
    rxdpid_stupcnt: u2 = 0,
    reserved0: u1 = 0,
};

pub const UsbDoepint = bitpack struct(u32) {
    xfrc: bool = false,
    epdisd: bool = false,
    reserved0: u1 = 0,
    stup: bool = false,
    otepdis: bool = false,
    reserved1: u1 = 0,
    b2bstup: bool = false,
    reserved2: u25 = 1,
};

pub const UsbDiep = extern struct {
    ctl: UsbDiepctl,
    reserved4: u32,
    int: UsbDiepint,
    reserved5: u32,
    tsiz: UsbDieptsiz,
    dma: u32,
    dtxfsts: UsbDtxfsts,
    reserved7: u32
};

pub const UsbDoep = extern struct {
    ctl: UsbDoepctl,
    reserved20: u32,
    int: UsbDoepint,
    reserved21: u32,
    tsiz: UsbDoeptsiz,
    dma: u32,
    reserved22: [2]u32,
};

pub const UsbOtgDevice = extern struct {
    dcfg: UsbDcfg,
    dctl: UsbDctl,
    dsts: UsbDsts,
    reserved0: u32,
    diepmsk: UsbDiepmsk,
    doepmsk: UsbDoepmsk,
    daint: UsbDaint,
    daintmsk: UsbDaintmsk,
    reserved1: [2]u32,
    dvbusdis: UsbDvbusdis,
    dvbuspulse: UsbDvbuspulse,
    reserved2: u32,
    diepempmsk: UsbDiepempmsk,
    reserved3: [50]u32,
    diep: [8]UsbDiep,
    reserved19: [64]u32,
    doep: [9]UsbDoep,

    pub fn setFullSpeed(self: *volatile UsbOtgDevice) void {
        self.dcfg.dspd = .full;
    }

    pub fn init(self: *volatile UsbOtgDevice, in_endpoints: u4, out_endpoints: u4) void {
        self.dcfg.pfivl = ._80p;
        self.setFullSpeed();
        self.diepempmsk = UsbDiepempmsk{};
        self.doepmsk = UsbDoepmsk{};
        self.daint = UsbDaint{.iepint = 0xFFFF, .oepint = 0xFFFF};
        self.daintmsk = UsbDaintmsk{};

        for (0..in_endpoints) |i| {
            var ep = &self.diep[i];
            if (ep.ctl.epena) {
                ep.ctl = UsbDiepctl{.epdis = true, .cnak = true};
            } else {
                ep.ctl = UsbDiepctl{};
            }
            ep.tsiz = UsbDieptsiz{};
            ep.int = UsbDiepint{
                .epdisd = true,
                .inepne = true,
                .txfe = true,
                .xfrc = true,
                .ittxfe = true,
                .nak = true,
                .toc = true
            };
        }
        for (0..out_endpoints) |i| {
            var ep = &self.doep[i];
            if (ep.ctl.epena) {
                ep.ctl = UsbDoepctl{.epdis = true, .cnak = true};
            } else {
                ep.ctl = UsbDoepctl{};
            }
            ep.tsiz = UsbDoeptsiz{};
            ep.int = UsbDoepint{
                .b2bstup = true,
                .xfrc = true,
                .stup = true,
                .otepdis = true,
                .epdisd = true
            };
        }
        self.diepmsk.txfurm = false;
    }
};

pub const otg_fs_device: *volatile UsbOtgDevice = @ptrFromInt(OTG_FS_DEVICE_BASE);
pub const otg_hs_device: *volatile UsbOtgDevice = @ptrFromInt(OTG_HS_DEVICE_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0xC20-0x800, @sizeOf(UsbOtgDevice));
}
