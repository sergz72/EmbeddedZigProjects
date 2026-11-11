const std = @import("std");
const usb = @import("usb");
const usb_device = @import("usb_device");
const usb_cdc = @import("usb_cdc");
const rcc = @import("rcc");
const dma_sender = @import("dma_sender");
const system_timer = @import("system_timer");

const device_init = usb_cdc.buildDeviceInit(&endpointStatus, &haltEp);

var device: usb_device.Device = .{
    .init = &device_init
};

var rx_callback: *const fn (data: []const u8) void = undefined;

pub var in_buffer: [usb_device.USB_FS_MAX_PACKET_SIZE]u8 align(4) = undefined;
var dma_sender_instance = dma_sender.DmaSender {
    .dma_start = &usbDmaStart,
    .delayms = system_timer.delayms,
};

fn endpointStatus(endpoint: u8) usb_device.EndpointStatus {
    return switch (endpoint) {
        0x80 + usb_cdc.INTERRUPT_ENDPOINT => usb.usb.getEndpointTxStatus(usb_cdc.INTERRUPT_ENDPOINT),
        usb_cdc.DATA_IN_ENDPOINT => usb.usb.getEndpointRxStatus(usb_cdc.DATA_IN_ENDPOINT),
        0x80 + usb_cdc.DATA_OUT_ENDPOINT => usb.usb.getEndpointTxStatus(usb_cdc.DATA_OUT_ENDPOINT),
        else => .invalid_request
    };
}

fn haltEp(endpoint: u8, halt: bool) bool {
    switch (endpoint) {
        0x80 + usb_cdc.INTERRUPT_ENDPOINT => usb.usb.haltEndpointTx(usb_cdc.INTERRUPT_ENDPOINT, halt),
        usb_cdc.DATA_IN_ENDPOINT => usb.usb.haltEndpointRx(usb_cdc.DATA_IN_ENDPOINT, halt),
        0x80 + usb_cdc.DATA_OUT_ENDPOINT => usb.usb.haltEndpointTx(usb_cdc.DATA_OUT_ENDPOINT, halt),
        else => return false
    }
    return true;
}

fn epReset() void {
    usb.usb.epReset(usb_cdc.DATA_IN_ENDPOINT, .valid, .disabled, .bulk);
    usb.usb.epReset(usb_cdc.INTERRUPT_ENDPOINT, .disabled, .nak, .interrupt);
    usb.usb.setEndpointTxLength(usb_cdc.INTERRUPT_ENDPOINT, 0);
    usb.usb.epReset(usb_cdc.DATA_OUT_ENDPOINT, .disabled, .nak, .bulk);
    usb.usb.setEndpointTxLength(usb_cdc.DATA_OUT_ENDPOINT, 0);
}

pub fn init(usb_clock_source: rcc.UsbfsSel, callback: *const fn (data: []const u8) void, buffer_size: usize,
                allocator: std.mem.Allocator) error{OutOfMemory}!void {
    try dma_sender_instance.init(buffer_size, allocator);
    rx_callback = callback;
    usb.usb.devicePreinit(usb_clock_source);
    usb.usb.enableEndpoint(usb_cdc.INTERRUPT_ENDPOINT, false, true);
    usb.usb.enableEndpoint(usb_cdc.DATA_IN_ENDPOINT, true, false);
    usb.usb.enableEndpoint(usb_cdc.DATA_OUT_ENDPOINT, false, true);
    epReset();
    usb.usb.deviceInit();
}

pub fn tx(data: []const u8) void {
    dma_sender_instance.send(data);
    dma_sender_instance.start();
}

pub fn txChar(c: u8) void {
    dma_sender_instance.sendChar(c);
    dma_sender_instance.start();
}

pub fn flush() void {
    dma_sender_instance.start();
}

fn usbDmaStart(data: []const u8) usize {
    if (data.len <= usb_device.USB_FS_MAX_PACKET_SIZE) {
        usb.usb.tx(usb_cdc.DATA_OUT_ENDPOINT, data);
        return data.len;
    } else {
        usb.usb.tx(usb_cdc.DATA_OUT_ENDPOINT, data[0..usb_device.USB_FS_MAX_PACKET_SIZE]);
        return usb_device.USB_FS_MAX_PACKET_SIZE;
    }
}

export fn USB_DRD_FS_IRQHandler() callconv(.c) void {
    @setRuntimeSafety(false);

    const istr = usb.usb.istr;

    if (istr.ctr) {
        const endpoint = istr.idn;
        if (endpoint < 8) {
            const chepr = usb.usb.chepr[endpoint];
            const chp: u32 = @bitCast(chepr);
            usb.usb.chepr[endpoint] = @bitCast(chp & 0xFFFF_0F0F);
            if (chepr.vtrx) {
                // OUT or SETUP packet received
                if (chepr.setup) {
                    usb_device.copyFromPMA32(@ptrCast(&usb.ep0_buffer), usb.pma_buffers_rx[0], 8);
                    const result = device.setup(@ptrCast(&usb.ep0_buffer));
                    if (result.tx) |tx_data| {
                        usb.usb.tx(usb_cdc.CONTROL_ENDPOINT, tx_data);
                    }
                    if (result.invalid_request) {
                        usb.usb.setEndpointTxStatus(usb_cdc.CONTROL_ENDPOINT, .stall);
                    }
                    usb.usb.setEndpointRxStatus(usb_cdc.CONTROL_ENDPOINT, .valid);
                } else {
                    switch (endpoint) {
                        usb_cdc.CONTROL_ENDPOINT => {
                            if (device.outPacket()) {
                                usb.usb.txZeroPacket(usb_cdc.CONTROL_ENDPOINT);
                            }
                        },
                        usb_cdc.DATA_IN_ENDPOINT => {
                            const rx_length = usb.usb.getEndpointRxLength(usb_cdc.DATA_IN_ENDPOINT);
                            usb_device.copyFromPMA32(@ptrCast(&in_buffer), usb.pma_buffers_rx[usb_cdc.DATA_IN_ENDPOINT], rx_length);
                            rx_callback(in_buffer[0..rx_length]);
                            usb.usb.setEndpointRxStatus(usb_cdc.DATA_IN_ENDPOINT, .valid);
                        },
                        else => {}
                    }
                }
            }
            if (chepr.vttx) {
                //IN packet sent
                switch (endpoint) {
                    usb_cdc.CONTROL_ENDPOINT => {
                        const result = device.inPacket();
                        if (result.tx) |tx_data| {
                            usb.usb.tx(usb_cdc.CONTROL_ENDPOINT, tx_data);
                        }
                        if (result.set_address != 0) {
                            usb.usb.setAddress(result.set_address);
                        }
                        usb.usb.setEndpointRxStatus(usb_cdc.CONTROL_ENDPOINT, .valid);
                    },
                    usb_cdc.DATA_OUT_ENDPOINT => {
                        dma_sender_instance.dmaDone();
                    },
                    else => {}
                }
            }
        }
        usb.usb.istr.ctr = false;
        return;
    }

    if (istr.sof) {
        usb.usb.istr.sof = false;
        return;
    }
    if (istr.rst_dcon) {
        usb.usb.setAddress(0);
        usb.usb.ep0Reset();
        epReset();
        usb.usb.istr.rst_dcon = false;
        return;
    }
    if (istr.susp) {
        device.suspendWakeup(true);
        usb.usb.istr.susp = false;
        return;
    }
    if (istr.wkup) {
        device.suspendWakeup(false);
        usb.usb.istr.wkup = false;
        return;
    }
    usb.usb.istr = usb.UsbIstr{};
}