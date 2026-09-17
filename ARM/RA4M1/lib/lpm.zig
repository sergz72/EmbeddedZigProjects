const SBYCR_BASE: usize = 0x4001E00C;
const MSTPCRA_BASE: usize = 0x4001E01C;
const SNZCR_BASE: usize = 0x4001E092;
const OPCCR_BASE: usize = 0x4001E0A0;
const SOPCCR_BASE: usize = 0x4001E0AA;

const MSTPCRB_BASE: usize = 0x40047000;
const MSTPCRC_BASE: usize = 0x40047004;
const MSTPCRD_BASE: usize = 0x40047008;

pub const Mstpcra = packed struct(u32) {
    sram0: bool = false,
    reserved: u5 = 0x1F,
    eccsram: bool = false,
    reserved2: u15 = 0x7FFF,
    dmac_dtc: bool = false,
    reserved3: u9 = 0x1FF
};

pub const Mstpcrb = packed struct(u32) {
    reserved: u2 = 3,
    can0: bool = true,
    reserved2: u5 = 0x1F,
    iic1: bool = true,
    iic0: bool = true,
    reserved3: u1 = 1,
    usbfs: bool = true,
    reserved4: u6 = 0x3F,
    spi1: bool = true,
    spi0: bool = true,
    reserved5: u2 = 3,
    sci9: bool = true,
    reserved6: u6 = 0x3F,
    sci2: bool = true,
    sci1: bool = true,
    sci0: bool = true
};

pub const Mstpcrc = packed struct(u32) {
    cac: bool = true,
    crc: bool = true,
    reserved: u1 = 1,
    ctsu: bool = true,
    slcdc: bool = true,
    reserved2: u3 = 7,
    ssie0: bool = true,
    reserved3: u4 = 0x0F,
    doc: bool = true,
    elc: bool = true,
    reserved4: u16 = 0xFFFF,
    sce5: bool = true
};

pub const Mstpcrd = packed struct(u32) {
    reserved: u2 = 3,
    agt1: bool = true,
    agt0: bool = true,
    reserved2: u1 = 1,
    gpt32: bool = true,
    gpt16: bool = true,
    reserved3: u7 = 0x3F,
    poeg: bool = true,
    reserved4: u1 = 1,
    adc14: bool = true,
    reserved5: u2 = 3,
    dac8: bool = true,
    dac12: bool = true,
    reserved6: u8 = 0x3F,
    acmplp: bool = true,
    reserved7: u1 = 1,
    opamp: bool = true
};

pub const Opccr = packed struct(u8) {
    opcm: u2 = 2,
    reserved: u2 = 0,
    opcmtsf: bool = false,
    reserved2: u3 = 0
};

pub const Sopccr = packed struct(u8) {
    sopcm: bool = false,
    reserved: u3 = 0,
    sopcmtsf: bool = false,
    reserved2: u3 = 0
};

pub const Snzcr = packed struct(u8) {
    rxdreqen: bool = false,
    snzdtcen: bool = false,
    reserved: u5 = 0,
    snze: bool = false
};

pub var sbycr: *volatile u16 = @ptrFromInt(SBYCR_BASE);
pub var mstpcra: *volatile Mstpcra = @ptrFromInt(MSTPCRA_BASE);
pub var mstpcrb: *volatile Mstpcrb = @ptrFromInt(MSTPCRB_BASE);
pub var mstpcrc: *volatile Mstpcrc = @ptrFromInt(MSTPCRC_BASE);
pub var mstpcrd: *volatile Mstpcrd = @ptrFromInt(MSTPCRD_BASE);
pub var opccr: *volatile Opccr = @ptrFromInt(OPCCR_BASE);
pub var sopccr: *volatile Sopccr = @ptrFromInt(SOPCCR_BASE);
pub var snzcr: *volatile Snzcr = @ptrFromInt(SNZCR_BASE);
