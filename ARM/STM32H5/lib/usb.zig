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

pub const UsbChepr = packed struct(u32) {
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

pub const UsbCntr = packed struct(u32) {
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

pub const UsbIstr = packed struct(u32) {
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

pub const UsbFnr = packed struct(u32) {
    fnum: u11 = 0,
    lsof: u2 = 0,
    lck: bool = false,
    rxdm: bool = false,
    rxdp: bool = false,
    reserved0: u16 = 0,
};

pub const UsbDaddr = packed struct(u32) {
    add: u7 = 0,
    ef: bool = false,
    reserved0: u24 = 0,
};

pub const UsbLpmcsr = packed struct(u32) {
    lpmen: bool = false,
    lpmack: bool = false,
    reserved0: u1 = 0,
    remwake: bool = false,
    besl: u4 = 0,
    reserved1: u24 = 0,
};

pub const UsbBcdr = packed struct(u32) {
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

pub const UsbChepTx = packed struct(u32) {
    addr_tx: u16,
    count_tx: u10,
    reserved0: u6
};

pub const UsbChepRx = packed struct(u32) {
    addr_rx: u16,
    count_rx: u10,
    num_block: u5,
    blsize: bool
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

    pub inline fn ep0Reset(self: *volatile Usb) void {
        const chepr = self.chepr[0];
        self.chepr[0] = UsbChepr{
            .utype = UsbUsageType.control,
            .stattx = chepr.stattx ^ @backingInt(UsbDeviceEndpointStatus.nak),
            .statrx = chepr.statrx ^ @backingInt(UsbDeviceEndpointStatus.valid)};
    }

    pub inline fn setAddress(self: *volatile Usb, address: u7) void {
        self.daddr = UsbDaddr{.add = address, .ef = true};
    }

    pub fn enableEndpoint(self: *volatile Usb, ep_no: u3, rx_enable: bool, tx_enable: bool) void {
        _ = self;
        _ = ep_no;
        _ = rx_enable;
        _ = tx_enable;
    }

    pub fn setEndpointTxLength(self: *volatile Usb, ep_no: u3, length: u16) void {
        self.chep[ep_no].tx.count_tx = @truncate(length);
    }

    pub fn setEndpointTxStatus(self: *volatile Usb, ep_no: u3, status: UsbDeviceEndpointStatus) void {
        var chepr = self.chepr[ep_no];
        chepr.stattx ^= @backingInt(status);
        chepr.statrx = 0;
        chepr.dtogrx = false;
        chepr.dtogrx = false;
        self.chepr[ep_no] = chepr;
    }

    pub fn setEndpointRxStatus(self: *volatile Usb, ep_no: u3, status: UsbDeviceEndpointStatus) void {
        var chepr = self.chepr[ep_no];
        chepr.stattx = 0;
        chepr.statrx ^= @backingInt(status);
        chepr.dtogrx = false;
        chepr.dtogrx = false;
        self.chepr[ep_no] = chepr;
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

    pub fn devicePreinit(self: *volatile Usb, usb_clock_source: rcc.UsbfsSel) bool {
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
        return true;
    }

    pub fn deviceInit(self: *volatile Usb) void {
        self.daddr = UsbDaddr{.ef = true};
        self.bcdr = UsbBcdr{.dppu_dpd = true};
    }

    pub fn tx(self: *volatile Usb, ep_no: u3, data: []const u8) void {
        usb_device.copyToPMA32(pma_buffers[ep_no], data.ptr, data.len);
        self.setEndpointTxLength(ep_no, @truncate(data.len));
        self.setEndpointTxStatus(ep_no, .valid);
    }

    pub fn txZeroPacket(self: *volatile Usb, ep_no: u3) void {
        self.setEndpointTxLength(ep_no, 0);
        self.setEndpointTxStatus(ep_no, .valid);
    }
};

pub const usb: *volatile Usb = @ptrFromInt(USB_BASE);
pub var ep0_buffer: [usb_device.USB_FS_MAX_PACKET_SIZE]u8 align(4) = undefined;
pub var pma_buffers: [8][*]u32 = undefined;

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0xC00, @sizeOf(Usb));
}
