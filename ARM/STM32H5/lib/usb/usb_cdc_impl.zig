const usb = @import("usb");
const usb_device = @import("usb_device");
const usb_cdc = @import("usb_cdc");
const rcc = @import("rcc");

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
        0x81 => usb.usb.getEndpointTxStatus(1),
        0x02 => usb.usb.getEndpointRxStatus(2),
        0x83 => usb.usb.getEndpointTxStatus(3),
        else => .invalid_request
    };
}

fn haltEp(endpoint: u8, halt: bool) bool {
    switch (endpoint) {
        0x81 => usb.usb.haltEndpointTx(1, halt),
        0x02 => usb.usb.haltEndpointRx(2, halt),
        0x83 => usb.usb.haltEndpointTx(3, halt),
        else => return false
    }
    return true;
}

fn epReset() void {
    usb.usb.setEndpointRxStatus(2, .valid);
    usb.usb.setEndpointTxStatus(1, .nak);
    usb.usb.setEndpointTxLength(1, 0);
    usb.usb.setEndpointTxStatus(3, .nak);
    usb.usb.setEndpointTxLength(3, 0);
    cdc_tx_in_progress = false;
    //todo: CDC_Init()
}

pub fn init(usb_clock_source: rcc.UsbfsSel) bool {
    cdc_tx_in_progress = false;
    if (!usb.usb.devicePreinit(usb_clock_source)) {
        return false;
    }
    usb.usb.enableEndpoint(1, false, true);
    usb.usb.enableEndpoint(2, true, false);
    usb.usb.enableEndpoint(3, false, true);
    epReset();
    usb.usb.deviceInit();
    return true;
}

fn cdcRx(data: []u8) void {
    _ = data;
}

export fn USB_DRD_FS_IRQHandler() callconv(.c) void {
    @setRuntimeSafety(false);

    const istr = usb.usb.istr;

    if (istr.ctr) {
        const endpoint = istr.idn;
        if (endpoint < 8) {
            const chepr = &usb.usb.chepr[endpoint];
            if (chepr.vtrx) {
                // OUT or SETUP packet received
                chepr.vtrx = false;
                if (chepr.setup) {
                    usb_device.copyFromPMA32(@ptrCast(&usb.ep0_buffer), usb.pma_buffers[endpoint], 8);
                    const result = device.setup(@ptrCast(&usb.ep0_buffer));
                    if (result.tx) |tx| {
                        usb.usb.tx(0, tx);
                    }
                    else if (result.invalid_request) {
                        usb.usb.setEndpointTxStatus(0, .stall);
                    }
                } else {
                    switch (endpoint) {
                        0 => {
                            if (device.outPacket()) {
                                usb.usb.txZeroPacket(0);
                            }
                        },
                        2 => {

                        },
                        else => {}
                    }
                }
            }
            if (chepr.vttx) {
                //IN packet sent
                chepr.vttx = false;
                switch (endpoint) {
                    0 => {
                        const result = device.inPacket();
                        if (result.tx) |tx| {
                            usb.usb.tx(0, tx);
                        }
                        if (result.start_rx) {
                            usb.usb.setEndpointRxStatus(0, .valid);
                        }
                        if (result.set_address != 0)
                            usb.usb.setAddress(result.set_address);
                    },
                    3 => {
                        cdc_tx_in_progress = false;
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