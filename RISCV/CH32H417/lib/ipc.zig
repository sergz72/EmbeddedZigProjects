const IPC_BASE = 0xE000D000;

pub const IpcCtlr = bitpack struct(u32) {
    tx_cid0: bool = false,
    reserved0: u1 = 0,
    rx_cid0: bool = false,
    reserved1: u1 = 0,
    tx_ier0: bool = false,
    rx_ier0: bool = false,
    autoen0: bool = false,
    lock0: bool = false,
    tx_cid1: bool = false,
    reserved2: u1 = 0,
    rx_cid1: bool = false,
    reserved3: u1 = 0,
    tx_ier1: bool = false,
    rx_ier1: bool = false,
    autoen1: bool = false,
    lock1: bool = false,
    tx_cid2: bool = false,
    reserved4: u1 = 0,
    rx_cid2: bool = false,
    reserved5: u1 = 0,
    tx_ier2: bool = false,
    rx_ier2: bool = false,
    autoen2: bool = false,
    lock2: bool = false,
    tx_cid3: bool = false,
    reserved6: u1 = 0,
    rx_cid3: bool = false,
    reserved7: u1 = 0,
    tx_ier3: bool = false,
    rx_ier3: bool = false,
    autoen3: bool = false,
    lock3: bool = false,
};

pub const Ipcr = bitpack struct(u32) {
    ipc0: u8 = 0,
    ipc1: u8 = 0,
    ipc2: u8 = 0,
    ipc3: u8 = 0,
};

pub const Ipc = extern struct {
    ctlr: IpcCtlr,
    isr: Ipcr,
    ism: Ipcr,
    reserved0: u32,
    ena: Ipcr,
    sts: Ipcr,
    set: Ipcr,
    clr: Ipcr,
    msg: [4]u32,
};

pub const ipc: *volatile Ipc = @ptrFromInt(IPC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x30, @sizeOf(Ipc));
}
