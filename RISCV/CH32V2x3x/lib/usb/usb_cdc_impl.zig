const usbfs = @import("usbfs");
const usb_device = @import("usb_device");
const usb_cdc = @import("usb_cdc");
const system_timer = @import("system_timer");

const device_init = usb_cdc.buildDeviceInit(&endpointStatus, &haltEp);

var device: usb_device.Device = .{
    .init = &device_init
};

var cdc_tx_in_progress: bool = undefined;
pub var ep1_buffer: [usb_device.USB_FS_MAX_PACKET_SIZE]u8 align(4) = undefined;
pub var ep2_buffer: [usb_device.USB_FS_MAX_PACKET_SIZE]u8 align(4) = undefined;
pub var ep3_buffer: [usb_device.USB_FS_MAX_PACKET_SIZE]u8 align(4) = undefined;

fn endpointStatus(endpoint: u8) usb_device.EndpointStatus {
    return switch (endpoint) {
        0x81 => usbfs.usbfs.getEndpointTxStatus(1),
        0x02 => usbfs.usbfs.getEndpointRxStatus(2),
        0x83 => usbfs.usbfs.getEndpointTxStatus(3),
        else => .invalid_request
    };
}

fn haltEp(endpoint: u8, halt: bool) bool {
    switch (endpoint) {
        0x81 => usbfs.usbfs.haltEndpointTx(1, halt),
        0x02 => usbfs.usbfs.haltEndpointRx(2, halt),
        0x83 => usbfs.usbfs.haltEndpointTx(3, halt),
        else => return false
    }
    return true;
}

fn epReset() void {
    usbfs.usbfs.setEndpointRxStatus(2, .ack);
    usbfs.usbfs.setEndpointTxStatus(1, .nak);
    usbfs.usbfs.setEndpointTxLength(1, 0);
    usbfs.usbfs.setEndpointTxStatus(3, .nak);
    usbfs.usbfs.setEndpointTxLength(3, 0);
    cdc_tx_in_progress = false;
    //todo: CDC_Init()
}

pub fn init() bool {
    cdc_tx_in_progress = false;
    if (!usbfs.usbfs.devicePreinit()) {
        return false;
    }
    usbfs.usbfs.enableEndpoint(1, false, true);
    usbfs.usbfs.enableEndpoint(2, true, false);
    usbfs.usbfs.enableEndpoint(3, false, true);
    usbfs.usbfs.uep_dma[1] = @intFromPtr(&ep1_buffer);
    usbfs.usbfs.uep_dma[2] = @intFromPtr(&ep2_buffer);
    usbfs.usbfs.uep_dma[3] = @intFromPtr(&ep3_buffer);
    epReset();
    usbfs.usbfs.deviceInit();
    return true;
}

fn cdcRx(data: []u8) void {
    _ = data;
}

fn USBFSIRQHandler() callconv(.c) void {
    @setRuntimeSafety(false);
    const intflag = usbfs.usbfs.int_fg;
    const intst = usbfs.usbfs.int_st;

    if (intflag.transfer) {
        switch (intst.token) {
            .in => {
                switch (intst.h_res_or_endp) {
                    0 => {
                        const result = device.inPacket();
                        if (result.r_tog_and_ack) {
                            usbfs.usbfs.rTogAndAck(0);
                        }
                        if (result.tx) |tx| {
                            @memcpy(&usbfs.ep0_buffer, tx);
                            usbfs.usbfs.tTogAndSetTxLen(0, @truncate(tx.len));
                        }
                        if (result.set_address != 0)
                            usbfs.usbfs.setAddress(result.set_address);
                    },
                    // interrupt endpoint
                    1 => {
                        usbfs.usbfs.tTogAndNak(1);
                    },
                    // data endpoint
                    3 => {
                        usbfs.usbfs.tTogAndNak(3);
                        cdc_tx_in_progress = false;
                    },
                    else => {}
                }
            },
            .out => {
                switch (intst.h_res_or_endp) {
                    0 => {
                        if (device.outPacket()) {
                            usbfs.usbfs.tTogAndSendZeroPacket(0);
                        }
                    },
                    2 => {
                        usbfs.usbfs.rTog(2);
                        cdcRx(ep2_buffer[0..usbfs.usbfs.rx_len]);
                    },
                    else => {}
                }
            },
            .setup => {
                const ep = &usbfs.usbfs.uep_ctrl[0];
                ep.tx_ctrl = .{.tog = true, .res = .nak};
                ep.rx_ctrl = .{.tog = true, .res = .nak};
                const setup_packet: *const usb_device.SetupPacket = @ptrCast(&usbfs.ep0_buffer);
                const result = device.setup(setup_packet);
                if (result.tx) |tx| {
                    @memcpy(&usbfs.ep0_buffer, tx);
                    usbfs.usbfs.tTogAndSetTxLen(0, @truncate(tx.len));
                }
                else if (result.invalid_request) {
                    ep.tx_ctrl = .{.tog = true, .res = .stall};
                    ep.rx_ctrl = .{.tog = true, .res = .stall};
                }
                else if (result.receive_start) {
                    ep.rx_ctrl = .{.tog = true, .res = .ack};
                }
            },
            else => {}
        }
        usbfs.usbfs.int_fg = .{.transfer = true};
        return;
    }

    if (intflag.bus_rst_or_detect) {
        usbfs.usbfs.setAddress(0);
        usbfs.usbfs.ep0Reset();
        epReset();
        usbfs.usbfs.int_fg = .{.bus_rst_or_detect = true};
        return;
    }

    if (intflag.suspend_wakeup) {
        usbfs.usbfs.int_fg = .{.suspend_wakeup = true};
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
