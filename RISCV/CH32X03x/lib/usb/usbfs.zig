const std = @import("std");
const rcc = @import("rcc");
const gpio = @import("gpio");
const afio = @import("afio");
const pfic = @import("pfic");
const interrupts = @import("interrupts");

const USB_FS_MAX_PACKET_SIZE = 64;

const USBFS_BASE: usize = 0x40023400;

pub const EndpointStatus = enum {
    ok,
    stall,
    invalid_request
};

pub const UsbFsBaseCtrl = packed struct(u8) {
    dma_en: bool = false,
    clr_all: bool = true,
    rst_sie: bool = false,
    int_busy: bool = false,
    sys_mode: u2 = 0,
    low_speed: bool = false,
    host_mode: bool = false
};

pub const UsbFsIntEn = packed struct(u8) {
    bus_rst_or_detect: bool = false,
    transfer: bool = false,
    suspend_wakeup: bool = false,
    sof: bool = false,
    fifo_ov: bool = false,
    one_wire: bool = false,
    dev_nak: bool = false,
    reserved: u1 = 0
};

pub const UsbFsMisSt = packed struct(u8) {
    dev_attach: bool,
    dm_level: bool,
    suspended: bool,
    bus_rst: bool,
    r_firo_rdy: bool,
    free: bool,
    sof: bool,
    sof_pres: bool
};

pub const UsbFsIntFg = packed struct(u8) {
    bus_rst_or_detect: bool = false,
    transfer: bool = false,
    suspend_wakeup: bool = false,
    sof: bool = false,
    fifo_ov: bool = false,
    free: bool = false,
    match_sync: bool = false,
    is_nak: bool = false
};

pub const UsbFsToken = enum(u2) {
    out = 0,
    sof = 1,
    in = 2,
    setup = 3
};

pub const UsbFsIntSt = packed struct(u8) {
    h_res_or_endp: u4,
    token: UsbFsToken,
    tog_ok: bool,
    setup: bool
};

pub const UsbFsUep41Mod = packed struct(u8) {
    reserved: u2 = 0,
    ep4_t_en: bool = false,
    ep4_r_en: bool = false,
    ep1_buf_mod: bool = false,
    reserved2: u1 = 0,
    ep1_t_en: bool = false,
    ep1_r_en: bool = false,
};

pub const UsbFsUep23Mod = packed struct(u8) {
    ep2_buf_mod: bool = false,
    reserved: u1 = 0,
    ep2_t_en: bool = false,
    ep2_r_en: bool = false,
    ep3_buf_mod: bool = false,
    reserved2: u1 = 0,
    ep3_t_en: bool = false,
    ep3_r_en: bool = false,
};

pub const UsbFsUep567Mod = packed struct(u8) {
    ep5_t_en: bool = false,
    ep5_r_en: bool = false,
    ep6_t_en: bool = false,
    ep6_r_en: bool = false,
    ep7_t_en: bool = false,
    ep7_r_en: bool = false,
    reserved: u2 = 0
};

pub const UsbFsUdevCtrl = packed struct(u8) {
    port_en: bool = false,
    gp_bit: bool = false,
    low_speed: bool = false,
    reserved: u1 = 0,
    dm_pin: bool = false,
    dp_pin: bool = false,
    reserved2: u1 = 0,
    pd_dis: bool = true
};

pub const UsbFsRes = enum(u2) {
    ack = 0,
    nyet = 1,
    nak = 2,
    stall = 3
};

pub const UsbFsUepCtrl32 = packed struct(u32) {
    tx_len: u7 = 0,
    reserved: u9 = 0,
    t_res: UsbFsRes = .ack,
    r_res: UsbFsRes = .ack,
    tog_auto: bool = false,
    reserved2: u1 = 0,
    t_tog: bool = false,
    r_tog: bool = false,
    reserved3: u8 = 0
};

pub const UsbFsUepCtrlH = packed struct(u16) {
    t_res: UsbFsRes = .ack,
    r_res: UsbFsRes = .ack,
    tog_auto: bool = false,
    reserved: u1 = 0,
    t_tog: bool = false,
    r_tog: bool = false,
    reserved2: u8 = 0
};

pub const UsbFsUepTxLen = packed struct(u16) {
    tx_len: u7 = 0,
    reserved: u9 = 0
};

pub const UsbFsUepCtrl16 = extern struct {
    tx_len: UsbFsUepTxLen,
    ctrl_h: UsbFsUepCtrlH
};

pub const UsbFsUepCtrl = extern union {
    ctrl32: UsbFsUepCtrl32,
    ctrl16: UsbFsUepCtrl16,

    pub fn tTog(self: *volatile UsbFsUepCtrl) void {
        self.ctrl16.ctrl_h.t_tog = !self.ctrl16.ctrl_h.t_tog;
    }

    pub fn rTog(self: *volatile UsbFsUepCtrl) void {
        self.ctrl16.ctrl_h.r_tog = !self.ctrl16.ctrl_h.r_tog;
    }
};

pub const UsbFs = extern struct {
    base_ctrl: UsbFsBaseCtrl,
    udev_ctrl: UsbFsUdevCtrl,
    int_en: UsbFsIntEn,
    dev_addr: u8,
    reserved2: u8,
    mis_st: UsbFsMisSt,
    int_fg: UsbFsIntFg,
    int_st: UsbFsIntSt,
    rx_len: u16,
    reserved3: u16,
    uep4_1_mod: UsbFsUep41Mod,
    uep2_3_mod: UsbFsUep23Mod,
    uep567_mod: UsbFsUep567Mod,
    reserved4: u8,
    uep_dma: [4]u32, // ep0-3
    uep_ctrl: [5]UsbFsUepCtrl, //ep0-4
    reserved5: [8]u32,
    uep_dma2: [3]u32,//ep5-7
    reserved6: u32,
    uep_ctrl2: [3]UsbFsUepCtrl,//ep5-7
    uepx_mod: u32,

    pub inline fn ep0Reset(self: *volatile UsbFs) void {
        self.uep_ctrl[0].ctrl16.ctrl_h = UsbFsUepCtrlH{.t_res = .nak, .r_res = .ack};
    }

    pub fn devicePreinit(self: *volatile UsbFs) void {
        rcc.rcc.apb2pcenr.iopcen = true;
        rcc.rcc.apb2pcenr.afioen = true;
        rcc.rcc.ahbpcenr.usbfsen = true;

        gpio.gpioc.init(1 << 16, gpio.GpioCnfInputFloating);
        gpio.gpioc.bsxr = 1 << 1; // pullup, pc17
        gpio.gpioc.init(1 << 17, gpio.GpioCnfInputPullupPulldown);

        afio.afio.ctlr.usb_phy_v33 = true;
        afio.afio.ctlr.usb_ioen = true;
        afio.afio.ctlr.udp_pue = ._1k5;

        self.base_ctrl = UsbFsBaseCtrl{};
        self.uep_dma[0] = @intFromPtr(&ep0_buffer);
        self.ep0Reset();
    }

    pub fn deviceInit(self: *volatile UsbFs) void {
        self.dev_addr = 0;
        // sys_mode 2 is USBFS_UC_DEV_PU_EN
        self.base_ctrl = UsbFsBaseCtrl{.dma_en = true, .int_busy = true, .sys_mode = 2};
        self.int_fg = UsbFsIntFg{
            .bus_rst_or_detect = true, .fifo_ov = true, .free = true, .is_nak = true,
            .match_sync = true, .sof = true, .suspend_wakeup = true, .transfer = true
        };
        self.udev_ctrl = UsbFsUdevCtrl{.pd_dis = true, .port_en = true};
        self.int_en = UsbFsIntEn{.suspend_wakeup = true, .bus_rst_or_detect = true, .transfer = true};
        UsbFs.interruptEnable();
    }

    pub inline fn interruptEnable() void {
        pfic.pfic.interruptEnable(interrupts.Interrupt.USBFS.toU8());
    }

    pub inline fn interruptDisable() void {
        pfic.pfic.interruptDisable(interrupts.Interrupt.USBFS.toU8());
    }

    pub inline fn setAddress(self: *volatile UsbFs, address: u8) void {
        self.dev_addr = address;
    }

    pub inline fn getEp0(self: *volatile UsbFs) *volatile UsbFsUepCtrl {
        return &self.uep_ctrl[0];
    }

    pub inline fn getEp1(self: *volatile UsbFs) *volatile UsbFsUepCtrl {
        return &self.uep_ctrl[1];
    }

    pub inline fn getEp1TxStatus(self: *volatile UsbFs) EndpointStatus {
        return if (self.uep_ctrl[1].ctrl16.ctrl_h.t_res == .stall) .stall else .ok;
    }

    pub inline fn getEp1RxStatus(self: *volatile UsbFs) EndpointStatus {
        return if (self.uep_ctrl[1].ctrl16.ctrl_h.r_res == .stall) .stall else .ok;
    }

    pub inline fn haltEp1Tx(self: *volatile UsbFs, halt: bool) void {
        self.uep_ctrl[1].ctrl16.ctrl_h.t_res = if (halt) .stall else .nak;
    }

    pub inline fn haltEp1Rx(self: *volatile UsbFs, halt: bool) void {
        self.uep_ctrl[1].ctrl16.ctrl_h.t_res = if (halt) .stall else .ack;
    }

    pub inline fn getEp2(self: *volatile UsbFs) *volatile UsbFsUepCtrl {
        return &self.uep_ctrl[2];
    }

    pub inline fn getEp2TxStatus(self: *volatile UsbFs) EndpointStatus {
        return if (self.uep_ctrl[2].ctrl16.ctrl_h.t_res == .stall) .stall else .ok;
    }

    pub inline fn getEp2RxStatus(self: *volatile UsbFs) EndpointStatus {
        return if (self.uep_ctrl[2].ctrl16.ctrl_h.r_res == .stall) .stall else .ok;
    }

    pub inline fn haltEp2Tx(self: *volatile UsbFs, halt: bool) void {
        self.uep_ctrl[2].ctrl16.ctrl_h.t_res = if (halt) .stall else .nak;
    }

    pub inline fn haltEp2Rx(self: *volatile UsbFs, halt: bool) void {
        self.uep_ctrl[2].ctrl16.ctrl_h.t_res = if (halt) .stall else .ack;
    }

    pub inline fn getEp3(self: *volatile UsbFs) *volatile UsbFsUepCtrl {
        return &self.uep_ctrl[3];
    }

    pub inline fn getEp3TxStatus(self: *volatile UsbFs) EndpointStatus {
        return if (self.uep_ctrl[3].ctrl16.ctrl_h.t_res == .stall) .stall else .ok;
    }

    pub inline fn getEp3RxStatus(self: *volatile UsbFs) EndpointStatus {
        return if (self.uep_ctrl[3].ctrl16.ctrl_h.r_res == .stall) .stall else .ok;
    }

    pub inline fn haltEp3Tx(self: *volatile UsbFs, halt: bool) void {
        self.uep_ctrl[3].ctrl16.ctrl_h.t_res = if (halt) .stall else .nak;
    }

    pub inline fn haltEp3Rx(self: *volatile UsbFs, halt: bool) void {
        self.uep_ctrl[3].ctrl16.ctrl_h.t_res = if (halt) .stall else .ack;
    }

    pub inline fn getEp4(self: *volatile UsbFs) *volatile UsbFsUepCtrl {
        return &self.uep_ctrl[4];
    }

    pub inline fn getEp4TxStatus(self: *volatile UsbFs) EndpointStatus {
        return if (self.uep_ctrl[4].ctrl16.ctrl_h.t_res == .stall) .stall else .ok;
    }

    pub inline fn haltEp4Tx(self: *volatile UsbFs, halt: bool) void {
        self.uep_ctrl[4].ctrl16.ctrl_h.t_res = if (halt) .stall else .nak;
    }

    pub inline fn haltEp4Rx(self: *volatile UsbFs, halt: bool) void {
        self.uep_ctrl[4].ctrl16.ctrl_h.t_res = if (halt) .stall else .ack;
    }

    pub inline fn getEp4RxStatus(self: *volatile UsbFs) EndpointStatus {
        return if (self.uep_ctrl[4].ctrl16.ctrl_h.r_res == .stall) .stall else .ok;
    }

    pub inline fn getEp5(self: *volatile UsbFs) *volatile UsbFsUepCtrl {
        return &self.uep_ctrl2[0];
    }

    pub inline fn getEp5TxStatus(self: *volatile UsbFs) EndpointStatus {
        return if (self.uep_ctrl2[0].ctrl16.ctrl_h.t_res == .stall) .stall else .ok;
    }

    pub inline fn getEp5RxStatus(self: *volatile UsbFs) EndpointStatus {
        return if (self.uep_ctrl2[0].ctrl16.ctrl_h.r_res == .stall) .stall else .ok;
    }

    pub inline fn haltEp5Tx(self: *volatile UsbFs, halt: bool) void {
        self.uep_ctrl2[0].ctrl16.ctrl_h.t_res = if (halt) .stall else .nak;
    }

    pub inline fn haltEp5Rx(self: *volatile UsbFs, halt: bool) void {
        self.uep_ctrl2[0].ctrl16.ctrl_h.t_res = if (halt) .stall else .ack;
    }

    pub inline fn getEp6(self: *volatile UsbFs) *volatile UsbFsUepCtrl {
        return &self.uep_ctrl2[1];
    }

    pub inline fn getEp6TxStatus(self: *volatile UsbFs) EndpointStatus {
        return if (self.uep_ctrl2[1].ctrl16.ctrl_h.t_res == .stall) .stall else .ok;
    }

    pub inline fn getEp6RxStatus(self: *volatile UsbFs) EndpointStatus {
        return if (self.uep_ctrl2[1].ctrl16.ctrl_h.r_res == .stall) .stall else .ok;
    }

    pub inline fn haltEp6Tx(self: *volatile UsbFs, halt: bool) void {
        self.uep_ctrl2[1].ctrl16.ctrl_h.t_res = if (halt) .stall else .nak;
    }

    pub inline fn haltEp6Rx(self: *volatile UsbFs, halt: bool) void {
        self.uep_ctrl2[1].ctrl16.ctrl_h.t_res = if (halt) .stall else .ack;
    }

    pub inline fn getEp7(self: *volatile UsbFs) *volatile UsbFsUepCtrl {
        return &self.uep_ctrl2[2];
    }

    pub inline fn getEp7TxStatus(self: *volatile UsbFs) EndpointStatus {
        return if (self.uep_ctrl2[2].ctrl16.ctrl_h.t_res == .stall) .stall else .ok;
    }

    pub inline fn getEp7RxStatus(self: *volatile UsbFs) EndpointStatus {
        return if (self.uep_ctrl2[2].ctrl16.ctrl_h.r_res == .stall) .stall else .ok;
    }

    pub inline fn haltEp7Tx(self: *volatile UsbFs, halt: bool) void {
        self.uep_ctrl2[2].ctrl16.ctrl_h.t_res = if (halt) .stall else .nak;
    }

    pub inline fn haltEp7Rx(self: *volatile UsbFs, halt: bool) void {
        self.uep_ctrl2[2].ctrl16.ctrl_h.t_res = if (halt) .stall else .ack;
    }

    fn getEndpoint(self: *volatile UsbFs, ep_no: u4) *volatile UsbFsUepCtrl {
        return switch (ep_no) {
            0 => &self.uep_ctrl[0],
            1 => &self.uep_ctrl[1],
            2 => &self.uep_ctrl[2],
            3 => &self.uep_ctrl[3],
            4 => &self.uep_ctrl[4],
            5 => &self.uep_ctrl2[0],
            6 => &self.uep_ctrl2[1],
            else => &self.uep_ctrl2[2]
        };
    }
};

pub const usbfs: *volatile UsbFs = @ptrFromInt(USBFS_BASE);
pub var ep0_buffer: [USB_FS_MAX_PACKET_SIZE]u8 align(4) = undefined;

test "sizeof test" {
    try std.testing.expectEqual(0x74, @sizeOf(UsbFs));
}
