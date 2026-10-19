const USB_OTG_FS_BASE: usize = 0x50000000;
const USB_OTG_HS_BASE: usize = 0x40040000;

pub const UsbGotgctl = packed struct(u32) {
    srqscs: bool = false,
    srq: bool = false,
    reserved: u6 = 0,
    hngscs: bool = false,
    hnprq: bool = false,
    hshnpen: bool = false,
    dhnpen: bool = false,
    reserved2: u4 = 0,
    cidsts: bool = true,
    dbct: bool = false,
    asvld: bool = false,
    bsvls: bool = false,
    reserved3: u12 = 0
};

pub const UsbGotgint = packed struct(u32) {
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

pub const UsbGahbcfg = packed struct(u32) {
    gintmsk: bool = false,
    reserved: u6 = 0,
    txfelvl: bool = false,
    ptxfelvl: bool = false,
    reserved2: u23 = 0
};

pub const UsbGusbcfg = packed struct(u32) {
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

pub const UsbGrstctl = packed struct(u32) {
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

pub const UsbGintsts = packed struct(u32) {
    cmod: bool = false,
    mmis: bool = false,
    otgnt: bool = false,
    sof: bool = false,
    rxlvl: bool = false,
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
    wkuint: bool = false
};

pub const UsbOtgCore = extern struct {
    gotgctl: UsbGotgctl,
    gotgint: UsbGotgint,
    gahbcfg: UsbGahbcfg,
    gusbcfg: UsbGusbcfg,
    grstctl: UsbGrstctl,
    gintsts: UsbGintsts,
    gintmsk: UsbGintsts,
    grxstsr: u32,
    grxstsp: u32,
    grxfsiz: u32,
    dieptxf0_hnptxfsiz: u32,
    hnptxsts: u32,
    reserved30: [2]u32,
    gccfg: u32,
    cid: u32,
    reserved40: [3]u32,
    ghwcfg3: u32,
    reserved6: u32,
    glpmcfg: u32,
    reserved: u32,
    gdfifocfg: u32,
    reserved43: [40]u32,
    hptxfsiz: u32,
    dieptxf: [15]u32,
};

pub const UsbOtgDevice = extern struct {
    dcfg: u32,
    dctl: u32,
    dsts: u32,
    reserved0c: u32,
    diepmsk: u32,
    doepmsk: u32,
    daint: u32,
    daintmsk: u32,
    reserved20: u32,
    reserved9: u32,
    dvbusdis: u32,
    dvbuspulse: u32,
    dthrctl: u32,
    diepempmsk: u32,
    deachint: u32,
    deachmsk: u32,
    reserved40: u32,
    dinep1msk: u32,
    reserved44: [15]u32,
    doutep1msk: u32,
};

pub const UsbOtgInEndpoint = extern struct {
    diepctl: u32,
    reserved04: u32,
    diepint: u32,
    reserved0c: u32,
    dieptsiz: u32,
    diepdma: u32,
    dtxfsts: u32,
    reserved18: u32,
};

pub const UsbOtgOutEndpoint = extern struct {
    doepctl: u32,
    reserved04: u32,
    doepint: u32,
    reserved0c: u32,
    doeptsiz: u32,
    doepdma: u32,
    reserved18: [2]u32,
};

pub const UsbOtgHost = extern struct {
    hcfg: u32,
    hfir: u32,
    hfnum: u32,
    reserved40c: u32,
    hptxsts: u32,
    haint: u32,
    haintmsk: u32,
};

pub const UsbOtgHostChannel = extern struct {
    hcchar: u32,
    hcsplt: u32,
    hcint: u32,
    hcintmsk: u32,
    hctsiz: u32,
    hcdma: u32,
    reserved: [2]u32,
};

const USB_OTG_FS_HOST_MAX_CHANNEL_NBR                = 12;
const USB_OTG_FS_MAX_ENDPOINTS                       = 6;    // Including EP0
const USB_OTG_FS_TOTAL_FIFO_SIZE                     = 1280; // in Bytes
const USB_OTG_HS_HOST_MAX_CHANNEL_NBR                = 16;
const USB_OTG_HS_MAX_ENDPOINTS                       = 9;    // Including EP0
const USB_OTG_HS_TOTAL_FIFO_SIZE                     = 4096; // in Bytes

pub const UsbOtg = struct {
    core: *volatile UsbOtgCore,
    device: *volatile UsbOtgDevice,
    host: *volatile UsbOtgHost,
    host_channel: *volatile UsbOtgHostChannel,
    in_endpoint: *volatile UsbOtgInEndpoint,
    out_endpoint: *volatile UsbOtgOutEndpoint,
    fifo: *[USB_OTG_HS_TOTAL_FIFO_SIZE][4096]u8,
};

pub const usb_otg_fs: UsbOtg = UsbOtg{
    .core = @ptrFromInt(USB_OTG_FS_BASE),
    .device = @ptrFromInt(USB_OTG_FS_BASE + 0x800),
    .host = @ptrFromInt(USB_OTG_FS_BASE + 0x400),
    .host_channel = @ptrFromInt(USB_OTG_FS_BASE + 0x500),
    .in_endpoint = @ptrFromInt(USB_OTG_FS_BASE + 0x900),
    .out_endpoint = @ptrFromInt(USB_OTG_FS_BASE + 0xb00),
    .fifo = @ptrFromInt(USB_OTG_FS_BASE + 0x1000)
};

pub const usb_otg_hs: UsbOtg = UsbOtg{
    .core = @ptrFromInt(USB_OTG_HS_BASE),
    .device = @ptrFromInt(USB_OTG_HS_BASE + 0x800),
    .host = @ptrFromInt(USB_OTG_HS_BASE + 0x400),
    .host_channel = @ptrFromInt(USB_OTG_HS_BASE + 0x500),
    .in_endpoint = @ptrFromInt(USB_OTG_HS_BASE + 0x900),
    .out_endpoint = @ptrFromInt(USB_OTG_HS_BASE + 0xb00),
    .fifo = @ptrFromInt(USB_OTG_HS_BASE + 0x1000)
};
