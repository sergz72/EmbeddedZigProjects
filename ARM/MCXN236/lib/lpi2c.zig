const LPI2C0_BASE = 0x40092800;
const LPI2C1_BASE = 0x40093800;
const LPI2C2_BASE = 0x40094800;
const LPI2C3_BASE = 0x40095800;
const LPI2C4_BASE = 0x400B4800;
const LPI2C5_BASE = 0x400B5800;
const LPI2C6_BASE = 0x400B6800;
const LPI2C7_BASE = 0x400B7800;

pub const Feature = enum(u16) {
    MASTER_ONLY = 2,
    MASTER_AND_SLAVE = 3,
};

pub const Verid = bitpack struct(u32) {
    feature: Feature = .MASTER_AND_SLAVE,
    minor: u8,
    major: u8,
};

pub const Param = bitpack struct(u32) {
    mtxfifo: u4,
    reserved0: u4,
    mrxfifo: u4,
    reserved1: u20,
};

pub const Mcr = bitpack struct(u32) {
    men: bool = false,
    rst: bool = false,
    dozen: bool = false,
    dbgen: bool = false,
    reserved0: u4 = 0,
    rtf: bool = false,
    rrf: bool = false,
    reserved1: u22 = 0,
};

pub const Msr = bitpack struct(u32) {
    tdf: bool = true,
    rdf: bool = false,
    reserved0: u6 = 0,
    epf: bool = false,
    sdf: bool = false,
    ndf: bool = false,
    alf: bool = false,
    fef: bool = false,
    pltf: bool = false,
    dmf: bool = false,
    stf: bool = false,
    reserved1: u8 = 0,
    mbf: bool = false,
    bbf: bool = false,
    reserved2: u6 = 0,
};

pub const Mier = bitpack struct(u32) {
    tdie: bool = false,
    rdie: bool = false,
    reserved0: u6 = 0,
    epie: bool = false,
    sdie: bool = false,
    ndie: bool = false,
    alie: bool = false,
    feie: bool = false,
    pltie: bool = false,
    dmie: bool = false,
    stie: bool = false,
    reserved1: u16 = 0,
};

pub const Mder = bitpack struct(u32) {
    tdde: bool = false,
    rdde: bool = false,
    reserved0: u30 = 0,
};

pub const Mcfgr0 = bitpack struct(u32) {
    hren: bool = false,
    hrpol: bool = false,
    hrsel: bool = false,
    hrdir: bool = false,
    reserved0: u4 = 0,
    cirfifo: bool = false,
    rdmo: bool = false,
    reserved1: u6 = 0,
    relax: bool = false,
    abort: bool = false,
    reserved2: u14 = 0,
};

pub const Prescale = enum(u3) {
    DIVIDE_BY_1 = 0,
    DIVIDE_BY_2 = 1,
    DIVIDE_BY_4 = 2,
    DIVIDE_BY_8 = 3,
    DIVIDE_BY_16 = 4,
    DIVIDE_BY_32 = 5,
    DIVIDE_BY_64 = 6,
    DIVIDE_BY_128 = 7,
};

pub const Matcfg = enum(u3) {
    DISABLED = 0,
    FIRST_DATA_WORD_EQUALS_MATCH0_OR_MATCH1 = 2,
    ANY_DATA_WORD_EQUALS_MATCH0_OR_MATCH1 = 3,
    FIRST_DATA_WORD_MATCH0_AND_SECOND_DATA_WORD_MATCH1 = 4,
    ANY_DATA_WORD_MATCH0_NEXT_DATA_WORD_MATCH1 = 5,
    FIRST_DATA_WORD_AND_MATCH1_EQUALS_MATCH0_AND_MATCH1 = 6,
    ANY_DATA_WORD_AND_MATCH1_EQUALS_MATCH0_AND_MATCH1 = 7,
};

pub const Pincfg = enum(u3) {
    OPEN_DRAIN_2_PIN = 0,
    OUTPUT_2_PIN_ONLY = 1,
    PUSH_PULL_2_PIN = 2,
    PUSH_PULL_4_PIN = 3,
    OPEN_DRAIN_2_PIN_W_LPI2C_SLAVE = 4,
    OUTPUT_2_PIN_ONLY_W_LPI2C_SLAVE = 5,
    PUSH_PULL_2_PIN_W_LPI2C_SLAVE = 6,
    PUSH_PULL_4_PIN_W_LPI2C_SLAVE = 7,
};

pub const Mcfgr1 = bitpack struct(u32) {
    prescale: Prescale = .DIVIDE_BY_1,
    reserved0: u5 = 0,
    autostop: bool = false,
    ignack: bool = false,
    timecfg: bool = false,
    stopcfg: bool = false,
    startcfg: bool = false,
    reserved1: u3 = 0,
    matcfg: Matcfg = .DISABLED,
    reserved2: u5 = 0,
    pincfg: Pincfg = .OPEN_DRAIN_2_PIN,
    reserved3: u5 = 0,
};

pub const Mcfgr2 = bitpack struct(u32) {
    busidle: u12 = 0,
    reserved0: u4 = 0,
    filtscl: u4 = 0,
    reserved1: u4 = 0,
    filtsda: u4 = 0,
    reserved2: u4 = 0,
};

pub const Mcfgr3 = bitpack struct(u32) {
    reserved0: u8 = 0,
    pinlow: u12 = 0,
    reserved1: u12 = 0,
};

pub const Mdmr = bitpack struct(u32) {
    match0: u8 = 0,
    reserved0: u8 = 0,
    match1: u8 = 0,
    reserved1: u8 = 0,
};

pub const Mccr0 = bitpack struct(u32) {
    clklo: u6 = 0,
    reserved0: u2 = 0,
    clkhi: u6 = 0,
    reserved1: u2 = 0,
    sethold: u6 = 0,
    reserved2: u2 = 0,
    datavd: u6 = 0,
    reserved3: u2 = 0,
};

pub const Mccr1 = bitpack struct(u32) {
    clklo: u6 = 0,
    reserved0: u2 = 0,
    clkhi: u6 = 0,
    reserved1: u2 = 0,
    sethold: u6 = 0,
    reserved2: u2 = 0,
    datavd: u6 = 0,
    reserved3: u2 = 0,
};

pub const Mfcr = bitpack struct(u32) {
    txwater: u3 = 0,
    reserved0: u13 = 0,
    rxwater: u3 = 0,
    reserved1: u13 = 0,
};

pub const Mfsr = bitpack struct(u32) {
    txcount: u4,
    reserved0: u12,
    rxcount: u4,
    reserved1: u12,
};

pub const Cmd = enum(u3) {
    TRANSMIT_DATA_7_THROUGH_0 = 0,
    RECEIVE_DATA_7_THROUGH_0_PLUS_ONE = 1,
    GENERATE_STOP_CONDITION = 2,
    RECEIVE_AND_DISCARD_DATA_7_THROUGH_0_PLUS_ONE = 3,
    GENERATE_START_AND_TRANSMIT_ADDRESS_IN_DATA_7_THROUGH_0 = 4,
    GENERATE_START_AND_TRANSMIT_ADDRESS_IN_DATA_7_THROUGH_0_EXPECT_NACK = 5,
    GENERATE_START_AND_TRANSMIT_ADDRESS_IN_DATA_7_THROUGH_0_USING_HIGH_SPEED_MODE = 6,
    GENERATE_START_AND_TRANSMIT_ADDRESS_IN_DATA_7_THROUGH_0_USING_HIGH_SPEED_MODE_EXPECT_NACK = 7,
};

pub const Mtdr = bitpack struct(u32) {
    data: u8 = 0,
    cmd: Cmd = .TRANSMIT_DATA_7_THROUGH_0,
    reserved0: u21 = 0,
};

pub const Mrdr = bitpack struct(u32) {
    data: u8,
    reserved0: u6,
    rxempty: bool,
    reserved1: u17,
};

pub const Mrdror = bitpack struct(u32) {
    data: u8,
    reserved0: u6,
    rxempty: bool,
    reserved1: u17,
};

pub const Scr = bitpack struct(u32) {
    sen: bool = false,
    rst: bool = false,
    reserved0: u2 = 0,
    filten: bool = false,
    filtdz: bool = false,
    reserved1: u2 = 0,
    rtf: bool = false,
    rrf: bool = false,
    reserved2: u22 = 0,
};

pub const Ssr = bitpack struct(u32) {
    tdf: bool = false,
    rdf: bool = false,
    avf: bool = false,
    taf: bool = false,
    reserved0: u4 = 0,
    rsf: bool = false,
    sdf: bool = false,
    bef: bool = false,
    fef: bool = false,
    am0f: bool = false,
    am1f: bool = false,
    gcf: bool = false,
    sarf: bool = false,
    reserved1: u8 = 0,
    sbf: bool = false,
    bbf: bool = false,
    reserved2: u6 = 0,
};

pub const Sier = bitpack struct(u32) {
    tdie: bool = false,
    rdie: bool = false,
    avie: bool = false,
    taie: bool = false,
    reserved0: u4 = 0,
    rsie: bool = false,
    sdie: bool = false,
    beie: bool = false,
    feie: bool = false,
    am0ie: bool = false,
    am1ie: bool = false,
    gcie: bool = false,
    sarie: bool = false,
    reserved1: u16 = 0,
};

pub const Sder = bitpack struct(u32) {
    tdde: bool = false,
    rdde: bool = false,
    avde: bool = false,
    reserved0: u5 = 0,
    rsde: bool = false,
    sdde: bool = false,
    reserved1: u22 = 0,
};

pub const Scfgr0 = bitpack struct(u32) {
    rdreq: bool = false,
    rdack: bool = false,
    reserved0: u30 = 0,
};

pub const Addrcfg = enum(u3) {
    ADDRESS_MATCH0_7_BIT = 0,
    ADDRESS_MATCH0_10_BIT = 1,
    ADDRESS_MATCH0_7_BIT_OR_ADDRESS_MATCH1_7_BIT = 2,
    ADDRESS_MATCH0_10_BIT_OR_ADDRESS_MATCH1_10_BIT = 3,
    ADDRESS_MATCH0_7_BIT_OR_ADDRESS_MATCH1_10_BIT = 4,
    ADDRESS_MATCH0_10_BIT_OR_ADDRESS_MATCH1_7_BIT = 5,
    FROM_ADDRESS_MATCH0_7_BIT_TO_ADDRESS_MATCH1_7_BIT = 6,
    FROM_ADDRESS_MATCH0_10_BIT_TO_ADDRESS_MATCH1_10_BIT = 7,
};

pub const Scfgr1 = bitpack struct(u32) {
    adrstall: bool = false,
    rxstall: bool = false,
    txdstall: bool = false,
    ackstall: bool = false,
    rxnack: bool = false,
    reserved0: u3 = 0,
    gcen: bool = false,
    saen: bool = false,
    txcfg: bool = false,
    rxcfg: bool = false,
    ignack: bool = false,
    hsmen: bool = false,
    reserved1: u2 = 0,
    addrcfg: Addrcfg = .ADDRESS_MATCH0_7_BIT,
    reserved2: u5 = 0,
    rxall: bool = false,
    rscfg: bool = false,
    sdcfg: bool = false,
    reserved3: u5 = 0,
};

pub const Scfgr2 = bitpack struct(u32) {
    clkhold: u4 = 0,
    reserved0: u4 = 0,
    datavd: u6 = 0,
    reserved1: u2 = 0,
    filtscl: u4 = 0,
    reserved2: u4 = 0,
    filtsda: u4 = 0,
    reserved3: u4 = 0,
};

pub const Samr = bitpack struct(u32) {
    reserved0: u1 = 0,
    addr0: u10 = 0,
    reserved1: u6 = 0,
    addr1: u10 = 0,
    reserved2: u5 = 0,
};

pub const Sasr = bitpack struct(u32) {
    raddr: u11,
    reserved0: u3,
    anv: bool,
    reserved1: u17,
};

pub const Star = bitpack struct(u32) {
    txnack: bool = false,
    reserved0: u31 = 0,
};

pub const Stdr = bitpack struct(u32) {
    data: u8 = 0,
    reserved0: u24 = 0,
};

pub const Srdr = bitpack struct(u32) {
    data: u8,
    raddr: u3,
    reserved0: u3,
    rxempty: bool,
    sof: bool,
    reserved1: u16,
};

pub const Srdror = bitpack struct(u32) {
    data: u8,
    raddr: u3,
    reserved0: u3,
    rxempty: bool,
    sof: bool,
    reserved1: u16,
};

pub const Mtcbr[%s] = bitpack struct(u32) {
    data: u8 = 0,
    cmd: u3 = 0,
    reserved0: u21 = 0,
};

pub const Mtdbr[%s] = bitpack struct(u32) {
    data0: u8 = 0,
    data1: u8 = 0,
    data2: u8 = 0,
    data3: u8 = 0,
};

pub const LPI2C0 = extern struct {
    verid: Verid,
    param: Param,
    reserved0: [8]u8,
    mcr: Mcr,
    msr: Msr,
    mier: Mier,
    mder: Mder,
    mcfgr0: Mcfgr0,
    mcfgr1: Mcfgr1,
    mcfgr2: Mcfgr2,
    mcfgr3: Mcfgr3,
    reserved1: [16]u8,
    mdmr: Mdmr,
    reserved2: [4]u8,
    mccr0: Mccr0,
    reserved3: [4]u8,
    mccr1: Mccr1,
    reserved4: [4]u8,
    mfcr: Mfcr,
    mfsr: Mfsr,
    mtdr: Mtdr,
    reserved5: [12]u8,
    mrdr: Mrdr,
    reserved6: [4]u8,
    mrdror: Mrdror,
    reserved7: [148]u8,
    scr: Scr,
    ssr: Ssr,
    sier: Sier,
    sder: Sder,
    scfgr0: Scfgr0,
    scfgr1: Scfgr1,
    scfgr2: Scfgr2,
    reserved8: [20]u8,
    samr: Samr,
    reserved9: [12]u8,
    sasr: Sasr,
    star: Star,
    reserved10: [8]u8,
    stdr: Stdr,
    reserved11: [12]u8,
    srdr: Srdr,
    reserved12: [4]u8,
    srdror: Srdror,
    reserved13: [132]u8,
    mtcbr[%s]: Mtcbr[%s],
    reserved14: [508]u8,
    mtdbr[%s]: Mtdbr[%s],
};

pub const lpi2c0: *volatile LPI2C0 = @ptrFromInt(LPI2C0_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x7F4, @sizeOf(LPI2C0));

}
