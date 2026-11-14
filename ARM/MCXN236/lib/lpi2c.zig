const LPI2C0_BASE = 0x40092800;
const LPI2C1_BASE = 0x40093800;
const LPI2C2_BASE = 0x40094800;
const LPI2C3_BASE = 0x40095800;
const LPI2C4_BASE = 0x400B4800;
const LPI2C5_BASE = 0x400B5800;
const LPI2C6_BASE = 0x400B6800;
const LPI2C7_BASE = 0x400B7800;

pub const Feature = enum(u16) {
    master_only = 2,
    master_and_slave = 3,
};

pub const Verid = bitpack struct(u32) {
    feature: Feature = .master_and_slave,
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
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3,
    div16 = 4,
    div32 = 5,
    div64 = 6,
    div128 = 7
};

pub const Matcfg = enum(u3) {
    disabled = 0,
    first_data_word_equals_match0_or_match1 = 2,
    any_data_word_equals_match0_or_match1 = 3,
    first_data_word_match0_and_second_data_word_match1 = 4,
    any_data_word_match0_next_data_word_match1 = 5,
    first_data_word_and_match1_equals_match0_and_match1 = 6,
    any_data_word_and_match1_equals_match0_and_match1 = 7,
};

pub const Pincfg = enum(u3) {
    open_drain_2_pin = 0,
    output_2_pin_only = 1,
    push_pull_2_pin = 2,
    push_pull_4_pin = 3,
    open_drain_2_pin_w_lpi2c_slave = 4,
    output_2_pin_only_w_lpi2c_slave = 5,
    push_pull_2_pin_w_lpi2c_slave = 6,
    push_pull_4_pin_w_lpi2c_slave = 7,
};

pub const Mcfgr1 = bitpack struct(u32) {
    prescale: Prescale = .div1,
    reserved0: u5 = 0,
    autostop: bool = false,
    ignack: bool = false,
    timecfg: bool = false,
    stopcfg: bool = false,
    startcfg: bool = false,
    reserved1: u3 = 0,
    matcfg: Matcfg = .disabled,
    reserved2: u5 = 0,
    pincfg: Pincfg = .open_drain_2_pin,
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
    transmit_data_7_through_0 = 0,
    receive_data_7_through_0_plus_one = 1,
    generate_stop_condition = 2,
    receive_and_discard_data_7_through_0_plus_one = 3,
    generate_start_and_transmit_address_in_data_7_through_0 = 4,
    generate_start_and_transmit_address_in_data_7_through_0_expect_nack = 5,
    generate_start_and_transmit_address_in_data_7_through_0_using_high_speed_mode = 6,
    generate_start_and_transmit_address_in_data_7_through_0_using_high_speed_mode_expect_nack = 7,
};

pub const Mtdr = bitpack struct(u32) {
    data: u8 = 0,
    cmd: Cmd = .transmit_data_7_through_0,
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
    address_match0_7_bit = 0,
    address_match0_10_bit = 1,
    address_match0_7_bit_or_address_match1_7_bit = 2,
    address_match0_10_bit_or_address_match1_10_bit = 3,
    address_match0_7_bit_or_address_match1_10_bit = 4,
    address_match0_10_bit_or_address_match1_7_bit = 5,
    from_address_match0_7_bit_to_address_match1_7_bit = 6,
    from_address_match0_10_bit_to_address_match1_10_bit = 7,
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
    addrcfg: Addrcfg = .address_match0_7_bit,
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

pub const Mtcbr = bitpack struct(u32) {
    data: u8 = 0,
    cmd: u3 = 0,
    reserved0: u21 = 0,
};

pub const Mtdbr = bitpack struct(u32) {
    data0: u8 = 0,
    data1: u8 = 0,
    data2: u8 = 0,
    data3: u8 = 0,
};

pub const Lpi2c = extern struct {
    verid: Verid,
    param: Param,
    reserved0: [2]u32,
    mcr: Mcr,
    msr: Msr,
    mier: Mier,
    mder: Mder,
    mcfgr0: Mcfgr0,
    mcfgr1: Mcfgr1,
    mcfgr2: Mcfgr2,
    mcfgr3: Mcfgr3,
    reserved1: [4]u32,
    mdmr: Mdmr,
    reserved2: u32,
    mccr0: Mccr0,
    reserved3: u32,
    mccr1: Mccr1,
    reserved4: u32,
    mfcr: Mfcr,
    mfsr: Mfsr,
    mtdr: Mtdr,
    reserved5: [3]u32,
    mrdr: Mrdr,
    reserved6: u32,
    mrdror: Mrdror,
    reserved7: [37]u32,
    scr: Scr,
    ssr: Ssr,
    sier: Sier,
    sder: Sder,
    scfgr0: Scfgr0,
    scfgr1: Scfgr1,
    scfgr2: Scfgr2,
    reserved8: [5]u32,
    samr: Samr,
    reserved9: [3]u32,
    sasr: Sasr,
    star: Star,
    reserved10: [2]u32,
    stdr: Stdr,
    reserved11: [3]u32,
    srdr: Srdr,
    reserved12: u32,
    srdror: Srdror,
    reserved13: [33]u32,
    mtcbr: [128]Mtcbr,
    mtdbr: [253]Mtdbr,
};

pub const lpi2c0: *volatile Lpi2c = @ptrFromInt(LPI2C0_BASE);
pub const lpi2c1: *volatile Lpi2c = @ptrFromInt(LPI2C1_BASE);
pub const lpi2c2: *volatile Lpi2c = @ptrFromInt(LPI2C2_BASE);
pub const lpi2c3: *volatile Lpi2c = @ptrFromInt(LPI2C3_BASE);
pub const lpi2c4: *volatile Lpi2c = @ptrFromInt(LPI2C4_BASE);
pub const lpi2c5: *volatile Lpi2c = @ptrFromInt(LPI2C5_BASE);
pub const lpi2c6: *volatile Lpi2c = @ptrFromInt(LPI2C6_BASE);
pub const lpi2c7: *volatile Lpi2c = @ptrFromInt(LPI2C7_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x7F4, @sizeOf(Lpi2c));
}
