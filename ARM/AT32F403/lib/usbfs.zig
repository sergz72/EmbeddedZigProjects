const crm = @import("crm");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const usb_device = @import("usb_device");

const USBFS_BASE = 0x40005C00;
const USBFS_BUFFER_BASE_EX = 0x40007800;
const USBFS_BUFFER_SIZE_EX = 1280*2;
const USBFS_BUFFER_BASE = 0x40006000;
const USBFS_BUFFER_SIZE = 512*2;

pub const UsbfsEptSts = enum(u2) {
    disabled = 0,
    stall = 1,
    nak = 2,
    valid = 3
};

pub const UsbfsEptTransType = enum(u2) {
    bulk = 0,
    control = 1,
    isochronous = 2,
    interrupt = 3
};

pub const UsbfsEpt = packed struct(u16) {
    addr: u4 = 0,
    txsts: UsbfsEptSts = .disabled,
    txdts: bool = false,
    txtc: bool = false,
    exf: bool = false,
    trans_type: UsbfsEptTransType = .bulk,
    setuptc: bool = false,
    rxsts: UsbfsEptSts = .disabled,
    rxdts: bool = false,
    rxtc: bool = false
};

pub const UsbfsEpts = extern struct {
    ept: UsbfsEpt,
    reserved: u16
};

pub const UsbfsCtrl = packed struct(u16) {
    csrst: bool = true,
    disusb: bool = true,
    lpm: bool = false,
    ssp: bool = false,
    gresume: bool = false,
    reserved: u3 = 0,
    lsofien: bool = false,
    sofien: bool = false,
    rstien: bool = false,
    spien: bool = false,
    wkien: bool = false,
    beien: bool = false,
    ucforien: bool = false,
    tcien: bool = false
};

pub const UsbfsIntsts = packed struct(u16) {
    ept_num: u4 = 0,
    inout: bool = false,
    reserved: u3 = 0,
    lsof: bool = false,
    sof: bool = false,
    rst: bool = false,
    sp: bool = false,
    wk: bool = false,
    be: bool = false,
    ucfor: bool = false,
    tc: bool = false
};

pub const UsbfsSofrnum = packed struct(u16) {
    sofnum: u11,
    lsofnum: u2,
    clck: bool,
    dmsts: bool,
    dpsts: bool
};

pub const UsbfsDevaddr = packed struct(u16) {
    addr: u7 = 0,
    cen: bool = false,
    reserved: u8 = 0
};

pub const UsbfsCfg = packed struct(u16) {
    sofouten: bool = false,
    puo: bool = false,
    reserved: u14 = 0
};

pub const UsbfsTlen = packed struct(u16) {
    len: u10,
    reserved: u6
};

pub const UsbfsRlen = packed struct(u16) {
    len: u10,
    nblk: u5,
    bsize: bool
};

pub const UsbfsEptBufferInfo = extern struct {
    taddr: u16,
    reserved: u16,
    tlen: UsbfsTlen,
    reserved1: u16,
    raddr: u16,
    reserved2: u16,
    rlen: UsbfsRlen,
    reserved3: u16
};

pub const UsbfsBuffer = extern struct {
    info: [8]UsbfsEptBufferInfo,
    buffers: [(USBFS_BUFFER_SIZE_EX-128)/4]u32,

    pub fn enableEndpoint(self: *volatile UsbfsBuffer, ep_no: u3, rx_enable: bool, tx_enable: bool) void {
        if (rx_enable) {
            const pma_offset = allocatePMABuffer(usb_device.USB_FS_MAX_PACKET_SIZE);
            pma_buffers_rx[ep_no] = @ptrCast(&self.buffers[pma_offset]);
            // 2 blocks of 32 bytes each
            self.info[ep_no].raddr = @truncate(pma_offset*2+64);
            self.info[ep_no].rlen =  UsbfsRlen{.len = 0, .nblk = 2, .bsize = true};
        }
        if (tx_enable) {
            const pma_offset = allocatePMABuffer(usb_device.USB_FS_MAX_PACKET_SIZE);
            pma_buffers_tx[ep_no] = @ptrCast(&self.buffers[pma_offset]);
            self.info[ep_no].taddr = @truncate(pma_offset*2+64);
        }
    }

    pub fn getEndpointRxLength(self: *volatile UsbfsBuffer, ep_no: u3) u10 {
        return self.info[ep_no].rlen.len;
    }

    pub fn setEndpointTxLength(self: *volatile UsbfsBuffer, ep_no: u3, length: u16) void {
        self.info[ep_no].tlen.len = @truncate(length);
    }
};

pub const Usbfs = extern struct {
    ept: [8]UsbfsEpts,
    reserved5: [16]u16,
    ctrl: UsbfsCtrl,
    reserved: u16,
    intsts: UsbfsIntsts,
    reserved1: u16,
    sofrnum: UsbfsSofrnum,
    reserved2: u16,
    devaddr: UsbfsDevaddr,
    reserved3: u16,
    buftbl: u16,
    reserved4: [7]u16,
    cfg: UsbfsCfg,

    pub fn devicePreinit(self: *volatile Usbfs) bool {
        crm.crm.apb2en.gpioa = true;
        if (!crm.crm.usbFsClkConfig())
            return false;
        crm.crm.apb1en.usb = true;
        self.ctrl = UsbfsCtrl{.csrst = false, .disusb = false};
        self.intsts = UsbfsIntsts{};
        self.buftbl = 0;
        nvic.nvic.enableInterrupt(interrupts.Interrupt.USBFS_L_CAN1_RX0.toU8());
        self.ctrl = UsbfsCtrl{.csrst = false, .disusb = false, .sofien = true, .rstien = true,
                                .spien = true, .wkien = true, .tcien = true};
        sram_pointer = 0;
        usbfs_buffer.enableEndpoint(0, true, true);
        self.ep0Reset();
        return true;
    }

    pub fn deviceInit(self: *volatile Usbfs) void {
        self.devaddr = UsbfsDevaddr{.cen = true};
    }

    pub fn select_buffer(use_ex: bool) void {
        crm.crm.misc1.usbbufs = use_ex;
        if (use_ex) {
            usbfs_buffer = usbfs_buffer_ex;
        } else {
            usbfs_buffer = usbfs_buffer_nex;
        }
    }

    pub inline fn setAddress(self: *volatile Usbfs, address: u7) void {
        self.devaddr = UsbfsDevaddr{.addr = address, .cen = true};
    }

    pub fn setEndpointTxStatus(self: *volatile Usbfs, ep_no: u3, status: UsbfsEptSts) void {
        var chepr: u16 = @bitCast(self.ept[ep_no].ept);
        chepr &= 0x8FBF;
        chepr ^= @as(u16, @backingInt(status)) << 4;
        self.ept[ep_no].ept = @bitCast(chepr);
    }

    pub fn setEndpointRxStatus(self: *volatile Usbfs, ep_no: u3, status: UsbfsEptSts) void {
        var chepr: u16 = @bitCast(self.ept[ep_no].ept);
        chepr &= 0xBF8F;
        chepr ^= @as(u16, @backingInt(status)) << 12;
        self.ept[ep_no].ept = @bitCast(chepr);
    }

    pub fn getEndpointTxStatus(self: *volatile Usbfs, ep_no: u3) usb_device.EndpointStatus {
        return if (self.ept[ep_no].ept.txsts == UsbfsEptSts.stall) .stall else .ok;
    }

    pub fn getEndpointRxStatus(self: *volatile Usbfs, ep_no: u3) usb_device.EndpointStatus {
        return if (self.ept[ep_no].ept.rxsts == UsbfsEptSts.stall) .stall else .ok;
    }

    pub inline fn haltEndpointTx(self: *volatile Usbfs, ep_no: u3, halt: bool) void {
        self.setEndpointTxStatus(ep_no, if (halt) .stall else .nak);
    }

    pub inline fn haltEndpointRx(self: *volatile Usbfs, ep_no: u3, halt: bool) void {
        self.setEndpointRxStatus(ep_no, if (halt) .stall else .valid);
    }

    pub fn epReset(self: *volatile Usbfs, ep_no: u3, statrx: UsbfsEptSts, stattx: UsbfsEptSts,
                    endpoint_type: UsbfsEptTransType) void {
        self.ept[ep_no].ept = UsbfsEpt{
            .addr = ep_no,
            .trans_type = endpoint_type,
            .txsts = stattx,
            .rxsts = statrx};
    }

    pub fn ep0Reset(self: *volatile Usbfs) void {
        self.epReset(0, .valid, .nak, .control);
    }

    pub fn tx(self: *volatile Usbfs, ep_no: u3, data: []const u8) void {
        usb_device.copyToPMA1632(pma_buffers_tx[ep_no], data.ptr, data.len);
        usbfs_buffer.setEndpointTxLength(ep_no, @truncate(data.len));
        self.setEndpointTxStatus(ep_no, UsbfsEptSts.valid);
    }

    pub fn txZeroPacket(self: *volatile Usbfs, ep_no: u3) void {
        usbfs_buffer.setEndpointTxLength(ep_no, 0);
        self.setEndpointTxStatus(ep_no, UsbfsEptSts.valid);
    }
};

fn allocatePMABuffer(size: usize) usize {
    const current_pointer = sram_pointer;
    sram_pointer += size / 2;
    return current_pointer;
}

pub const usbfs: *volatile Usbfs = @ptrFromInt(USBFS_BASE);
const usbfs_buffer_ex: *volatile UsbfsBuffer = @ptrFromInt(USBFS_BUFFER_BASE_EX);
const usbfs_buffer_nex: *volatile UsbfsBuffer = @ptrFromInt(USBFS_BUFFER_BASE);
pub var usbfs_buffer = usbfs_buffer_nex;
var sram_pointer: usize = undefined;
pub var pma_buffers_rx: [8][*]volatile u32 = undefined;
pub var pma_buffers_tx: [8][*]volatile u32 = undefined;
pub var ep0_buffer: [usb_device.USB_FS_MAX_PACKET_SIZE]u8 align(4) = undefined;

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x62, @sizeOf(Usbfs));
}
