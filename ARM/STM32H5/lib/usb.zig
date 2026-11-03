const USB_BASE = 0x40016000;

pub const UsbDeviceEndpointStatus = enum(u2) {
    disabled = 0,
    stall = 1,
    nak = 2,
    valid = 3
};

pub const UsbChepr = packed struct(u32) {
    ea: u4 = 0,
    stattx: u2 = 0,
    dtogtx: bool = false,
    vttx: bool = false,
    epkind: bool = false,
    utype: u2 = 0,
    setup: bool = false,
    statrx: u2 = 0,
    dtogrx: bool = false,
    vtrx: bool = false,
    devaddr: u7 = 0,
    nak: bool = false,
    ls_ep: bool = false,
    err_tx: bool = false,
    err_rx: bool = false,
    three_err_tx: u2 = 0,
    three_err_rx: u2 = 0,
    reserved0: u1 = 0,
};

pub const UsbCntr = packed struct(u32) {
    usbrst: bool = true,
    pdwn: bool = true,
    susprdy: bool = false,
    suspen: bool = false,
    l2res: bool = false,
    l1res: bool = false,
    reserved0: u1 = 0,
    l1reqm: bool = false,
    esofm: bool = false,
    sofm: bool = false,
    rst_dconm: bool = false,
    suspm: bool = false,
    wkupm: bool = false,
    errm: bool = false,
    pmaovrm: bool = false,
    ctrm: bool = false,
    thr512m: bool = false,
    ddiscm: bool = false,
    reserved1: u13 = 0,
    host: bool = false,
};

pub const UsbIstr = packed struct(u32) {
    idn: u4 = 0,
    dir: bool = false,
    reserved0: u2 = 0,
    l1req: bool = false,
    esof: bool = false,
    sof: bool = false,
    rst_dcon: bool = false,
    susp: bool = false,
    wkup: bool = false,
    err: bool = false,
    pmaovr: bool = false,
    ctr: bool = false,
    thr512: bool = false,
    ddisc: bool = false,
    reserved1: u11 = 0,
    dcon_stat: bool = false,
    ls_dcon: bool = false,
    reserved2: u1 = 0,
};

pub const UsbFnr = packed struct(u32) {
    fnum: u11 = 0,
    lsof: u2 = 0,
    lck: bool = false,
    rxdm: bool = false,
    rxdp: bool = false,
    reserved0: u16 = 0,
};

pub const UsbDaddr = packed struct(u32) {
    add: u7 = 0,
    ef: bool = false,
    reserved0: u24 = 0,
};

pub const UsbLpmcsr = packed struct(u32) {
    lpmen: bool = false,
    lpmack: bool = false,
    reserved0: u1 = 0,
    remwake: bool = false,
    besl: u4 = 0,
    reserved1: u24 = 0,
};

pub const UsbBcdr = packed struct(u32) {
    bcden: bool = false,
    dcden: bool = false,
    pden: bool = false,
    sden: bool = false,
    dcdet: bool = false,
    pdet: bool = false,
    sdet: bool = false,
    ps2det: bool = false,
    reserved0: u7 = 0,
    dppu_dpd: bool = false,
    reserved1: u16 = 0,
};

pub const UsbChepTx = packed struct(u32) {
    addr_tx: u16,
    count_tx: u10,
    reserved0: u6
};

pub const UsbChepRx = packed struct(u32) {
    addr_rx: u16,
    count_rx: u10,
    num_block: u5,
    blsize: bool
};

pub const UsbChep = extern struct {
    tx: UsbChepTx,
    rx: UsbChepRx
};

pub const Usb = extern struct {
    chepr: [8]UsbChepr,
    reserved0: [8]u32,
    cntr: UsbCntr,
    istr: UsbIstr,
    fnr: UsbFnr,
    daddr: UsbDaddr,
    reserved1: u32,
    lpmcsr: UsbLpmcsr,
    bcdr: UsbBcdr,
    reserved: [233]u32,
    chep: [8]UsbChep,
    sram: [496]u32
};

pub const usb: *volatile Usb = @ptrFromInt(USB_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0xC00, @sizeOf(Usb));
}
