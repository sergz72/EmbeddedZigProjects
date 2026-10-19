const USBD_BASE: usize = 0x40005C00;
const USBD_BUFFERS: usize = 0x40006000;

pub const UsbdCntr = packed struct(u16) {
    fres: bool = true,
    pwdn: bool = true,
    lpmode: bool = false,
    fsusp: bool = false,
    resum: bool = false,
    reserved: u2 = 0,
    mode_1wire: bool = false,
    esofm: bool = false,
    sofm: bool = false,
    rstm: bool = false,
    suspm: bool = false,
    wkupm: bool = false,
    errm: bool = false,
    pmaovrm: bool = false,
    ctrm: bool = false
};

pub const UsbdIstr = packed struct(u16) {
    ep_id: u4 = 0,
    dir: bool = false,
    reserved: u3 = 0,
    esof: bool = false,
    sof: bool = false,
    reset: bool = false,
    susp: bool = false,
    wakeup: bool = false,
    err: bool = false,
    pmaovr: bool = false,
    ctr: bool = false,
};

pub const UsbdFnr = packed struct(u16) {
    f_n: u11,
    lsof: u2,
    lck: bool,
    rxdm: bool, 
    rxdp: bool
};

pub const UsbdDaddr = packed struct(u16) {
    add: u7  = 0,
    ef: bool = false,
    reserved: u8 = 0
};

pub const UsbdBtable = packed struct(u16) {
    reserved: u3 = 0,
    blable: u13 = 0
};

pub const UsbdEndpointStatus = enum(u2) {
    disabled = 0,
    stall = 1,
    nak = 2,
    ack = 3,
};

pub const UsbdEndpointType = enum(u2) {
    bulk = 0,
    control = 1,
    iso = 2,
    interrupt = 3
};

pub const UsbdEpr = packed struct(u16) {
    ea: u4 = 0,
    stat_tx: UsbdEndpointStatus = .disabled,
    dtog_tx: bool = false,
    ctr_tx: bool = false,
    ep_kind: bool = false,
    eptype: UsbdEndpointType = .bulk,
    setup: bool = false,
    stat_rx: UsbdEndpointStatus = .disabled,
    dtog_rx: bool = false,
    ctr_rx: bool = false
};

pub const Usbd = extern struct {
    epr: [8]UsbdEpr,
    reserved5: [8]u32,
    cntr: UsbdCntr,
    reserved: u16,
    istr: UsbdIstr,
    reserved2: u16,
    fnr: UsbdFnr,
    reserved3: u16,
    daddr: UsbdDaddr,
    reserved4: u16,
    btable: UsbdBtable
};

pub const UsbdCountRx = packed struct(u16) {
    count: u10,
    num_block: u5 = 0,
    blsize: bool = false
};

pub const UsbdEndpointBuffers = extern struct {
    addr_tx: u16,
    reserved: u16,
    count_tx: u16,
    reserved2: u16,
    addr_rx: u16,
    reserved3: u16,
    count_rx: UsbdCountRx,
    reserved4: u16
};

pub const UsbdBuffers = extern struct {
    buffers: [8]UsbdEndpointBuffers,
    ram: [512-8*16]u8
};

pub const usbd: *volatile Usbd = @ptrFromInt(USBD_BASE);
pub const usbd_buffers: *volatile [8]UsbdEndpointBuffers = @ptrFromInt(USBD_BUFFERS);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x52, @sizeOf(Usbd));
    try std.testing.expectEqual(512, @sizeOf(UsbdBuffers));
}
