const std = @import("std");
const usbfs = @import("usbfs");
const usb_device = @import("usb_device");
const usb_cdc = @import("usb_cdc");
const system_timer = @import("system_timer");
const dma_sender = @import("dma_sender");

const device_init = usb_cdc.buildDeviceInit(&endpointStatus, &haltEp);

var device = usb_device.Device{
    .init = &device_init
};

var rx_callback: *const fn (data: []const u8) void = undefined;

var dma_sender_instance = dma_sender.DmaSender {
    .dma_start = &usbDmaStart,
    .delayms = system_timer.delayms,
};

pub var ep1_buffer: [usb_device.USB_FS_MAX_PACKET_SIZE]u8 align(4) = undefined;
pub var ep2_buffer: [usb_device.USB_FS_MAX_PACKET_SIZE]u8 align(4) = undefined;
pub var ep3_buffer: [usb_device.USB_FS_MAX_PACKET_SIZE]u8 align(4) = undefined;

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
    usbfs.usbfs.setEndpointRxAuto(usb_cdc.DATA_IN_ENDPOINT, .ack);
    usbfs.usbfs.setEndpointTxAuto(usb_cdc.INTERRUPT_ENDPOINT, .nak);
    usbfs.usbfs.setEndpointTxLength(usb_cdc.INTERRUPT_ENDPOINT, 0);
    usbfs.usbfs.setEndpointTxAuto(usb_cdc.DATA_OUT_ENDPOINT, .nak);
    usbfs.usbfs.setEndpointTxLength(usb_cdc.DATA_OUT_ENDPOINT, 0);
}

pub fn init(callback: *const fn (data: []const u8) void, buffer_size: usize, allocator: std.mem.Allocator) error{OutOfMemory}!bool {
    try dma_sender_instance.init(buffer_size, allocator);
    if (!usbfs.usbfs.devicePreinit()) {
        return false;
    }
    rx_callback = callback;
    usbfs.usbfs.enableEndpoint(usb_cdc.INTERRUPT_ENDPOINT, false, true);
    usbfs.usbfs.enableEndpoint(usb_cdc.DATA_IN_ENDPOINT, true, false);
    usbfs.usbfs.enableEndpoint(usb_cdc.DATA_OUT_ENDPOINT, false, true);
    usbfs.usbfs.uep_dma[usb_cdc.INTERRUPT_ENDPOINT] = @intFromPtr(&ep1_buffer);
    usbfs.usbfs.uep_dma[usb_cdc.DATA_IN_ENDPOINT] = @intFromPtr(&ep2_buffer);
    usbfs.usbfs.uep_dma[usb_cdc.DATA_OUT_ENDPOINT] = @intFromPtr(&ep3_buffer);
    epReset();
    usbfs.usbfs.deviceInit();
    return true;
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
    @setRuntimeSafety(false);
    if (data.len <= usb_device.USB_FS_MAX_PACKET_SIZE) {
        @memcpy(ep3_buffer[0..data.len], data);
        usbfs.usbfs.setTxLenAndAck(usb_cdc.DATA_OUT_ENDPOINT, @truncate(data.len));
        return data.len;
    } else {
        @memcpy(&ep3_buffer, data[0..usb_device.USB_FS_MAX_PACKET_SIZE]);
        usbfs.usbfs.setTxLenAndAck(usb_cdc.DATA_OUT_ENDPOINT, usb_device.USB_FS_MAX_PACKET_SIZE);
        return usb_device.USB_FS_MAX_PACKET_SIZE;
    }
}

fn USBFSIRQHandler() callconv(.c) void {
    @setRuntimeSafety(false);
    const intflag = usbfs.usbfs.int_fg;
    const intst = usbfs.usbfs.int_st;

    if (intflag.transfer) {
        switch (intst.token) {
            .in => {
                switch (intst.h_res_or_endp) {
                    usb_cdc.CONTROL_ENDPOINT => {
                        const result = device.inPacket();
                        if (result.tx) |tx_data| {
                            @memcpy(&usbfs.ep0_buffer, tx_data);
                            usbfs.usbfs.tTogAndSetTxLen(usb_cdc.CONTROL_ENDPOINT, @truncate(tx_data.len));
                        }
                        if (result.set_address != 0) {
                            usbfs.usbfs.setAddress(result.set_address);
                        }
                        usbfs.usbfs.rTogAndAck(usb_cdc.CONTROL_ENDPOINT);
                    },
                    // data endpoint
                    usb_cdc.DATA_OUT_ENDPOINT => {
                        usbfs.usbfs.setEndpointTxStatus(usb_cdc.DATA_OUT_ENDPOINT, .nak);
                        dma_sender_instance.dmaDone();
                    },
                    else => {}
                }
            },
            .out => {
                switch (intst.h_res_or_endp) {
                    usb_cdc.CONTROL_ENDPOINT => {
                        if (device.outPacket()) {
                            usbfs.usbfs.tTogAndSendZeroPacket(usb_cdc.CONTROL_ENDPOINT);
                        }
                    },
                    usb_cdc.DATA_IN_ENDPOINT => {
                        usbfs.usbfs.setEndpointRxStatus(usb_cdc.DATA_IN_ENDPOINT, .nak);
                        rx_callback(ep2_buffer[0..usbfs.usbfs.rx_len]);
                        usbfs.usbfs.setEndpointRxStatus(usb_cdc.DATA_IN_ENDPOINT, .ack);
                    },
                    else => {}
                }
            },
            .setup => {
                const ep = &usbfs.usbfs.uep_ctrl[usb_cdc.CONTROL_ENDPOINT];
                ep.tx_ctrl = usbfs.UsbFsUepTxRxCtrl{.tog = true, .res = .nak};
                ep.rx_ctrl = usbfs.UsbFsUepTxRxCtrl{.tog = true, .res = .nak};
                const setup_packet: *const usb_device.SetupPacket = @ptrCast(&usbfs.ep0_buffer);
                const result = device.setup(setup_packet);
                if (result.tx) |tx_data| {
                    @memcpy(&usbfs.ep0_buffer, tx_data);
                    ep.t_len = @truncate(tx_data.len);
                    ep.tx_ctrl = usbfs.UsbFsUepTxRxCtrl{.tog = true, .res = .ack};
                }
                else if (result.invalid_request) {
                    ep.tx_ctrl = usbfs.UsbFsUepTxRxCtrl{.tog = true, .res = .stall};
                }
                ep.rx_ctrl = usbfs.UsbFsUepTxRxCtrl{.tog = true, .res = .ack};
            },
            else => {}
        }
        usbfs.usbfs.int_fg = usbfs.UsbFsIntFg{.transfer = true};
        return;
    }

    if (intflag.bus_rst_or_detect) {
        usbfs.usbfs.setAddress(0);
        usbfs.usbfs.ep0Reset();
        epReset();
        usbfs.usbfs.int_fg = usbfs.UsbFsIntFg{.bus_rst_or_detect = true};
        return;
    }

    if (intflag.suspend_wakeup) {
        usbfs.usbfs.int_fg = usbfs.UsbFsIntFg{.suspend_wakeup = true};
        system_timer.delayLoopus(10);
        device.suspendWakeup(usbfs.usbfs.mis_st.suspended);
        return;
    }

    usbfs.usbfs.int_fg = @bitCast(intflag);
}

export fn USBFS_IRQHandler() callconv(.naked) void {
    asm volatile(
        \\ call %[handler_fn]
        \\ mret
        :
        : [handler_fn] "i" (&USBFSIRQHandler)
    );
}
