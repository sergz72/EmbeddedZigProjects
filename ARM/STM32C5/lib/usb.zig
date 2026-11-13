const usb_device = @import("usb_device");
const gpio = @import("gpio");
const rcc = @import("rcc");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const pwr = @import("pwr");

const USB_BASE = 0x40016000;

const USB_PORT = gpio.gpioa;
const USB_DM_PIN = 11;
const USB_DM_PIN_MASK: u16 = 1 << USB_DM_PIN;
const USB_DP_PIN = 12;
const USB_DP_PIN_MASK: u16 = 1 << USB_DP_PIN;

pub const UsbDeviceEndpointStatus = enum(u2) {
    disabled = 0,
    stall = 1,
    nak = 2,
    valid = 3
};

pub const UsbUsageType = enum(u2) {
    bulk = 0,
    control = 1,
    iso = 2,
    interrupt = 3
};

pub const UsbChepr = bitpack struct(u32) {
    ea: u4 = 0,
    stattx: u2 = 0,
    dtogtx: bool = false,
    vttx: bool = false,
    epkind: bool = false,
    utype: UsbUsageType = .bulk,
    setup: bool = false,
    statrx: u2 = 0,
    dtogrx: bool = false,
    vtrx: bool = false,
    devaddr: u7 = 0,
    nak: bool = false,
    ls_ep: bool = false,
    err_tx: bool = false,
    err_rx: bool = false,
    three_err_tx: u2 = 0,
    three_err_rx: u2 = 0,
    reserved0: u1 = 0,
};

pub const UsbCntr = bitpack struct(u32) {
    usbrst: bool = true,
    pdwn: bool = true,
    susprdy: bool = false,
    suspen: bool = false,
    l2res: bool = false,
    l1res: bool = false,
    reserved0: u1 = 0,
    l1reqm: bool = false,
    esofm: bool = false,
    sofm: bool = false,
    rst_dconm: bool = false,
    suspm: bool = false,
    wkupm: bool = false,
    errm: bool = false,
    pmaovrm: bool = false,
    ctrm: bool = false,
    thr512m: bool = false,
    ddiscm: bool = false,
    reserved1: u13 = 0,
    host: bool = false,
};

pub const UsbIstr = bitpack struct(u32) {
    idn: u4 = 0,
    dir: bool = false,
    reserved0: u2 = 0,
    l1req: bool = false,
    esof: bool = false,
    sof: bool = false,
    rst_dcon: bool = false,
    susp: bool = false,
    wkup: bool = false,
    err: bool = false,
    pmaovr: bool = false,
    ctr: bool = false,
    thr512: bool = false,
    ddisc: bool = false,
    reserved1: u11 = 0,
    dcon_stat: bool = false,
    ls_dcon: bool = false,
    reserved2: u1 = 0,
};

pub const UsbFnr = bitpack struct(u32) {
    fnum: u11 = 0,
    lsof: u2 = 0,
    lck: bool = false,
    rxdm: bool = false,
    rxdp: bool = false,
    reserved0: u16 = 0,
};

pub const UsbDaddr = bitpack struct(u32) {
    add: u7 = 0,
    ef: bool = false,
    reserved0: u24 = 0,
};

pub const UsbLpmcsr = bitpack struct(u32) {
    lpmen: bool = false,
    lpmack: bool = false,
    reserved0: u1 = 0,
    remwake: bool = false,
    besl: u4 = 0,
    reserved1: u24 = 0,
};

pub const UsbBcdr = bitpack struct(u32) {
    bcden: bool = false,
    dcden: bool = false,
    pden: bool = false,
    sden: bool = false,
    dcdet: bool = false,
    pdet: bool = false,
    sdet: bool = false,
    ps2det: bool = false,
    reserved0: u7 = 0,
    dppu_dpd: bool = false,
    reserved1: u16 = 0,
};

pub const UsbChepTx = bitpack struct(u32) {
    addr_tx: u16,
    count_tx: u10 = 0,
    reserved0: u6 = 0
};

pub const UsbChepRx = bitpack struct(u32) {
    addr_rx: u16,
    count_rx: u10 = 0,
    num_block: u5 = 0,
    blsize: bool = false
};

pub const UsbChep = extern struct {
    tx: UsbChepTx,
    rx: UsbChepRx
};

pub const Usb = extern struct {
    chepr: [8]UsbChepr,
    reserved0: [8]u32,
    cntr: UsbCntr,
    istr: UsbIstr,
    fnr: UsbFnr,
    daddr: UsbDaddr,
    reserved1: u32,
    lpmcsr: UsbLpmcsr,
    bcdr: UsbBcdr,
    reserved: [233]u32,
    chep: [8]UsbChep,
    sram: [496]u32,

    pub fn epReset(self: *volatile Usb, ep_no: u3, statrx: UsbDeviceEndpointStatus, stattx: UsbDeviceEndpointStatus,
                    endpoint_type: UsbUsageType) void {
        self.chepr[ep_no] = UsbChepr{
            .ea = ep_no,
            .utype = endpoint_type,
            .stattx = @backingInt(stattx),
            .statrx = @backingInt(statrx)};
    }

    pub fn ep0Reset(self: *volatile Usb) void {
        self.epReset(0, .valid, .nak, .control);
    }

    pub inline fn setAddress(self: *volatile Usb, address: u7) void {
        self.daddr = UsbDaddr{.add = address, .ef = true};
    }

    pub fn enableEndpoint(self: *volatile Usb, ep_no: u3, rx_enable: bool, tx_enable: bool) void {
        if (rx_enable) {
            const pma_offset = allocatePMABuffer(usb_device.USB_FS_MAX_PACKET_SIZE);
            pma_buffers_rx[ep_no] = @ptrCast(&self.sram[pma_offset]);
            // 2 blocks of 32 bytes each
            self.chep[ep_no].rx = UsbChepRx{.addr_rx =  @truncate(pma_offset*4+64), .num_block = 2, .blsize = true};
        }
        if (tx_enable) {
            const pma_offset = allocatePMABuffer(usb_device.USB_FS_MAX_PACKET_SIZE);
            pma_buffers_tx[ep_no] = @ptrCast(&self.sram[pma_offset]);
            self.chep[ep_no].tx = UsbChepTx{.addr_tx = @truncate(pma_offset*4+64)};
        }
    }

    pub fn getEndpointRxLength(self: *volatile Usb, ep_no: u3) u10 {
        return self.chep[ep_no].rx.count_rx;
    }

    pub fn setEndpointTxLength(self: *volatile Usb, ep_no: u3, length: u16) void {
        self.chep[ep_no].tx.count_tx = @truncate(length);
    }

    pub fn setEndpointTxStatus(self: *volatile Usb, ep_no: u3, status: UsbDeviceEndpointStatus) void {
        var chepr: u32 = @bitCast(self.chepr[ep_no]);
        chepr &= 0xFFFF_8FBF;
        chepr ^= @as(u32, @backingInt(status)) << 4;
        self.chepr[ep_no] = @bitCast(chepr);
    }

    pub fn setEndpointRxStatus(self: *volatile Usb, ep_no: u3, status: UsbDeviceEndpointStatus) void {
        var chepr: u32 = @bitCast(self.chepr[ep_no]);
        chepr &= 0xFFFF_BF8F;
        chepr ^= @as(u32, @backingInt(status)) << 12;
        self.chepr[ep_no] = @bitCast(chepr);
    }

    pub fn getEndpointTxStatus(self: *volatile Usb, ep_no: u3) usb_device.EndpointStatus {
        return if (self.chepr[ep_no].stattx == @backingInt(UsbDeviceEndpointStatus.stall)) .stall else .ok;
    }

    pub fn getEndpointRxStatus(self: *volatile Usb, ep_no: u3) usb_device.EndpointStatus {
        return if (self.chepr[ep_no].statrx == @backingInt(UsbDeviceEndpointStatus.stall)) .stall else .ok;
    }

    pub inline fn haltEndpointTx(self: *volatile Usb, ep_no: u3, halt: bool) void {
        self.setEndpointTxStatus(ep_no, if (halt) .stall else .nak);
    }

    pub inline fn haltEndpointRx(self: *volatile Usb, ep_no: u3, halt: bool) void {
        self.setEndpointRxStatus(ep_no, if (halt) .stall else .valid);
    }

    pub fn devicePreinit(self: *volatile Usb, usb_clock_source: rcc.UsbfsSel) void {
        rcc.rcc.hpenr.ahb2.gpioaen = true;
        pwr.pwr.enableUsbPower();
        const init_data: gpio.GpioInit = .{
            .mode = .alternate,
            .speed = .very_high,
            .alternate = 10
        };
        USB_PORT.init(USB_DP_PIN_MASK | USB_DM_PIN_MASK, init_data);
        rcc.rcc.enableUsbClock(usb_clock_source);
        nvic.nvic.enableInterrupt(interrupts.Interrupt.USB_DRD_FS.toU8());

        self.cntr = UsbCntr{
            .errm = true,
            .pmaovrm = true,
            .ctrm = true,
            .thr512m = true,
            .suspm = true,
            .wkupm = true,
            .rst_dconm = true,
            .usbrst = false,
            .pdwn = false
        };
        sram_pointer = 0;
        self.enableEndpoint(0, true, true);
        self.ep0Reset();
    }

    pub fn deviceInit(self: *volatile Usb) void {
        self.daddr = UsbDaddr{.ef = true};
        self.bcdr = UsbBcdr{.dppu_dpd = true};
    }

    pub fn tx(self: *volatile Usb, ep_no: u3, data: []const u8) void {
        usb_device.copyToPMA32(pma_buffers_tx[ep_no], data.ptr, data.len);
        self.setEndpointTxLength(ep_no, @truncate(data.len));
        self.setEndpointTxStatus(ep_no, .valid);
    }

    pub fn txZeroPacket(self: *volatile Usb, ep_no: u3) void {
        self.setEndpointTxLength(ep_no, 0);
        self.setEndpointTxStatus(ep_no, .valid);
    }
};

fn allocatePMABuffer(size: usize) usize {
    const current_pointer = sram_pointer;
    sram_pointer += size / 4;
    return current_pointer;
}

pub const usb: *volatile Usb = @ptrFromInt(USB_BASE);
pub var ep0_buffer: [usb_device.USB_FS_MAX_PACKET_SIZE]u8 align(4) = undefined;
pub var pma_buffers_rx: [8][*]volatile u32 = undefined;
pub var pma_buffers_tx: [8][*]volatile u32 = undefined;
var sram_pointer: usize = undefined;

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0xC00, @sizeOf(Usb));
}
