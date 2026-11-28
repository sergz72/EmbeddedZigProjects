const ELS_BASE = 0x40054000;

pub const EcdsaVfyStatus = enum(u2) {
    no_v_run = 0,
    sig_fail = 1,
    sig_pass = 2,
    err = 3,
};

pub const Pprot = enum(u2) {
    secnp = 0,
    secp = 1,
    nsecnp = 2,
    nsecp = 3,
};

pub const DrbgEntLvl = enum(u2) {
    none = 0,
    low = 1,
    high = 2,
    rfu = 3,
};

pub const Status = bitpack struct(u32) {
    els_busy: bool,
    els_irq: bool,
    els_err: bool,
    prng_rdy: bool,
    ecdsa_vfy_status: EcdsaVfyStatus = .no_v_run,
    pprot: Pprot = .nsecnp,
    drbg_ent_lvl: DrbgEntLvl = .none,
    dtrng_busy: bool,
    reserved0: u5,
    els_locked: bool,
    reserved1: u15,
};

pub const Ctrl = bitpack struct(u32) {
    els_en: bool = false,
    els_start: bool = false,
    els_reset: bool = false,
    els_cmd: u5 = 0,
    byte_order: bool = false,
    reserved0: u23 = 0,
};

pub const Cmdcfg0 = bitpack struct(u32) {
    cmdcfg0: u32 = 0,
};

pub const Cfg = bitpack struct(u32) {
    reserved0: u16 = 0,
    adctrl: u10 = 0,
    reserved1: u6 = 0,
};

pub const Kidx0 = bitpack struct(u32) {
    kidx0: u5 = 0,
    reserved0: u27 = 0,
};

pub const Kidx1 = bitpack struct(u32) {
    kidx1: u5 = 0,
    reserved0: u27 = 0,
};

pub const Kpropin = bitpack struct(u32) {
    kpropin: u32 = 0,
};

pub const DmaSrc0 = bitpack struct(u32) {
    addr_src0: u32 = 0,
};

pub const DmaSrc0Len = bitpack struct(u32) {
    size_src0_len: u32 = 0,
};

pub const DmaSrc1 = bitpack struct(u32) {
    addr_src1: u32 = 0,
};

pub const DmaSrc2 = bitpack struct(u32) {
    addr_src2: u32 = 0,
};

pub const DmaSrc2Len = bitpack struct(u32) {
    size_src2_len: u32 = 0,
};

pub const DmaRes0 = bitpack struct(u32) {
    addr_res0: u32 = 0,
};

pub const DmaRes0Len = bitpack struct(u32) {
    size_res0_len: u32 = 0,
};

pub const IntEnable = bitpack struct(u32) {
    int_en: bool = false,
    reserved0: u31 = 0,
};

pub const IntStatusClr = bitpack struct(u32) {
    int_clr: bool = false,
    reserved0: u31 = 0,
};

pub const IntStatusSet = bitpack struct(u32) {
    int_set: bool = false,
    reserved0: u31 = 0,
};

pub const ErrStatus = bitpack struct(u32) {
    bus_err: bool,
    opn_err: bool,
    alg_err: bool,
    itg_err: bool,
    flt_err: bool,
    prng_err: bool,
    err_lvl: u2,
    dtrng_err: bool,
    reserved0: u23,
};

pub const ErrStatusClr = bitpack struct(u32) {
    err_clr: bool = false,
    reserved0: u31 = 0,
};

pub const Version = bitpack struct(u32) {
    z: u4,
    y2: u4,
    y1: u4,
    x: u4,
    sw_z: u4,
    sw_y2: u4,
    sw_y1: u4,
    sw_x: u4,
};

pub const PrngDatout = bitpack struct(u32) {
    prng_datout: u32,
};

pub const CmdcrcCtrl = bitpack struct(u32) {
    cmdcrc_rst: bool = false,
    cmdcrc_en: bool = false,
    reserved0: u30 = 0,
};

pub const Cmdcrc = bitpack struct(u32) {
    cmdcrc: u32,
};

pub const SessionId = bitpack struct(u32) {
    session_id: u32 = 0,
};

pub const DmaFinAddr = bitpack struct(u32) {
    dma_fin_addr: u32,
};

pub const MasterId = bitpack struct(u32) {
    master_id: u5 = 31,
    reserved0: u27 = 0,
};

pub const Kidx2 = bitpack struct(u32) {
    kidx2: u5 = 0,
    reserved0: u27 = 0,
};

pub const Ks0Ksize = enum(u2) {
    size128 = 0,
    size256 = 1,
};

pub const ElsKs0 = bitpack struct(u32) {
    ks0_ksize: Ks0Ksize = .size128,
    reserved0: u3,
    ks0_kact: bool,
    ks0_kbase: bool,
    ks0_fgp: bool,
    ks0_frtn: bool,
    ks0_fhwo: bool,
    reserved1: u1,
    ks0_ukpuk: bool,
    ks0_utecdh: bool,
    ks0_ucmac: bool,
    ks0_uksk: bool,
    ks0_urtf: bool,
    ks0_uckdf: bool,
    ks0_uhkdf: bool,
    ks0_uecsg: bool,
    ks0_uecdh: bool,
    ks0_uaes: bool,
    ks0_uhmac: bool,
    ks0_ukwk: bool,
    ks0_ukuok: bool,
    ks0_utlspms: bool,
    ks0_utlsms: bool,
    ks0_ukgsrc: bool,
    ks0_uhwo: bool,
    ks0_uwrpok: bool,
    ks0_uduk: bool,
    ks0_upprot: u2,
};

pub const Ks1Ksize = enum(u2) {
    size128 = 0,
    size256 = 1,
};

pub const ElsKs1 = bitpack struct(u32) {
    ks1_ksize: Ks1Ksize = .size128,
    reserved0: u3,
    ks1_kact: bool,
    ks1_kbase: bool,
    ks1_fgp: bool,
    ks1_frtn: bool,
    ks1_fhwo: bool,
    reserved1: u1,
    ks1_ukpuk: bool,
    ks1_utecdh: bool,
    ks1_ucmac: bool,
    ks1_uksk: bool,
    ks1_urtf: bool,
    ks1_uckdf: bool,
    ks1_uhkdf: bool,
    ks1_uecsg: bool,
    ks1_uecdh: bool,
    ks1_uaes: bool,
    ks1_uhmac: bool,
    ks1_ukwk: bool,
    ks1_ukuok: bool,
    ks1_utlspms: bool,
    ks1_utlsms: bool,
    ks1_ukgsrc: bool,
    ks1_uhwo: bool,
    ks1_uwrpok: bool,
    ks1_uduk: bool,
    ks1_upprot: u2,
};

pub const Ks2Ksize = enum(u2) {
    size128 = 0,
    size256 = 1,
};

pub const ElsKs2 = bitpack struct(u32) {
    ks2_ksize: Ks2Ksize = .size128,
    reserved0: u3,
    ks2_kact: bool,
    ks2_kbase: bool,
    ks2_fgp: bool,
    ks2_frtn: bool,
    ks2_fhwo: bool,
    reserved1: u1,
    ks2_ukpuk: bool,
    ks2_utecdh: bool,
    ks2_ucmac: bool,
    ks2_uksk: bool,
    ks2_urtf: bool,
    ks2_uckdf: bool,
    ks2_uhkdf: bool,
    ks2_uecsg: bool,
    ks2_uecdh: bool,
    ks2_uaes: bool,
    ks2_uhmac: bool,
    ks2_ukwk: bool,
    ks2_ukuok: bool,
    ks2_utlspms: bool,
    ks2_utlsms: bool,
    ks2_ukgsrc: bool,
    ks2_uhwo: bool,
    ks2_uwrpok: bool,
    ks2_uduk: bool,
    ks2_upprot: u2,
};

pub const Ks3Ksize = enum(u2) {
    size128 = 0,
    size256 = 1,
};

pub const ElsKs3 = bitpack struct(u32) {
    ks3_ksize: Ks3Ksize = .size128,
    reserved0: u3,
    ks3_kact: bool,
    ks3_kbase: bool,
    ks3_fgp: bool,
    ks3_frtn: bool,
    ks3_fhwo: bool,
    reserved1: u1,
    ks3_ukpuk: bool,
    ks3_utecdh: bool,
    ks3_ucmac: bool,
    ks3_uksk: bool,
    ks3_urtf: bool,
    ks3_uckdf: bool,
    ks3_uhkdf: bool,
    ks3_uecsg: bool,
    ks3_uecdh: bool,
    ks3_uaes: bool,
    ks3_uhmac: bool,
    ks3_ukwk: bool,
    ks3_ukuok: bool,
    ks3_utlspms: bool,
    ks3_utlsms: bool,
    ks3_ukgsrc: bool,
    ks3_uhwo: bool,
    ks3_uwrpok: bool,
    ks3_uduk: bool,
    ks3_upprot: u2,
};

pub const Ks4Ksize = enum(u2) {
    size128 = 0,
    size256 = 1,
};

pub const ElsKs4 = bitpack struct(u32) {
    ks4_ksize: Ks4Ksize = .size128,
    reserved0: u3,
    ks4_kact: bool,
    ks4_kbase: bool,
    ks4_fgp: bool,
    ks4_frtn: bool,
    ks4_fhwo: bool,
    reserved1: u1,
    ks4_ukpuk: bool,
    ks4_utecdh: bool,
    ks4_ucmac: bool,
    ks4_uksk: bool,
    ks4_urtf: bool,
    ks4_uckdf: bool,
    ks4_uhkdf: bool,
    ks4_uecsg: bool,
    ks4_uecdh: bool,
    ks4_uaes: bool,
    ks4_uhmac: bool,
    ks4_ukwk: bool,
    ks4_ukuok: bool,
    ks4_utlspms: bool,
    ks4_utlsms: bool,
    ks4_ukgsrc: bool,
    ks4_uhwo: bool,
    ks4_uwrpok: bool,
    ks4_uduk: bool,
    ks4_upprot: u2,
};

pub const Ks5Ksize = enum(u2) {
    size128 = 0,
    size256 = 1,
};

pub const ElsKs5 = bitpack struct(u32) {
    ks5_ksize: Ks5Ksize = .size128,
    reserved0: u3,
    ks5_kact: bool,
    ks5_kbase: bool,
    ks5_fgp: bool,
    ks5_frtn: bool,
    ks5_fhwo: bool,
    reserved1: u1,
    ks5_ukpuk: bool,
    ks5_utecdh: bool,
    ks5_ucmac: bool,
    ks5_uksk: bool,
    ks5_urtf: bool,
    ks5_uckdf: bool,
    ks5_uhkdf: bool,
    ks5_uecsg: bool,
    ks5_uecdh: bool,
    ks5_uaes: bool,
    ks5_uhmac: bool,
    ks5_ukwk: bool,
    ks5_ukuok: bool,
    ks5_utlspms: bool,
    ks5_utlsms: bool,
    ks5_ukgsrc: bool,
    ks5_uhwo: bool,
    ks5_uwrpok: bool,
    ks5_uduk: bool,
    ks5_upprot: u2,
};

pub const Ks6Ksize = enum(u2) {
    size128 = 0,
    size256 = 1,
};

pub const ElsKs6 = bitpack struct(u32) {
    ks6_ksize: Ks6Ksize = .size128,
    reserved0: u3,
    ks6_kact: bool,
    ks6_kbase: bool,
    ks6_fgp: bool,
    ks6_frtn: bool,
    ks6_fhwo: bool,
    reserved1: u1,
    ks6_ukpuk: bool,
    ks6_utecdh: bool,
    ks6_ucmac: bool,
    ks6_uksk: bool,
    ks6_urtf: bool,
    ks6_uckdf: bool,
    ks6_uhkdf: bool,
    ks6_uecsg: bool,
    ks6_uecdh: bool,
    ks6_uaes: bool,
    ks6_uhmac: bool,
    ks6_ukwk: bool,
    ks6_ukuok: bool,
    ks6_utlspms: bool,
    ks6_utlsms: bool,
    ks6_ukgsrc: bool,
    ks6_uhwo: bool,
    ks6_uwrpok: bool,
    ks6_uduk: bool,
    ks6_upprot: u2,
};

pub const Ks7Ksize = enum(u2) {
    size128 = 0,
    size256 = 1,
};

pub const ElsKs7 = bitpack struct(u32) {
    ks7_ksize: Ks7Ksize = .size128,
    reserved0: u3,
    ks7_kact: bool,
    ks7_kbase: bool,
    ks7_fgp: bool,
    ks7_frtn: bool,
    ks7_fhwo: bool,
    reserved1: u1,
    ks7_ukpuk: bool,
    ks7_utecdh: bool,
    ks7_ucmac: bool,
    ks7_uksk: bool,
    ks7_urtf: bool,
    ks7_uckdf: bool,
    ks7_uhkdf: bool,
    ks7_uecsg: bool,
    ks7_uecdh: bool,
    ks7_uaes: bool,
    ks7_uhmac: bool,
    ks7_ukwk: bool,
    ks7_ukuok: bool,
    ks7_utlspms: bool,
    ks7_utlsms: bool,
    ks7_ukgsrc: bool,
    ks7_uhwo: bool,
    ks7_uwrpok: bool,
    ks7_uduk: bool,
    ks7_upprot: u2,
};

pub const Ks8Ksize = enum(u2) {
    size128 = 0,
    size256 = 1,
};

pub const ElsKs8 = bitpack struct(u32) {
    ks8_ksize: Ks8Ksize = .size128,
    reserved0: u3,
    ks8_kact: bool,
    ks8_kbase: bool,
    ks8_fgp: bool,
    ks8_frtn: bool,
    ks8_fhwo: bool,
    reserved1: u1,
    ks8_ukpuk: bool,
    ks8_utecdh: bool,
    ks8_ucmac: bool,
    ks8_uksk: bool,
    ks8_urtf: bool,
    ks8_uckdf: bool,
    ks8_uhkdf: bool,
    ks8_uecsg: bool,
    ks8_uecdh: bool,
    ks8_uaes: bool,
    ks8_uhmac: bool,
    ks8_ukwk: bool,
    ks8_ukuok: bool,
    ks8_utlspms: bool,
    ks8_utlsms: bool,
    ks8_ukgsrc: bool,
    ks8_uhwo: bool,
    ks8_uwrpok: bool,
    ks8_uduk: bool,
    ks8_upprot: u2,
};

pub const Ks9Ksize = enum(u2) {
    size128 = 0,
    size256 = 1,
};

pub const ElsKs9 = bitpack struct(u32) {
    ks9_ksize: Ks9Ksize = .size128,
    reserved0: u3,
    ks9_kact: bool,
    ks9_kbase: bool,
    ks9_fgp: bool,
    ks9_frtn: bool,
    ks9_fhwo: bool,
    reserved1: u1,
    ks9_ukpuk: bool,
    ks9_utecdh: bool,
    ks9_ucmac: bool,
    ks9_uksk: bool,
    ks9_urtf: bool,
    ks9_uckdf: bool,
    ks9_uhkdf: bool,
    ks9_uecsg: bool,
    ks9_uecdh: bool,
    ks9_uaes: bool,
    ks9_uhmac: bool,
    ks9_ukwk: bool,
    ks9_ukuok: bool,
    ks9_utlspms: bool,
    ks9_utlsms: bool,
    ks9_ukgsrc: bool,
    ks9_uhwo: bool,
    ks9_uwrpok: bool,
    ks9_uduk: bool,
    ks9_upprot: u2,
};

pub const Ks10Ksize = enum(u2) {
    size128 = 0,
    size256 = 1,
};

pub const ElsKs10 = bitpack struct(u32) {
    ks10_ksize: Ks10Ksize = .size128,
    reserved0: u3,
    ks10_kact: bool,
    ks10_kbase: bool,
    ks10_fgp: bool,
    ks10_frtn: bool,
    ks10_fhwo: bool,
    reserved1: u1,
    ks10_ukpuk: bool,
    ks10_utecdh: bool,
    ks10_ucmac: bool,
    ks10_uksk: bool,
    ks10_urtf: bool,
    ks10_uckdf: bool,
    ks10_uhkdf: bool,
    ks10_uecsg: bool,
    ks10_uecdh: bool,
    ks10_uaes: bool,
    ks10_uhmac: bool,
    ks10_ukwk: bool,
    ks10_ukuok: bool,
    ks10_utlspms: bool,
    ks10_utlsms: bool,
    ks10_ukgsrc: bool,
    ks10_uhwo: bool,
    ks10_uwrpok: bool,
    ks10_uduk: bool,
    ks10_upprot: u2,
};

pub const Ks11Ksize = enum(u2) {
    size128 = 0,
    size256 = 1,
};

pub const ElsKs11 = bitpack struct(u32) {
    ks11_ksize: Ks11Ksize = .size128,
    reserved0: u3,
    ks11_kact: bool,
    ks11_kbase: bool,
    ks11_fgp: bool,
    ks11_frtn: bool,
    ks11_fhwo: bool,
    reserved1: u1,
    ks11_ukpuk: bool,
    ks11_utecdh: bool,
    ks11_ucmac: bool,
    ks11_uksk: bool,
    ks11_urtf: bool,
    ks11_uckdf: bool,
    ks11_uhkdf: bool,
    ks11_uecsg: bool,
    ks11_uecdh: bool,
    ks11_uaes: bool,
    ks11_uhmac: bool,
    ks11_ukwk: bool,
    ks11_ukuok: bool,
    ks11_utlspms: bool,
    ks11_utlsms: bool,
    ks11_ukgsrc: bool,
    ks11_uhwo: bool,
    ks11_uwrpok: bool,
    ks11_uduk: bool,
    ks11_upprot: u2,
};

pub const Ks12Ksize = enum(u2) {
    size128 = 0,
    size256 = 1,
};

pub const ElsKs12 = bitpack struct(u32) {
    ks12_ksize: Ks12Ksize = .size128,
    reserved0: u3,
    ks12_kact: bool,
    ks12_kbase: bool,
    ks12_fgp: bool,
    ks12_frtn: bool,
    ks12_fhwo: bool,
    reserved1: u1,
    ks12_ukpuk: bool,
    ks12_utecdh: bool,
    ks12_ucmac: bool,
    ks12_uksk: bool,
    ks12_urtf: bool,
    ks12_uckdf: bool,
    ks12_uhkdf: bool,
    ks12_uecsg: bool,
    ks12_uecdh: bool,
    ks12_uaes: bool,
    ks12_uhmac: bool,
    ks12_ukwk: bool,
    ks12_ukuok: bool,
    ks12_utlspms: bool,
    ks12_utlsms: bool,
    ks12_ukgsrc: bool,
    ks12_uhwo: bool,
    ks12_uwrpok: bool,
    ks12_uduk: bool,
    ks12_upprot: u2,
};

pub const Ks13Ksize = enum(u2) {
    size128 = 0,
    size256 = 1,
};

pub const ElsKs13 = bitpack struct(u32) {
    ks13_ksize: Ks13Ksize = .size128,
    reserved0: u3,
    ks13_kact: bool,
    ks13_kbase: bool,
    ks13_fgp: bool,
    ks13_frtn: bool,
    ks13_fhwo: bool,
    reserved1: u1,
    ks13_ukpuk: bool,
    ks13_utecdh: bool,
    ks13_ucmac: bool,
    ks13_uksk: bool,
    ks13_urtf: bool,
    ks13_uckdf: bool,
    ks13_uhkdf: bool,
    ks13_uecsg: bool,
    ks13_uecdh: bool,
    ks13_uaes: bool,
    ks13_uhmac: bool,
    ks13_ukwk: bool,
    ks13_ukuok: bool,
    ks13_utlspms: bool,
    ks13_utlsms: bool,
    ks13_ukgsrc: bool,
    ks13_uhwo: bool,
    ks13_uwrpok: bool,
    ks13_uduk: bool,
    ks13_upprot: u2,
};

pub const Ks14Ksize = enum(u2) {
    size128 = 0,
    size256 = 1,
};

pub const ElsKs14 = bitpack struct(u32) {
    ks14_ksize: Ks14Ksize = .size128,
    reserved0: u3,
    ks14_kact: bool,
    ks14_kbase: bool,
    ks14_fgp: bool,
    ks14_frtn: bool,
    ks14_fhwo: bool,
    reserved1: u1,
    ks14_ukpuk: bool,
    ks14_utecdh: bool,
    ks14_ucmac: bool,
    ks14_uksk: bool,
    ks14_urtf: bool,
    ks14_uckdf: bool,
    ks14_uhkdf: bool,
    ks14_uecsg: bool,
    ks14_uecdh: bool,
    ks14_uaes: bool,
    ks14_uhmac: bool,
    ks14_ukwk: bool,
    ks14_ukuok: bool,
    ks14_utlspms: bool,
    ks14_utlsms: bool,
    ks14_ukgsrc: bool,
    ks14_uhwo: bool,
    ks14_uwrpok: bool,
    ks14_uduk: bool,
    ks14_upprot: u2,
};

pub const Ks15Ksize = enum(u2) {
    size128 = 0,
    size256 = 1,
};

pub const ElsKs15 = bitpack struct(u32) {
    ks15_ksize: Ks15Ksize = .size128,
    reserved0: u3,
    ks15_kact: bool,
    ks15_kbase: bool,
    ks15_fgp: bool,
    ks15_frtn: bool,
    ks15_fhwo: bool,
    reserved1: u1,
    ks15_ukpuk: bool,
    ks15_utecdh: bool,
    ks15_ucmac: bool,
    ks15_uksk: bool,
    ks15_urtf: bool,
    ks15_uckdf: bool,
    ks15_uhkdf: bool,
    ks15_uecsg: bool,
    ks15_uecdh: bool,
    ks15_uaes: bool,
    ks15_uhmac: bool,
    ks15_ukwk: bool,
    ks15_ukuok: bool,
    ks15_utlspms: bool,
    ks15_utlsms: bool,
    ks15_ukgsrc: bool,
    ks15_uhwo: bool,
    ks15_uwrpok: bool,
    ks15_uduk: bool,
    ks15_upprot: u2,
};

pub const Ks16Ksize = enum(u2) {
    size128 = 0,
    size256 = 1,
};

pub const ElsKs16 = bitpack struct(u32) {
    ks16_ksize: Ks16Ksize = .size128,
    reserved0: u3,
    ks16_kact: bool,
    ks16_kbase: bool,
    ks16_fgp: bool,
    ks16_frtn: bool,
    ks16_fhwo: bool,
    reserved1: u1,
    ks16_ukpuk: bool,
    ks16_utecdh: bool,
    ks16_ucmac: bool,
    ks16_uksk: bool,
    ks16_urtf: bool,
    ks16_uckdf: bool,
    ks16_uhkdf: bool,
    ks16_uecsg: bool,
    ks16_uecdh: bool,
    ks16_uaes: bool,
    ks16_uhmac: bool,
    ks16_ukwk: bool,
    ks16_ukuok: bool,
    ks16_utlspms: bool,
    ks16_utlsms: bool,
    ks16_ukgsrc: bool,
    ks16_uhwo: bool,
    ks16_uwrpok: bool,
    ks16_uduk: bool,
    ks16_upprot: u2,
};

pub const Ks17Ksize = enum(u2) {
    size128 = 0,
    size256 = 1,
};

pub const ElsKs17 = bitpack struct(u32) {
    ks17_ksize: Ks17Ksize = .size128,
    reserved0: u3,
    ks17_kact: bool,
    ks17_kbase: bool,
    ks17_fgp: bool,
    ks17_frtn: bool,
    ks17_fhwo: bool,
    reserved1: u1,
    ks17_ukpuk: bool,
    ks17_utecdh: bool,
    ks17_ucmac: bool,
    ks17_uksk: bool,
    ks17_urtf: bool,
    ks17_uckdf: bool,
    ks17_uhkdf: bool,
    ks17_uecsg: bool,
    ks17_uecdh: bool,
    ks17_uaes: bool,
    ks17_uhmac: bool,
    ks17_ukwk: bool,
    ks17_ukuok: bool,
    ks17_utlspms: bool,
    ks17_utlsms: bool,
    ks17_ukgsrc: bool,
    ks17_uhwo: bool,
    ks17_uwrpok: bool,
    ks17_uduk: bool,
    ks17_upprot: u2,
};

pub const Ks18Ksize = enum(u2) {
    size128 = 0,
    size256 = 1,
};

pub const ElsKs18 = bitpack struct(u32) {
    ks18_ksize: Ks18Ksize = .size128,
    reserved0: u3,
    ks18_kact: bool,
    ks18_kbase: bool,
    ks18_fgp: bool,
    ks18_frtn: bool,
    ks18_fhwo: bool,
    reserved1: u1,
    ks18_ukpuk: bool,
    ks18_utecdh: bool,
    ks18_ucmac: bool,
    ks18_uksk: bool,
    ks18_urtf: bool,
    ks18_uckdf: bool,
    ks18_uhkdf: bool,
    ks18_uecsg: bool,
    ks18_uecdh: bool,
    ks18_uaes: bool,
    ks18_uhmac: bool,
    ks18_ukwk: bool,
    ks18_ukuok: bool,
    ks18_utlspms: bool,
    ks18_utlsms: bool,
    ks18_ukgsrc: bool,
    ks18_uhwo: bool,
    ks18_uwrpok: bool,
    ks18_uduk: bool,
    ks18_upprot: u2,
};

pub const Ks19Ksize = enum(u2) {
    size128 = 0,
    size256 = 1,
};

pub const ElsKs19 = bitpack struct(u32) {
    ks19_ksize: Ks19Ksize = .size128,
    reserved0: u3,
    ks19_kact: bool,
    ks19_kbase: bool,
    ks19_fgp: bool,
    ks19_frtn: bool,
    ks19_fhwo: bool,
    reserved1: u1,
    ks19_ukpuk: bool,
    ks19_utecdh: bool,
    ks19_ucmac: bool,
    ks19_uksk: bool,
    ks19_urtf: bool,
    ks19_uckdf: bool,
    ks19_uhkdf: bool,
    ks19_uecsg: bool,
    ks19_uecdh: bool,
    ks19_uaes: bool,
    ks19_uhmac: bool,
    ks19_ukwk: bool,
    ks19_ukuok: bool,
    ks19_utlspms: bool,
    ks19_utlsms: bool,
    ks19_ukgsrc: bool,
    ks19_uhwo: bool,
    ks19_uwrpok: bool,
    ks19_uduk: bool,
    ks19_upprot: u2,
};

pub const ELS = extern struct {
    status: Status,
    ctrl: Ctrl,
    cmdcfg0: Cmdcfg0,
    cfg: Cfg,
    kidx0: Kidx0,
    kidx1: Kidx1,
    kpropin: Kpropin,
    reserved0: [4]u8,
    src0: DmaSrc0,
    src0: DmaSrc0Len,
    src1: DmaSrc1,
    reserved1: [4]u8,
    src2: DmaSrc2,
    src2: DmaSrc2Len,
    res0: DmaRes0,
    res0: DmaRes0Len,
    enable: IntEnable,
    status: IntStatusClr,
    status: IntStatusSet,
    status: ErrStatus,
    status: ErrStatusClr,
    version: Version,
    reserved2: [4]u8,
    datout: PrngDatout,
    ctrl: CmdcrcCtrl,
    cmdcrc: Cmdcrc,
    id: SessionId,
    reserved3: [4]u8,
    fin: DmaFinAddr,
    id: MasterId,
    kidx2: Kidx2,
    reserved4: [212]u8,
    ks0: ElsKs0,
    ks1: ElsKs1,
    ks2: ElsKs2,
    ks3: ElsKs3,
    ks4: ElsKs4,
    ks5: ElsKs5,
    ks6: ElsKs6,
    ks7: ElsKs7,
    ks8: ElsKs8,
    ks9: ElsKs9,
    ks10: ElsKs10,
    ks11: ElsKs11,
    ks12: ElsKs12,
    ks13: ElsKs13,
    ks14: ElsKs14,
    ks15: ElsKs15,
    ks16: ElsKs16,
    ks17: ElsKs17,
    ks18: ElsKs18,
    ks19: ElsKs19,
};

pub const els: *volatile ELS = @ptrFromInt(ELS_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1000, @sizeOf(ELS));

}
