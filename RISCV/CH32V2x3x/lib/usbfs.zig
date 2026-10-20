const std = @import("std");
const rcc = @import("rcc");
const system_timer = @import("system_timer");
const gpio = @import("gpio");
const pfic = @import("pfic");
const interrupts = @import("interrupts");
const usb_device = @import("usb_device");

const USB_FS_MAX_PACKET_SIZE = 64;

const USBFS_BASE: usize = 0x50000000;

pub const UsbFsSysCtrl = enum(u2) {
    device_disable_host_normal_working_mode = 0,
    device_enable_no_pullup_host_se0 = 1,
    device_enable_with_pullup_host_j = 2
};

pub const UsbFsCtrl = packed struct(u8) {
    dma_en: bool = false,
    clr_all: bool = true,
    reset_sie: bool = true,
    int_busy: bool = false,
    sys_ctrl: UsbFsSysCtrl = .device_disable_host_normal_working_mode,
    low_speed: bool = false,
    host_mode: bool = false
};

pub const UsbFsIntEn = packed struct(u8) {
    bus_rst_or_detect: bool = false,
    transfer: bool = false,
    susp: bool = false,
    hst_sof: bool = false,
    fifo_ov: bool = false,
    one_wire_mode: bool = false,
    dev_nak: bool = false,
    reserved: u1 = 0
};

pub const UsbFsDevAd = packed struct(u8) {
    usb_addr: u7 = 0,
    gp_bit: bool = false
};

pub const UsbFsMisSt = packed struct(u8) {
    dev_attach: bool,
    dm_level: bool,
    suspended: bool,
    bus_reset: bool,
    r_fifo_rdy: bool,
    sie_free: bool,
    sof_act: bool,
    sof_pres: bool
};

pub const UsbFsIntFg = packed struct(u8) {
    bus_rst_or_detect: bool = false,
    transfer: bool = false,
    suspend_wakeup: bool = false,
    hst_sof: bool = false,
    fifo_ov: bool = false,
    sie_free: bool = true,
    tog_ok: bool = false,
    is_nak: bool = false
};

pub const UsbFsToken = enum(u2) {
    out = 0,
    reserved = 1,
    in = 2,
    setup = 3
};

pub const UsbFsIntSt = packed struct(u8) {
    h_res_or_endp: u4,
    token: UsbFsToken,
    tog_ok: bool,
    is_nak: bool
};

pub const UsbFsOtgCr = packed struct(u32) {
    dischar_vbus: bool = false,
    charge_vbus: bool = false,
    idpu: bool = false,
    otg_en: bool = false,
    vbus_vth: bool = false,
    sess_vth: bool = false,
    reserved: u26 = 0
};

pub const UsbFsOtgSr = packed struct(u32) {
    vbus_vld: bool,
    sess_vld: bool,
    sess_end: bool,
    sr_id_dig: bool,
    reserved: u28
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

pub const UsbFsUep41Mod = packed struct(u8) {
    ep4_buf_mod: bool = false,
    reserved: u1 = 0,
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

pub const UsbFsUep56Mod = packed struct(u8) {
    ep5_buf_mod: bool = false,
    reserved: u1 = 0,
    ep5_t_en: bool = false,
    ep5_r_en: bool = false,
    ep6_buf_mod: bool = false,
    reserved2: u1 = 0,
    ep6_t_en: bool = false,
    ep6_r_en: bool = false,
};

pub const UsbFsUep7Mod = packed struct(u8) {
    ep7_buf_mod: bool = false,
    reserved: u1 = 0,
    ep7_t_en: bool = false,
    ep7_r_en: bool = false,
    reserved2: u4 = 0
};

pub const UsbFsRes = enum(u2) {
    ack = 0,
    none = 1,
    nak = 2,
    stall = 3
};

pub const UsbFsUepTxRxCtrl = packed struct(u8) {
    res: UsbFsRes = .ack,
    tog: bool = false,
    tog_auto: bool = false,
    reserved: u4 = 0
};

pub const UsbFsUepCtrl = extern struct {
    t_len: u16,
    tx_ctrl: UsbFsUepTxRxCtrl,
    rx_ctrl: UsbFsUepTxRxCtrl
};

pub const UsbFs = extern struct {
    ctrl: UsbFsCtrl,
    udev_ctrl: UsbFsUdevCtrl,
    int_en: UsbFsIntEn,
    dev_ad: UsbFsDevAd,
    reserved3: u8,
    mis_st: UsbFsMisSt,
    int_fg: UsbFsIntFg,
    int_st: UsbFsIntSt,
    rx_len: u16,
    reserved4: u16,
    uep4_1_mod: UsbFsUep41Mod,
    uep2_3_mod: UsbFsUep23Mod,
    uep56_mod: UsbFsUep56Mod,
    uep7_mod: UsbFsUep7Mod,
    uep_dma: [8]u32,
    uep_ctrl: [8]UsbFsUepCtrl,
    reserved: u32,
    //0x54
    otg_cr: UsbFsOtgCr,
    otg_sr: UsbFsOtgSr,

    pub inline fn ep0Reset(self: *volatile UsbFs) void {
        self.uep_ctrl[0].tx_ctrl = .{.res = .nak};
        self.uep_ctrl[0].rx_ctrl = .{.res = .ack};
    }

    pub fn devicePreinit(self: *volatile UsbFs) bool {
        if (!rcc.rcc.usbFsClkConfig())
            return false;
        rcc.rcc.ahbpcenr.otg_fsen = true;

        self.ctrl = .{};
        system_timer.delayus(10);
        self.ctrl = .{.reset_sie = false, .clr_all = false};
        self.int_en = .{.susp = true, .bus_rst_or_detect = true, .transfer = true};
        self.ctrl = .{
            .reset_sie = false,
            .clr_all = false,
            .sys_ctrl = .device_enable_with_pullup_host_j,
            .int_busy = true,
            .dma_en = true
        };
        self.uep_dma[0] = @intFromPtr(&ep0_buffer);
        self.ep0Reset();
        return true;
    }

    pub fn deviceInit(self: *volatile UsbFs) void {
        self.udev_ctrl = .{.pd_dis = true, .port_en = true};
        UsbFs.interruptEnable();
    }

    pub inline fn interruptEnable() void {
        pfic.pfic.interruptEnable(interrupts.Interrupt.USBFS.toU8());
    }

    pub inline fn interruptDisable() void {
        pfic.pfic.interruptDisable(interrupts.Interrupt.USBFS.toU8());
    }

    pub inline fn setAddress(self: *volatile UsbFs, address: u7) void {
        self.dev_ad.usb_addr = address;
    }

    pub fn rTogAndAck(self: *volatile UsbFs, ep_no: u3) void {
        self.uep_ctrl[ep_no].rx_ctrl = .{.tog = true, .res = .ack};
    }

    pub fn tTogAndSetTxLen(self: *volatile UsbFs, ep_no: u3, tx_len: u16) void {
        const ep = &self.uep_ctrl[ep_no];
        ep.tx_ctrl.tog = !ep.tx_ctrl.tog;
        ep.t_len = tx_len;
    }

    pub fn tTogAndSendZeroPacket(self: *volatile UsbFs, ep_no: u3) void {
        const ep = &self.uep_ctrl[ep_no];
        ep.tx_ctrl = .{.tog = true, .res = .ack};
        ep.t_len = 0;
    }

    pub fn tTogAndNak(self: *volatile UsbFs, ep_no: u3) void {
        const ep = &self.uep_ctrl[ep_no];
        ep.tx_ctrl.tog = !ep.tx_ctrl.tog;
        ep.tx_ctrl.res = .nak;
    }

    pub fn rTog(self: *volatile UsbFs, ep_no: u3) void {
        const ep = &self.uep_ctrl[ep_no];
        ep.rx_ctrl.tog = !ep.rx_ctrl.tog;
    }

    pub fn enableEndpoint(self: *volatile UsbFs, ep_no: u3, rx_enable: bool, tx_enable: bool) void {
        switch (ep_no) {
            1 => {
                if (rx_enable) self.uep4_1_mod.ep1_r_en = true;
                if (tx_enable) self.uep4_1_mod.ep1_t_en = true;
            },
            2 => {
                if (rx_enable) self.uep2_3_mod.ep2_r_en = true;
                if (tx_enable) self.uep2_3_mod.ep2_t_en = true;
            },
            3 => {
                if (rx_enable) self.uep2_3_mod.ep3_r_en = true;
                if (tx_enable) self.uep2_3_mod.ep3_t_en = true;
            },
            4 => {
                if (rx_enable) self.uep4_1_mod.ep4_r_en = true;
                if (tx_enable) self.uep4_1_mod.ep4_t_en = true;
            },
            5 => {
                if (rx_enable) self.uep56_mod.ep5_r_en = true;
                if (tx_enable) self.uep56_mod.ep5_t_en = true;
            },
            6 => {
                if (rx_enable) self.uep56_mod.ep6_r_en = true;
                if (tx_enable) self.uep56_mod.ep6_t_en = true;
            },
            7 => {
                if (rx_enable) self.uep7_mod.ep7_r_en = true;
                if (tx_enable) self.uep7_mod.ep7_t_en = true;
            },
            else => {}
        }
    }

    pub fn setEndpointTxLength(self: *volatile UsbFs, ep_no: u3, length: u16) void {
        self.uep_ctrl[ep_no].t_len = length;
    }

    pub fn setEndpointTxStatus(self: *volatile UsbFs, ep_no: u3, status: UsbFsRes) void {
        self.uep_ctrl[ep_no].tx_ctrl.res = status;
    }

    pub fn setEndpointRxStatus(self: *volatile UsbFs, ep_no: u3, status: UsbFsRes) void {
        self.uep_ctrl[ep_no].rx_ctrl.res = status;
    }

    pub fn getEndpointTxStatus(self: *volatile UsbFs, ep_no: u3) usb_device.EndpointStatus {
        return if (self.uep_ctrl[ep_no].tx_ctrl.res == .stall) .stall else .ok;
    }

    pub fn getEndpointRxStatus(self: *volatile UsbFs, ep_no: u3) usb_device.EndpointStatus {
        return if (self.uep_ctrl[ep_no].rx_ctrl.res == .stall) .stall else .ok;
    }

    pub inline fn haltEndpointTx(self: *volatile UsbFs, ep_no: u3, halt: bool) void {
        self.uep_ctrl[ep_no].tx_ctrl.res = if (halt) .stall else .nak;
    }

    pub inline fn haltEndpointRx(self: *volatile UsbFs, ep_no: u3, halt: bool) void {
        self.uep_ctrl[ep_no].rx_ctrl.res = if (halt) .stall else .ack;
    }
};

pub const usbfs: *volatile UsbFs = @ptrFromInt(USBFS_BASE);
pub var ep0_buffer: [USB_FS_MAX_PACKET_SIZE]u8 align(4) = undefined;

test "sizeof test" {
    try std.testing.expectEqual(0x5C, @sizeOf(UsbFs));
}
