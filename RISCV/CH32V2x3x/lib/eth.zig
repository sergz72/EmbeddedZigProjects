const ETH_MAC_BASE: usize = 0x40028000;
const ETH_MMC_BASE: usize = 0x40028100;
const ETH_PTP_BASE: usize = 0x40028700;
const ETH_DMA_BASE: usize = 0x40029000;

pub const EthHr = extern struct {
    hr: u32,
    lr: u32
};

pub const EthMac = extern struct {
    cr: u32,
    ffr: u32,
    ht: EthHr,
    miiar: u32,
    miidr: u32,
    fcr: u32,
    vlan: u32,
    reserved: [2]u32,
    wuffr: u32,
    pmtcsr: u32,
    reserved2: [2]u32,
    sr: u32,
    imr: u32,
    ahr: [4]EthHr,
    reserved3: [14]u32,
    cfg0: u32
};

pub const EthMmc = extern struct {
    cr: u32,
    rir: u32,
    tir: u32,
    rimr: u32,
    timr: u32,
    reserved: [14]u32,
    tgfsccr: u32,
    tgfmsccr: u32,
    reserved2: [5]u32,
    tgfscr: u32,
    reserved3: [10]u32,
    rfcecr: u32,
    rfaecr: u32,
    reserved4: [10]u32,
    rgufcr: u32
};

pub const EthPtp = extern struct {
    tscr: u32,
    ssir: u32,
    tsr: EthHr,
    tsur: EthHr,
    tsar: u32,
    tt: EthHr
};

pub const EthDma = extern struct {
    bmr: u32,
    tpdr: u32,
    rptr: u32,
    rdlar: u32,
    tdlar: u32,
    sr: u32,
    omr: u32,
    ier: u32,
    mfbocr: u32,
    reserved: [9]u32,
    chtdr: u32,
    chrdr: u32,
    chtbar: u32,
    chrbar: u32
};

pub const EthPhyReg = enum(u16) {
    _10Mbmcr = 0,
    _10Mbmsr = 1,
    _10Meth_anlpar = 5,
    _10Mphy_sr = 0x10,
    _10Mphy_mdix = 0x1e
};

pub const eth_mac: *volatile EthMac = @ptrFromInt(ETH_MAC_BASE);
pub const eth_mmc: *volatile EthMmc = @ptrFromInt(ETH_MMC_BASE);
pub const eth_ptp: *volatile EthPtp = @ptrFromInt(ETH_PTP_BASE);
pub const eth_dma: *volatile EthDma = @ptrFromInt(ETH_DMA_BASE);

pub fn eth_start() void {
    eth_mac_transmission_enable(true);
    eth_flush_transmission_fifo();
    eth_mac_reception_enable(true);
    eth_dma_transmission_enable(true);
    eth_dma_reception_enable(true);
}

pub fn eth_transmit(packet: []u8) void {
    _ = packet;
    //var offset: u32 = 0;
    //todo
}

pub fn eth_receive(packet: []u8) void {
    _ = packet;
    //var offset: u32 = 0;
    //var framelength: u32 = 0;
    //todo
}

pub fn eth_get_rx_packet_size(packet: []u8) u32 {
    _ = packet;
    //todo
    return 0;
}

pub fn eth_drop_rx_packet() void {
    //todo
}

pub fn eth_read_phy_register(phy_address: u16, phy_reg: EthPhyReg) u16 {
    _ = phy_address;
    _ = phy_reg;
    //todo
    return 0;
}

pub fn eth_write_phy_register(phy_address: u16, phy_reg: EthPhyReg, value: u16) bool {
    _ = phy_address;
    _ = phy_reg;
    _ = value;
    //todo
    return false;
}

pub fn eth_phy_loopback(phy_address: u16, enable: bool) bool {
    _ = phy_address;
    _ = enable;
    //todo
    return false;
}

pub inline fn eth_mac_transmission_enable(enable: bool) void {
    eth_mac.cr.te = enable;
}

pub inline fn eth_mac_reception_enable(enable: bool) void {
    eth_mac.cr.re = enable;
}

pub inline fn eth_get_flow_control_busy_satus() bool {
    return eth_mac.fcr.fcbbpa;
}

pub inline fn eth_initiate_pause_control_frame() void {
    eth_mac.fcr.fcbbpa = true;
}

pub inline fn eth_back_pressure_activation(enable: bool) void {
    eth_mac.fcr.fcbbpa = enable;
}

pub inline fn eth_mac_it_config(enable: bool) void {
    eth_mac.imr.it = !enable;
}

pub inline fn eth_mac_address_config(mac_addr_no: usize, mac_address: EthHr) void {
    eth_mac.ahr[mac_addr_no] = mac_address;
}

pub inline fn eth_get_mac_address(mac_addr_no: usize) EthHr {
    return eth_mac.ahr[mac_addr_no];
}

pub inline fn eth_mac_address_perfect_filter_enable(mac_addr_no: usize, enable: bool) void {
    _ = mac_addr_no;
    _ = enable;
    //todo
}

pub inline fn eth_mac_address_filter_config(mac_addr_no: usize, filter: u32) void {
    _ = mac_addr_no;
    _ = filter;
    //todo
}

pub inline fn eth_mac_address_mask_bytes_filter_config(mac_addr_no: usize, mask_byte: u32) void {
    _ = mac_addr_no;
    _ = mask_byte;
    //todo
}

pub inline fn eth_flush_transmission_fifo() void {
    //todo
}

pub inline fn eth_dma_transmission_enable(enable: bool) void {
    _ = enable;
    //todo
}

pub inline fn eth_dma_reception_enable(enable: bool) void {
    _ = enable;
    //todo
}

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x9C, @sizeOf(EthMac));
    try std.testing.expectEqual(0xC8, @sizeOf(EthMmc));
    try std.testing.expectEqual(0x24, @sizeOf(EthPtp));
    try std.testing.expectEqual(0x58, @sizeOf(EthDma));
}


