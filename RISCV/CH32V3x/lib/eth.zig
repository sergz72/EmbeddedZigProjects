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

pub const EthInterFrameGap = enum(u32) {
    _96Bit = 0,
    _88Bit = 0x00020000,
    _80Bit = 0x00040000,
    _72Bit = 0x00060000,
    _64Bit = 0x00080000,
    _56Bit = 0x000A0000,
    _48Bit = 0x000C0000,
    _40Bit = 0x000E0000
};

pub const EthMacSpeed = enum(u32) {
    _10M = 0,
    _100M = 0x00004000,
    _1000M = 0x00008000
};

pub const EthBackoffLimit = enum(u32) {
    _10 = 0,
    _8 = 0x20,
    _4 = 0x40,
    _1 = 0x60
};

pub const EthSourceAddrFilter = enum(u32) {
    disable = 0,
    normal = 0x200,
    inverse = 0x300
};

pub const EthPassControlFrames = enum(u32) {
    block_all = 0x40,
    forward_all = 0x80,
    forward_passed_addr_filter = 0xC0
};

pub const EthMulticastFramesFilter = enum(u32) {
    perfect_hash_table =0x00000404,
    hash_table = 0x00000004,
    perfect = 0,
    none = 0x00000010
};

pub const EthUnicastFramesFilter = enum(u32) {
    perfect_hash_table =0x00000402,
    hash_table = 0x00000002,
    perfect = 0
};

pub const EthPauseLowThreshold = enum(u32) {
    minus4 = 0,
    minus28 = 0x10,
    minus144 = 0x20,
    minus256 = 0x30
};

pub const EthVLANTagComparison = enum(u32) {
    _12bit = 0x00010000,
    _16bit = 0
};

pub const EthTransmitThresholdControl = enum(u32) {
    _64Bytes  = 0,
    _128Bytes = 0x00004000,
    _192Bytes = 0x00008000,
    _256Bytes = 0x0000C000,
    _40Bytes  = 0x00010000,
    _32Bytes  = 0x00014000,
    _24Bytes  = 0x00018000,
    _16Bytes  = 0x0001C000
};

pub const EthReceiveThresholdControl = enum(u32) {
    _64Bytes   = 0,
    _32Bytes   = 8,
    _96Bytes   = 0x10,
    _128Bytes  = 0x18
};

pub const EthRxDmaBurstLength = enum(u32) {
    _1Beat          = 0x00020000,
    _2Beat          = 0x00040000,
    _4Beat          = 0x00080000,
    _8Beat          = 0x00100000,
    _16Beat         = 0x00200000,
    _32Beat         = 0x00400000,
    _4xPBL_4Beat    = 0x01020000,
    _4xPBL_8Beat    = 0x01040000,
    _4xPBL_16Beat   = 0x01080000,
    _4xPBL_32Beat   = 0x01100000,
    _4xPBL_64Beat   = 0x01200000,
    _4xPBL_128Beat  = 0x01400000
};

pub const EthTxDmaBurstLength = enum(u32) {
    _1Beat          = 0x00000100,
    _2Beat          = 0x00000200,
    _4Beat          = 0x00000400,
    _8Beat          = 0x00000800,
    _16Beat         = 0x00001000,
    _32Beat         = 0x00002000,
    _4xPBL_4Beat    = 0x01000100,
    _4xPBL_8Beat    = 0x01000200,
    _4xPBL_16Beat   = 0x01000400,
    _4xPBL_32Beat   = 0x01000800,
    _4xPBL_64Beat   = 0x01001000,
    _4xPBL_128Beat  = 0x01002000
};

pub const EthDMAArbitration = enum(u32) {
    roundRobin_RxTx_1_1   = 0x00000000,
    roundRobin_RxTx_2_1   = 0x00004000,
    roundRobin_RxTx_3_1   = 0x00008000,
    roundRobin_RxTx_4_1   = 0x0000C000,
    rxPriorTx             = 0x00000002
};

pub const EthInit = struct {
    auto_negotiation: bool,
    watchdog: bool,
    jabber: bool,
    inter_frame_gap: EthInterFrameGap,
    carrier_sense: bool,
    receive_own: bool,
    loopback_mode: bool,
    mode_full_duplex: bool,
    checksum_offload: bool,
    retry_transmission: bool,
    automatic_pad_crc_strip: bool,
    backoff_limit: EthBackoffLimit,
    deferal_check: bool,
    receive_all: bool,
    source_addr_filter: EthSourceAddrFilter,
    pass_control_frames: EthPassControlFrames,
    broadcast_frames_reception: bool,
    destination_addr_filter_inverse: bool,
    promiscuous_mode: bool,
    multicast_frames_filter: EthMulticastFramesFilter,
    unicast_frames_filter: EthUnicastFramesFilter,
    hash_table: EthHr,
    pause_time: u32,
    zero_quanta_pause: bool,
    pause_low_threshold: EthPauseLowThreshold,
    unicast_pause_frame_detect: bool,
    receive_flow_control: bool,
    transmit_flow_control: bool,
    vlan_tag_comparison: EthVLANTagComparison,
    vlan_tag_identifier: u32,
    drop_tcpip_checksum_error_frame: bool,
    receive_store_forward: bool,
    flush_received_frame: bool,
    transmit_store_forward: bool,
    transmit_threshold_control: EthTransmitThresholdControl,
    forward_error_frames: bool,
    forward_undersized_good_frames: bool,
    receive_threshold_control: EthReceiveThresholdControl,
    second_frame_operate: bool,
    address_aligned_beats: bool,
    fixed_burst: bool,
    rx_dma_burst_length: EthRxDmaBurstLength,
    tx_dma_burst_length: EthTxDmaBurstLength,
    descriptor_skip_length: u32,
    dma_arbitration: EthDMAArbitration
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


