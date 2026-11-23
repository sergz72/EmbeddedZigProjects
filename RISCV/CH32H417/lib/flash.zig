const FLASH_BASE = 0x40022000;

pub const FlashActlr = bitpack struct(u32) {
    sck_cfg: u2 = 0,
    reserved0: u4 = 0,
    enhance_status: bool = false,
    ehmod: bool = false,
    flash_lp: bool = false,
    reserved1: u5 = 0,
    flash_ready: bool = false,
    flash_st: bool = false,
    reserved2: u16 = 0,
};

pub const FlashStatr = bitpack struct(u32) {
    bsy: bool = false,
    wrbsy: bool = false,
    reserved0: u2 = 0,
    wrprterr: bool = false,
    eop: bool = false,
    reserved1: u6 = 8,
    boot_ava: bool = false,
    boot_status: bool = false,
    boot_mode: bool = false,
    boot_lock: bool = true,
    reserved2: u16 = 0,
};

pub const FlashCtlr = bitpack struct(u32) {
    pg: bool = false,
    per: bool = false,
    reserved0: u2 = 0,
    obpg: bool = false,
    ober: bool = false,
    strt: bool = false,
    lock: bool = true,
    reserved1: u1 = 0,
    obwre: bool = false,
    errie: bool = false,
    reserved2: u1 = 0,
    eopie: bool = false,
    reserved3: u2 = 1,
    flock: bool = true,
    ftpg: bool = false,
    reserved4: u1 = 0,
    ber: bool = false,
    reserved5: u2 = 0,
    pgstrt: bool = false,
    rsenact: bool = false,
    reserved6: u9 = 0,
};

pub const FlashObr = bitpack struct(u32) {
    oberr: bool,
    rdprt: bool,
    iwdg_sw: bool,
    reserved0: u5,
    fix_11: u2,
    data0: u8,
    data1: u8,
    reserved1: u6,
};

pub const FlashCfgr0 = bitpack struct(u32) {
    reserved0: u28,
    dbmode: bool,
    reserved1: u3,
};

pub const Flash = extern struct {
    actlr: FlashActlr,
    keyr: u32,
    obkeyr: u32,
    statr: FlashStatr,
    ctlr: FlashCtlr,
    addr: u32,
    reserved0: u32,
    obr: FlashObr,
    wpr: u32,
    modekeyr: u32,
    reserved1: u32,
    cfgr0: FlashCfgr0,
};

pub const flash: *volatile Flash = @ptrFromInt(FLASH_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x400, @sizeOf(Flash));

}
