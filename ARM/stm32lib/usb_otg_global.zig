const usb_device = @import("usb_device");
const usb_otg_device = @import("usb_otg_device");
const cpu = @import("cpu");
const system_timer = @import("system_timer");
const nvic = @import("nvic");
const interrupts = @import("interrupts");

const DEVICE_OFFSET = 0x800;
const PWRCLK_OFFSET = 0xE00;

const USB_OTG_FS_BASE: usize = 0x50000000;
const USB_OTG_HS_BASE: usize = 0x40040000;

pub const UsbPcgcctl = bitpack struct(u32) {
    stppclk: bool = false,
    gatehclk: bool = false,
    reserved0: u2 = 0,
    physusp: bool = false,
    reserved1: u27 = 0,
};

pub const UsbGotgctl = bitpack struct(u32) {
    srqscs: bool = false,
    srq: bool = false,
    vbvaloen: bool = false,
    vbvaloval: bool = false,
    avaloen: bool = false,
    avaloval: bool = false,
    bvaloen: bool = false,
    bvaloval: bool = false,
    hngscs: bool = false,
    hnprq: bool = false,
    hshnpen: bool = false,
    dhnpen: bool = false,
    reserved2: u4 = 0,
    cidsts: bool = true,
    dbct: bool = false,
    asvld: bool = false,
    bsvld: bool = false,
    reserved3: u12 = 0
};

pub const UsbGotgint = bitpack struct(u32) {
    reserved: u2 = 0,
    sedet: bool = false,
    reserved2: u5 = 0,
    srsschg: bool = false,
    hnsschg: bool = false,
    reserved3: u7 = 0,
    hngdet: bool = false,
    adtochg: bool = false,
    dbccne: bool = false,
    reserved4: u12 = 0
};

pub const UsbGahbcfg = bitpack struct(u32) {
    gintmsk: bool = false,
    reserved: u6 = 0,
    txfelvl: bool = false,
    ptxfelvl: bool = false,
    reserved2: u23 = 0
};

pub const UsbGusbcfg = bitpack struct(u32) {
    tocal: u3 = 0,
    reserved: u3 = 0,
    physel: bool = true,
    reserved2: u1 = 0,
    srpcap: bool = false,
    hnpcap: bool = true,
    trdt: u4 = 2,
    reserved3: u15 = 0,
    fhmod: bool = false,
    fdmod: bool = false,
    ctxpkt: bool = false
};

pub const UsbGrstctl = bitpack struct(u32) {
    csrst: bool = false,
    hsrst: bool = false,
    fcrst: bool = false,
    reserved: u1 = 0,
    rxfflsh: bool = false,
    txfflsh: bool = false,
    txfnum: u5 = 0,
    reserved2: u20 = 0,
    ahbidl: bool = true
};

pub const UsbGint = bitpack struct(u32) {
    cmod: bool = false,
    mmis: bool = false,
    otgnt: bool = false,
    sof: bool = false,
    rxflvl: bool = false,
    nptxfe: bool = false,
    gnakeff: bool = false,
    gonakeff: bool,
    reserved: u2 = 0,
    esusp: bool = false,
    usbsusp: bool = false,
    usbrst: bool = false,
    enumdne: bool = false,
    isoodrp: bool = false,
    eopf: bool = false,
    reserved2: u2 = 0,
    iepint: bool = false,
    oepint: bool = false,
    iisoixfr: bool = false,
    ipfxr_incompisoout: bool = false,
    reserved3: u2 = 0,
    hprint: bool = false,
    hcint: bool = false,
    ptxfe: bool = false,
    reserved4: u1 = 0,
    cidschg: bool = false,
    discnt: bool = false,
    srqint: bool = false,
    wkupint: bool = false
};

pub const UsbGrxstsr = bitpack struct(u32) {
    chnum: u4,
    bcnt: u11,
    dpid: u2,
    pktsts: u4,
    frmnum: u4,
    reserved0: u7,
};

pub const UsbGrxstsp = bitpack struct(u32) {
    epnum: u4,
    bdcnt: u11,
    dpid: u2,
    pktsts: u4,
    frmnum: u4,
    reserved: u1,
    stsphst: bool,
    reserved1: u5,
};

pub const UsbHnptxsts = bitpack struct(u32) {
    nptxfsav: u16,
    nptqxsav: u8,
    nptxqtop: u7,
    reserved0: u1,
};

pub const UsbGccfg = bitpack struct(u32) {
    reserved0: u16,
    pwrdwn: bool = false,
    i2cpaden: bool = false,
    vbusasen: bool = false,
    vbusbsen: bool = false,
    sofouten: bool = false,
    vbden_novbussens: bool = false,
    reserved2: u10 = 0,
};

pub const UsbGlpmcfg = bitpack struct(u32) {
    lpmen: bool = false,
    lpmack: bool = false,
    besl: u4 = 0,
    remwake: bool = false,
    l1ssen: bool = false,
    neslthrs: u4 = 0,
    l1dsen: bool = false,
    lpmrsp: u2 = 0,
    slpsts: bool = false,
    l1rsmok: bool = false,
    lpmchidx: u4 = 0,
    lpmrcnt: u3 = 0,
    sndlpm: bool = false,
    lpmrcntsts: u3 = 0,
    enbesl: bool = false,
    reserved: u3 = 0
};

pub const UsbTxf = bitpack struct(u32) {
    txsa: u16,
    txfd: u16
};

pub const UsbOtgInit = struct {
    timeout: usize,
    vbus_sensing_enable: bool,
    novbussens: bool,
    in_endpoints: u4,
    out_endpoints: u4
};

pub const UsbOtgGlobal = extern struct {
    gotgctl: UsbGotgctl,
    gotgint: UsbGotgint,
    gahbcfg: UsbGahbcfg,
    gusbcfg: UsbGusbcfg,
    grstctl: UsbGrstctl,
    gintsts: UsbGint,
    gintmsk: UsbGint,
    grxstsr: UsbGrxstsr,
    grxstsp: UsbGrxstsp,
    grxfsiz: u32,
    dieptxf0_hnptxfsiz: u32,
    hnptxsts: UsbHnptxsts,
    reserved30: [2]u32,
    gccfg: UsbGccfg,
    cid: u32,
    reserved40: [3]u32,
    ghwcfg3: u32,
    reserved6: u32,
    glpmcfg: UsbGlpmcfg,
    reserved: u32,
    gdfifocfg: u32,
    reserved43: [40]u32,
    dieptxf: [8]UsbTxf,

    fn getDevice(self: *volatile UsbOtgGlobal) *volatile usb_otg_device.UsbOtgDevice {
        return @ptrFromInt(@intFromPtr(self) + DEVICE_OFFSET);
    }

    fn getPcgctl(self: *volatile UsbOtgGlobal) *volatile UsbPcgcctl {
        return @ptrFromInt(@intFromPtr(self) + PWRCLK_OFFSET);
    }

    fn waitAhbid(self: *volatile UsbOtgGlobal, timeout: usize) bool {
        for (0..timeout) |_| {
            if (self.grstctl.ahbidl) {
                return true;
            }
        }
        return false;
    }

    fn waitCsrst(self: *volatile UsbOtgGlobal, timeout: usize) bool {
        for (0..timeout) |_| {
            if (!self.grstctl.csrst) {
                return true;
            }
        }
        return false;
    }

    fn reset(self: *volatile UsbOtgGlobal, timeout: usize) bool {
        if (!self.waitAhbid(timeout)) {
            return false;
        }
        self.grstctl.csrst = true;
        return self.waitCsrst(timeout);
    }

    pub fn coreInit(self: *volatile UsbOtgGlobal, timeout: usize) bool {
        self.gusbcfg.physel = true; // Select FS Embedded PHY
        if (!self.reset(timeout)) {
            return false;
        }
        self.gccfg.pwrdwn = true;
        return true;
    }

    pub fn flushTxFifo(self: *volatile UsbOtgGlobal, fifo: u5, timeout: usize) bool {
        self.grstctl = UsbGrstctl{
            .txfflsh = true,
            .txfnum = fifo
        };
        for (0..timeout) |_| {
            if (!self.grstctl.txfflsh) {
                return true;
            }
        }
        return false;
    }

    pub fn flushRxFifo(self: *volatile UsbOtgGlobal, timeout: usize) bool {
        self.grstctl = UsbGrstctl{.rxfflsh = true};
        for (0..timeout) |_| {
            if (!self.grstctl.rxfflsh) {
                return true;
            }
        }
        return false;
    }

    pub fn deviceInit(self: *volatile UsbOtgGlobal, init_data: *const UsbOtgInit) bool {
        const device = self.getDevice();
        const pcgctl = self.getPcgctl();
        switch (cpu.getFamily()) {
            .F4 => {
                if (init_data.vbus_sensing_enable) {
                    self.gccfg.vbden_novbussens = !init_data.novbussens;
                    if (init_data.novbussens) {
                        self.gccfg.vbusbsen = true;
                    }
                } else {
                    self.gccfg.vbden_novbussens = init_data.novbussens;
                    if (init_data.novbussens) {
                        self.gccfg.vbusbsen = false;
                        self.gccfg.vbusasen = false;
                    }
                    self.gotgctl.bvaloen = true;
                    self.gotgctl.bvaloval = true;
                }
            },
            .F7, .U5 => {
                self.gccfg.vbden = init_data.vbus_sensing_enable;
                if (!init_data.vbus_sensing_enable) {
                    self.gotgctl.bvaloen = true;
                    self.gotgctl.bvaloval = true;
                }
            },
            else => return false
        }
        pcgctl.* = UsbPcgcctl{};
        self.flushTxFifo(0, 0x10, init_data.timeout);
        self.flushRxFifo(init_data.timeout);
        device.init(init_data.in_endpoints, init_data.out_endpoints);
        self.gintsts = UsbGint{
            .gonakeff = true,
            .cidschg = true,
            .cmod = true,
            .discnt = true,
            .enumdne = true,
            .eopf = true,
            .esusp = true,
            .gnakeff = true,
            .hcint = true,
            .hprint = true,
            .iepint = true,
            .oepint = true,
            .otgnt = true,
            .iisoixfr = true,
            .ipfxr_incompisoout = true,
            .isoodrp = true,
            .mmis = true,
            .nptxfe = true,
            .ptxfe = true,
            .rxflvl = true,
            .sof = true,
            .srqint = true,
            .usbrst = true,
            .usbsusp = true,
            .wkupint = true
        };
        self.gintmsk = UsbGint{
            .rxflvl = true,
            .usbrst = true,
            .usbsusp = true,
            .enumdne = true,
            .iepint = true,
            .oepint = true,
            .iisoixfr = true,
            .wkupint = true,
            .ipfxr_incompisoout = true
        };
        if (init_data.vbus_sensing_enable) {
            self.gintmsk.srqint = true;
            self.gintmsk.otgnt = true;
        }
        return true;
    }

    pub fn setRxFifo(self: *volatile UsbOtgGlobal, size: u32) void {
        self.grxfsiz = size / 4;
    }

    pub fn setTxFifo(self: *volatile UsbOtgGlobal, fifo: u3, txf: UsbTxf) void {
        self.dieptxf[fifo] = txf;
    }

    pub fn fifoInit(self: *volatile UsbOtgGlobal, out_endpoints: u4) void {
        self.setRxFifo(usb_device.USB_FS_MAX_PACKET_SIZE);
        var offset: u16 = usb_device.USB_FS_MAX_PACKET_SIZE;
        for (0..out_endpoints) |i| {
            self.setTxFifo(i, UsbTxf{
                .txsa = offset,
                .txfd = usb_device.USB_FS_MAX_PACKET_SIZE / 4,
            });
            offset += usb_device.USB_FS_MAX_PACKET_SIZE;
        }
    }

    pub fn epInit(self: *volatile UsbOtgGlobal, in_endpoints: u4) void {
        for (0..in_endpoints) |i| {
            self.dieptxf[i] = UsbTxf{};
        }
    }

    pub fn init(self: *volatile UsbOtgGlobal, init_data: *const UsbOtgInit) void {
        self.gahbcfg.gintmsk = false;
        self.coreInit(init_data.timeout);
        self.gusbcfg.fdmod = true;
        system_timer.delayms(50);
        self.epInit(init_data.in_endpoints);
        self.deviceInit(init_data);
        self.fifoInit(init_data.out_endpoints);
    }

    pub fn connect(self: *volatile UsbOtgGlobal) void {
        const device = self.getDevice();
        nvic.nvic.enableInterrupt(interrupts.OTG_FS.toU8());
        self.gahbcfg.gintmsk = true;
        device.dctl.sdis = false;
    }
};

pub const otg_fs_global: *volatile UsbOtgGlobal = @ptrFromInt(USB_OTG_FS_BASE);
pub const otg_hs_global: *volatile UsbOtgGlobal = @ptrFromInt(USB_OTG_HS_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x118, @sizeOf(UsbOtgGlobal));
}
