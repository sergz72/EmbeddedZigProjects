const USB_BASE = 0x4100A000;

pub const UsbCtrla = bitpack struct(u8) {
    swrst: bool = false,
    enable: bool = false,
    runstdby: bool = false,
    reserved0: u4 = 0,
    mode: bool = false,
};

pub const UsbSyncbusy = bitpack struct(u8) {
    swrst: bool,
    enable: bool,
    reserved0: u6,
};

pub const UsbQosctrl = bitpack struct(u8) {
    cqos: u2 = 3,
    dqos: u2 = 3,
    reserved0: u4 = 0,
};

pub const UsbSpdconf = enum(u2) {
    fs = 0,
    ls = 1,
};

pub const UsbLpmhdsk = enum(u2) {
    no = 0,
    ack = 1,
    nyet = 2,
};

pub const UsbCtrlb = bitpack struct(u16) {
    detach: bool = true,
    uprsm: bool = false,
    spdconf: UsbSpdconf = .fs,
    nreply: bool = false,
    reserved0: u4 = 0,
    gnak: bool = false,
    lpmhdsk: UsbLpmhdsk = .no,
    reserved1: u4 = 0,
};

pub const UsbDadd = bitpack struct(u8) {
    dadd: u7 = 0,
    adden: bool = false,
};

pub const UsbSpeed = enum(u2) {
    fs = 0,
    ls = 1,
};

pub const UsbLinestate = enum(u2) {
    se0_reset = 0,
    fsj_or_lsk = 1,
    fsk_or_lsj = 2,
};

pub const UsbStatus = bitpack struct(u8) {
    reserved0: u2,
    speed: UsbSpeed,
    reserved1: u2,
    linestate: UsbLinestate,
};

pub const UsbFsmstatus = enum(u8) {
    off = 1,
    on = 2,
    suspen = 4,
    sleep = 8,
    dnresume = 16,
    upresume = 32,
    reset = 64,
};

pub const UsbFnum = bitpack struct(u16) {
    reserved0: u3 = 0,
    fnum: u11 = 0,
    reserved1: u1 = 0,
    fncerr: bool = false,
};

pub const UsbInt = bitpack struct(u16) {
    suspen: bool = false,
    reserved0: u1 = 0,
    sof: bool = false,
    eorst: bool = false,
    wakeup: bool = false,
    eorsm: bool = false,
    uprsm: bool = false,
    ramacer: bool = false,
    lpmnyet: bool = false,
    lpmsusp: bool = false,
    reserved1: u6 = 0,
};

pub const UsbEpintsmry = bitpack struct(u16) {
    epint0: bool,
    epint1: bool,
    epint2: bool,
    epint3: bool,
    epint4: bool,
    epint5: bool,
    epint6: bool,
    epint7: bool,
    reserved0: u8,
};

pub const UsbPadcal = bitpack struct(u16) {
    transp: u5 = 0,
    reserved0: u1 = 0,
    transn: u5 = 0,
    reserved1: u1 = 0,
    trim: u3 = 0,
    reserved2: u1 = 0,
};

pub const UsbEpcfg = bitpack struct(u8) {
    eptype0: u3 = 0,
    reserved0: u1 = 0,
    eptype1: u3 = 0,
    reserved1: u1 = 0,
};

pub const UsbEpstatus = bitpack struct(u8) {
    dtglout: bool = false,
    dtglin: bool = false,
    curbk: bool = false,
    reserved0: u1 = 0,
    stallrq0: bool = false,
    stallrq1: bool = false,
    bk0rdy: bool = false,
    bk1rdy: bool = false,
};

pub const UsbEpint = bitpack struct(u8) {
    trcpt0: bool = false,
    trcpt1: bool = false,
    trfail0: bool = false,
    trfail1: bool = false,
    rxstp: bool = false,
    stall0: bool = false,
    stall1: bool = false,
    reserved0: u1 = 0,
};

pub const UsbDeviceEndpoint = extern struct {
    epcfg: UsbEpcfg,
    reserved0: [3]u8,
    epstatusclr: UsbEpstatus,
    epstatusset: UsbEpstatus,
    epstatus: UsbEpstatus,
    epintflag: UsbEpint,
    epintenclr: UsbEpint,
    epintenset: UsbEpint,
    reserved: [22]u8
};

pub const UsbDevice = extern struct {
    ctrla: UsbCtrla,
    reserved0: u8,
    syncbusy: UsbSyncbusy,
    qosctrl: UsbQosctrl,
    reserved1: u32,
    ctrlb: UsbCtrlb,
    dadd: UsbDadd,
    reserved2: u8,
    status: UsbStatus,
    fsmstatus: UsbFsmstatus,
    reserved3: u16,
    fnum: UsbFnum,
    reserved4: u16,
    intenclr: UsbInt,
    reserved5: u16,
    intenset: UsbInt,
    reserved6: u16,
    intflag: UsbInt,
    reserved7: u16,
    epintsmry: UsbEpintsmry,
    reserved8: u16,
    descadd: u32,
    padcal: UsbPadcal,
    reserved9: [107]u16,
    ep: [8]UsbDeviceEndpoint
};

pub const usb: *volatile UsbDevice = @ptrFromInt(USB_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x200, @sizeOf(UsbDevice));
}
