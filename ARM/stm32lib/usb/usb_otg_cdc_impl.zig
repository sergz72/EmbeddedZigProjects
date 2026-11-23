const std = @import("std");
const usb_otg_global = @import("usb_otg_global");
const usb_otg_device = @import("usb_otg_device");
const usb_device = @import("usb_device");
const usb_cdc = @import("usb_cdc");
const rcc = @import("rcc");
const dma_sender = @import("dma_sender");
const system_timer = @import("system_timer");
const cpu = @import("cpu");

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
        0x80 + usb_cdc.INTERRUPT_ENDPOINT => usb_otg_global.otg_fs_global.getEndpointTxStatus(usb_cdc.INTERRUPT_ENDPOINT),
        usb_cdc.DATA_IN_ENDPOINT => usb_otg_global.otg_fs_global.getEndpointRxStatus(usb_cdc.DATA_IN_ENDPOINT),
        0x80 + usb_cdc.DATA_OUT_ENDPOINT => usb_otg_global.otg_fs_global.getEndpointTxStatus(usb_cdc.DATA_OUT_ENDPOINT),
        else => .invalid_request
    };
}

fn haltEp(endpoint: u8, halt: bool) bool {
    switch (endpoint) {
        0x80 + usb_cdc.INTERRUPT_ENDPOINT => usb_otg_global.otg_fs_global.haltEndpointTx(usb_cdc.INTERRUPT_ENDPOINT, halt),
        usb_cdc.DATA_IN_ENDPOINT => usb_otg_global.otg_fs_global.haltEndpointRx(usb_cdc.DATA_IN_ENDPOINT, halt),
        0x80 + usb_cdc.DATA_OUT_ENDPOINT => usb_otg_global.otg_fs_global.haltEndpointTx(usb_cdc.DATA_OUT_ENDPOINT, halt),
        else => return false
    }
    return true;
}

fn epReset() void {
    usb_otg_global.otg_fs_global.epReset(usb_cdc.DATA_IN_ENDPOINT, .valid, .disabled, .bulk);
    usb_otg_global.otg_fs_global.epReset(usb_cdc.INTERRUPT_ENDPOINT, .disabled, .nak, .interrupt);
    usb_otg_global.otg_fs_global.setEndpointTxLength(usb_cdc.INTERRUPT_ENDPOINT, 0);
    usb_otg_global.otg_fs_global.epReset(usb_cdc.DATA_OUT_ENDPOINT, .disabled, .nak, .bulk);
    usb_otg_global.otg_fs_global.setEndpointTxLength(usb_cdc.DATA_OUT_ENDPOINT, 0);
}

pub fn init(usb_clock_source: rcc.UsbfsSel, callback: *const fn (data: []const u8) void, buffer_size: usize,
                allocator: std.mem.Allocator) error{OutOfMemory}!void {
    try dma_sender_instance.init(buffer_size, allocator);
    rx_callback = callback;
    usb_otg_global.otg_fs_global.devicePreinit(usb_clock_source);
    usb_otg_global.otg_fs_global.enableEndpoint(usb_cdc.INTERRUPT_ENDPOINT, false, true);
    usb_otg_global.otg_fs_global.enableEndpoint(usb_cdc.DATA_IN_ENDPOINT, true, false);
    usb_otg_global.otg_fs_global.enableEndpoint(usb_cdc.DATA_OUT_ENDPOINT, false, true);
    epReset();
    usb_otg_global.otg_fs_global.deviceInit();
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
        usb_otg_global.otg_fs_global.tx(usb_cdc.DATA_OUT_ENDPOINT, data);
        return data.len;
    } else {
        usb_otg_global.otg_fs_global.tx(usb_cdc.DATA_OUT_ENDPOINT, data[0..usb_device.USB_FS_MAX_PACKET_SIZE]);
        return usb_device.USB_FS_MAX_PACKET_SIZE;
    }
}

fn OEPIntHandler() void {
    var interrupts = usb_otg_device.otg_fs_device.getAllEpInterrupts().oepint;
    var ep_no: u4 = 0;
    const buffer = &usb_otg_global.xfer_buffer[ep_no];
    while (interrupts != 0) : (ep_no += 1) {
        if ((interrupts & 1) != 0) {
            const ep = usb_otg_device.otg_fs_device.getOutEndpoint(ep_no);
            const int = ep.int;
            if (int.xfrc) {
                ep.int = usb_otg_device.UsbDoepint{.xfrc = true};
                switch (ep_no) {
                    usb_cdc.CONTROL_ENDPOINT => {
                        if (device.outPacket()) {
                            usb_otg_device.otg_fs_device.txZeroPacket(usb_cdc.CONTROL_ENDPOINT);
                        }
                    },
                    usb_cdc.DATA_IN_ENDPOINT => {
                        rx_callback(buffer.buffer[0..buffer.length]);
                        usb_otg_global.otg_fs_global.setEndpointRxStatus(usb_cdc.DATA_IN_ENDPOINT, .valid);
                    },
                    else => {},
                }
            }
            if (int.stup) {
                ep.int = usb_otg_device.UsbDoepint{.stup = true};
                const result = device.setup(@ptrCast(&buffer.buffer));
                if (result.tx) |tx_data| {
                    usb_otg_global.otg_fs_global.tx(usb_cdc.CONTROL_ENDPOINT, tx_data);
                }
                if (result.invalid_request) {
                    usb_otg_global.otg_fs_global.setEndpointTxStatus(usb_cdc.CONTROL_ENDPOINT, .stall);
                }
                usb_otg_global.otg_fs_global.setEndpointRxStatus(usb_cdc.CONTROL_ENDPOINT, .valid);
            }
            if (int.otepdis) {
                ep.int = usb_otg_device.UsbDoepint{.otepdis = true};
            }
            if (int.otepspr) {
                ep.int = usb_otg_device.UsbDoepint{.otepspr = true};
            }
        }
        interrupts >>= 1;
        ep_no += 1;
    }
}

fn IEPIntHandler() void {
    var interrupts = usb_otg_device.otg_fs_device.getAllEpInterrupts().iepint;
    var ep_no: u4 = 0;
    while (interrupts != 0) : (ep_no += 1) {
        if ((interrupts & 1) != 0) {
            const ep = usb_otg_device.otg_fs_device.getInEndpoint(ep_no);
            const int = ep.int;
            if (int.xfrc) {
                ep.int = usb_otg_device.UsbDiepint{.xfrc = true};
                const fifoemptymsk = @as(u32, 1) << ep_no;
                usb_otg_device.otg_fs_device.clearFifoEmptyMask(fifoemptymsk);
                switch (ep_no) {
                    usb_cdc.CONTROL_ENDPOINT => {
                        const result = device.inPacket();
                        if (result.tx) |tx_data| {
                            usb_otg_global.otg_fs_global.tx(usb_cdc.CONTROL_ENDPOINT, tx_data);
                        }
                        if (result.set_address != 0) {
                            usb_otg_global.otg_fs_global.setAddress(result.set_address);
                        }
                        usb_otg_global.otg_fs_global.setEndpointRxStatus(usb_cdc.CONTROL_ENDPOINT, .valid);
                    },
                    usb_cdc.DATA_OUT_ENDPOINT => {
                        dma_sender_instance.dmaDone();
                    },
                    else => {}
                }
            }
        }
        interrupts >>= 1;
    }
}

fn USBRSTHandler() void {
    //todo: USB reset handling
}

fn USBActivateSetup() void {
    //todo: USB activate setup handling
}

export fn OTG_FS_IRQHandler() callconv(.c) void {
    @setRuntimeSafety(false);
    const status = usb_otg_global.otg_fs_global.getInterruptStatus();
    if (@backingInt(status) == 0) return;
    if (status.mmis) {
        usb_otg_global.otg_fs_global.gintsts = usb_otg_global.UsbGint{.mmis = true};
    }
    if (status.oepint) {
        OEPIntHandler();
    }
    if (status.iepint) {
        IEPIntHandler();
    }
    if (status.wkupint) {
        usb_otg_device.otg_fs_device.removeWakeupSignaling();
        //todo: resume callback
        usb_otg_global.otg_fs_global.gintsts = usb_otg_global.UsbGint{.wkupint = true};
    }
    if (status.usbsusp) {
        if (usb_otg_device.otg_fs_device.suspended()) {
            //todo: suspend callback
        }
        usb_otg_global.otg_fs_global.gintsts = usb_otg_global.UsbGint{.usbsusp = true};
    }
    if (cpu.family != .F4 and status.lpmint) {
        //todo: LPM interrupt handling
        usb_otg_global.otg_fs_global.gintsts = usb_otg_global.UsbGint{.lpmint = true};
    }
    if (status.usbrst) {
        USBRSTHandler();
    }
    if (status.enumdne) {
        USBActivateSetup();
        usb_otg_global.otg_fs_global.setTrdtTimeFs();
        //todo: reset callback
        usb_otg_global.otg_fs_global.gintsts = usb_otg_global.UsbGint{.enumdne = true};
    }
    if (status.rxflvl) {
        usb_otg_global.otg_fs_global.gintmsk.rxflvl = false;
        usb_otg_global.otg_fs_global.readPacket();
        usb_otg_global.otg_fs_global.gintmsk.rxflvl = true;
    }
    if (status.sof) {
        //todo: SOF callback
        usb_otg_global.otg_fs_global.gintsts = usb_otg_global.UsbGint{.sof = true};
    }
    if (status.iisoixfr) {
        //todo: incomplete isochronous IN transfer callback
        usb_otg_global.otg_fs_global.gintsts = usb_otg_global.UsbGint{.iisoixfr = true};
    }
    if (status.ipfxr_incompisoout) {
        //todo: incomplete isochronous OUT transfer callback
        usb_otg_global.otg_fs_global.gintsts = usb_otg_global.UsbGint{.ipfxr_incompisoout = true};
    }
    if (status.srqint) {
        //todo: connect callback
        usb_otg_global.otg_fs_global.gintsts = usb_otg_global.UsbGint{.srqint = true};
    }
    if (status.otgnt) {
        const temp = usb_otg_global.otg_fs_global.gotgint;
        if (temp.sedet) {
            //todo: disconnect callback
        }
        usb_otg_global.otg_fs_global.gotgint = temp;
    }
}
