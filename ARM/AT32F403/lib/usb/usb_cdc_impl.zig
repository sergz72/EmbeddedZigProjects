const std = @import("std");
const usbfs = @import("usbfs");
const usb_device = @import("usb_device");
const usb_cdc = @import("usb_cdc");
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
        0x80 + usb_cdc.INTERRUPT_ENDPOINT => usbfs.usbfs.getEndpointTxStatus(usb_cdc.INTERRUPT_ENDPOINT),
        usb_cdc.DATA_IN_ENDPOINT => usbfs.usbfs.getEndpointRxStatus(usb_cdc.DATA_IN_ENDPOINT),
        0x80 + usb_cdc.DATA_OUT_ENDPOINT => usbfs.usbfs.getEndpointTxStatus(usb_cdc.DATA_OUT_ENDPOINT),
        else => .invalid_request
    };
}

fn haltEp(endpoint: u8, halt: bool) bool {
    switch (endpoint) {
        0x80 + usb_cdc.INTERRUPT_ENDPOINT => usbfs.usbfs.haltEndpointTx(usb_cdc.INTERRUPT_ENDPOINT, halt),
        usb_cdc.DATA_IN_ENDPOINT => usbfs.usbfs.haltEndpointRx(usb_cdc.DATA_IN_ENDPOINT, halt),
        0x80 + usb_cdc.DATA_OUT_ENDPOINT => usbfs.usbfs.haltEndpointTx(usb_cdc.DATA_OUT_ENDPOINT, halt),
        else => return false
    }
    return true;
}

fn epReset() void {
    usbfs.usbfs.epReset(usb_cdc.DATA_IN_ENDPOINT, .valid, .disabled, .bulk);
    usbfs.usbfs.epReset(usb_cdc.INTERRUPT_ENDPOINT, .disabled, .nak, .interrupt);
    usbfs.usbfs_buffer.setEndpointTxLength(usb_cdc.INTERRUPT_ENDPOINT, 0);
    usbfs.usbfs.epReset(usb_cdc.DATA_OUT_ENDPOINT, .disabled, .nak, .bulk);
    usbfs.usbfs_buffer.setEndpointTxLength(usb_cdc.DATA_OUT_ENDPOINT, 0);
}

pub fn init(callback: *const fn (data: []const u8) void, buffer_size: usize,
                allocator: std.mem.Allocator) error{OutOfMemory}!bool {
    try dma_sender_instance.init(buffer_size, allocator);
    rx_callback = callback;
    if (!usbfs.usbfs.devicePreinit()) {
        return false;
    }
    usbfs.usbfs_buffer.enableEndpoint(usb_cdc.INTERRUPT_ENDPOINT, false, true);
    usbfs.usbfs_buffer.enableEndpoint(usb_cdc.DATA_IN_ENDPOINT, true, false);
    usbfs.usbfs_buffer.enableEndpoint(usb_cdc.DATA_OUT_ENDPOINT, false, true);
    epReset();
    usbfs.usbfs.deviceInit();
    return true;
}

pub fn tx(data: []const u8) void {
    dma_sender_instance.send(data);
    dma_sender_instance.start();
}

fn usbDmaStart(data: []const u8) usize {
    if (data.len <= usb_device.USB_FS_MAX_PACKET_SIZE) {
        usbfs.usbfs.tx(usb_cdc.DATA_OUT_ENDPOINT, data);
        return data.len;
    } else {
        usbfs.usbfs.tx(usb_cdc.DATA_OUT_ENDPOINT, data[0..usb_device.USB_FS_MAX_PACKET_SIZE]);
        return usb_device.USB_FS_MAX_PACKET_SIZE;
    }
}

export fn USBFS_L_CAN1_RX0_IRQHandler() callconv(.c) void {
    @setRuntimeSafety(false);

    const istr = usbfs.usbfs.intsts;

    if (istr.tc) {
        const endpoint = istr.ept_num;
        if (endpoint < 8) {
            const chepr = usbfs.usbfs.ept[endpoint].ept;
            const chp: u16 = @bitCast(chepr);
            usbfs.usbfs.ept[endpoint].ept = @bitCast(chp & 0x0F0F);
            if (chepr.rxtc) {
                // OUT or SETUP packet received
                if (chepr.setuptc) {
                    usb_device.copyFromPMA16(@ptrCast(&usbfs.ep0_buffer), usbfs.pma_buffers_rx[0], 8);
                    const result = device.setup(@ptrCast(&usbfs.ep0_buffer));
                    if (result.tx) |tx_data| {
                        usbfs.usbfs.tx(usb_cdc.CONTROL_ENDPOINT, tx_data);
                    }
                    if (result.invalid_request) {
                        usbfs.usbfs.setEndpointTxStatus(usb_cdc.CONTROL_ENDPOINT, .stall);
                    }
                    usbfs.usbfs.setEndpointRxStatus(usb_cdc.CONTROL_ENDPOINT, .valid);
                } else {
                    switch (endpoint) {
                        usb_cdc.CONTROL_ENDPOINT => {
                            if (device.outPacket()) {
                                usbfs.usbfs.txZeroPacket(usb_cdc.CONTROL_ENDPOINT);
                            }
                        },
                        usb_cdc.DATA_IN_ENDPOINT => {
                            const rx_length = usbfs.usbfs_buffer.getEndpointRxLength(usb_cdc.DATA_IN_ENDPOINT);
                            usb_device.copyFromPMA16(@ptrCast(&in_buffer), usbfs.pma_buffers_rx[usb_cdc.DATA_IN_ENDPOINT], rx_length);
                            rx_callback(in_buffer[0..rx_length]);
                            usbfs.usbfs.setEndpointRxStatus(usb_cdc.DATA_IN_ENDPOINT, .valid);
                        },
                        else => {}
                    }
                }
            }
            if (chepr.txtc) {
                //IN packet sent
                switch (endpoint) {
                    usb_cdc.CONTROL_ENDPOINT => {
                        const result = device.inPacket();
                        if (result.tx) |tx_data| {
                            usbfs.usbfs.tx(usb_cdc.CONTROL_ENDPOINT, tx_data);
                        }
                        if (result.set_address != 0) {
                            usbfs.usbfs.setAddress(result.set_address);
                        }
                        usbfs.usbfs.setEndpointRxStatus(usb_cdc.CONTROL_ENDPOINT, .valid);
                    },
                    usb_cdc.DATA_OUT_ENDPOINT => {
                        dma_sender_instance.dmaDone();
                    },
                    else => {}
                }
            }
        }
        usbfs.usbfs.intsts.tc = false;
        return;
    }

    if (istr.sof) {
        usbfs.usbfs.intsts.sof = false;
        return;
    }
    if (istr.rst) {
        usbfs.usbfs.setAddress(0);
        usbfs.usbfs.ep0Reset();
        epReset();
        usbfs.usbfs.intsts.rst = false;
        return;
    }
    if (istr.sp) {
        device.suspendWakeup(true);
        usbfs.usbfs.intsts.sp = false;
        return;
    }
    if (istr.wk) {
        device.suspendWakeup(false);
        usbfs.usbfs.intsts.wk = false;
        return;
    }
    usbfs.usbfs.intsts = usbfs.UsbfsIntsts{};
}