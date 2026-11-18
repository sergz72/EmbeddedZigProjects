const QSPI_BASE = 0x42003400;

pub const QspiCtrla = bitpack struct(u32) {
    swrst: bool = false,
    enable: bool = false,
    reserved0: u22 = 0,
    lastxfer: bool = false,
    reserved1: u7 = 0,
};

pub const QspiCsmode = enum(u2) {
    noreload = 0,
    lastxfer = 1,
    systematically = 2,
};

pub const QspiDatalen = enum(u4) {
    _8bits = 0,
    _9bits = 1,
    _10bits = 2,
    _11bits = 3,
    _12bits = 4,
    _13bits = 5,
    _14bits = 6,
    _15bits = 7,
    _16bits = 8,
};

pub const QspiCtrlb = bitpack struct(u32) {
    mode: bool = false,
    loopen: bool = false,
    wdrbt: bool = false,
    smemreg: bool = false,
    csmode: QspiCsmode = .noreload,
    reserved0: u2 = 0,
    datalen: QspiDatalen = ._8bits,
    reserved1: u4 = 0,
    dlybct: u8 = 0,
    dlycs: u8 = 0,
};

pub const QspiBaud = bitpack struct(u32) {
    cpol: bool = false,
    cpha: bool = false,
    reserved0: u6 = 0,
    baud: u8 = 0,
    dlybs: u8 = 0,
    reserved1: u8 = 0,
};

pub const QspiInt = bitpack struct(u32) {
    rxc: bool = false,
    dre: bool = false,
    txc: bool = false,
    err: bool = false,
    reserved0: u4 = 0,
    csrise: bool = false,
    reserved1: u1 = 0,
    instrend: bool = false,
    reserved2: u21 = 0,
};

pub const QspiStatus = bitpack struct(u32) {
    reserved0: u1,
    enable: bool,
    reserved1: u7,
    csstatus: bool,
    reserved2: u22,
};

pub const QspiInstrctrl = bitpack struct(u32) {
    instr: u8 = 0,
    reserved0: u8 = 0,
    optcode: u8 = 0,
    reserved1: u8 = 0,
};

pub const QspiWidth = enum(u3) {
    single_bit_spi = 0,
    dual_output = 1,
    quad_output = 2,
    dual_io = 3,
    quad_io = 4,
    dual_cmd = 5,
    quad_cmd = 6,
};

pub const QspiOptcodelen = enum(u2) {
    _1bit = 0,
    _2bits = 1,
    _4bits = 2,
    _8bits = 3,
};

pub const QspiTfrtype = enum(u2) {
    read = 0,
    readmemory = 1,
    write = 2,
    writememory = 3,
};

pub const QspiInstrframe = bitpack struct(u32) {
    width: QspiWidth = .single_bit_spi,
    reserved0: u1 = 0,
    instren: bool = false,
    addren: bool = false,
    optcodeen: bool = false,
    dataen: bool = false,
    optcodelen: QspiOptcodelen = ._1bit,
    addrlen: bool = false,
    reserved1: u1 = 0,
    tfrtype: QspiTfrtype = .read,
    crmode: bool = false,
    ddren: bool = false,
    dummylen: u5 = 0,
    reserved2: u11 = 0,
};

pub const QspiScrambctrl = bitpack struct(u32) {
    enable: bool = false,
    randomdis: bool = false,
    reserved0: u30 = 0,
};

pub const Qspi = extern struct {
    ctrla: QspiCtrla,
    ctrlb: QspiCtrlb,
    baud: QspiBaud,
    rxdata: u32,
    txdata: u32,
    intenclr: QspiInt,
    intenset: QspiInt,
    intflag: QspiInt,
    status: QspiStatus,
    reserved0: [3]u32,
    instraddr: u32,
    instrctrl: QspiInstrctrl,
    instrframe: QspiInstrframe,
    reserved1: u32,
    scrambctrl: QspiScrambctrl,
    scrambkey: u32,
};

pub const qspi: *volatile Qspi = @ptrFromInt(QSPI_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x48, @sizeOf(Qspi));
}
