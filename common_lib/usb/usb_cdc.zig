const usb_device = @import("usb_device");

pub const ComConfig = extern struct {
    baudrate: u32 = 115200,
    stopbit: u8 = 0,
    parity: u8 = 0,
    databit: u8 = 8,
    rx_timeout: u8 = 30
};

const manufacturer = usb_device.buildStringDescriptor("test inc");
const product = usb_device.buildStringDescriptor("test product");
const serial_number = usb_device.buildStringDescriptor("12345");
const descriptor = usb_device.buildDeviceDescriptor(.{
    .device_class = .cdc,
    .vendor_id = 0x1A86,
    .product_id = 0xFE0C
});
const INTERFACE_CONTROL = 0;
const INTERFACE_DATA = 1;
const config = usb_device.buildConfigDescriptor(.{
    .num_interfaces = 2,
    .self_powered = false,
    .remote_wakeup = false,
    .max_power_ma = 510
}, &.{
    //cdc control interface
    usb_device.buildInterfaceDescriptor(.{
        .number = INTERFACE_CONTROL,
        .num_endpoints = 1,
        .class = .cdc,
        .subclass = 2,
        .protocol = 1
    }),
    usb_device.buildClassInterfaceDescriptor(0, 0x10, 1),
    usb_device.buildClassInterfaceDescriptor(1, 0, INTERFACE_DATA),
    usb_device.buildClassInterfaceDescriptor4(2, 2),
    usb_device.buildClassInterfaceDescriptor(6, INTERFACE_CONTROL, INTERFACE_DATA),
    // control endpoint
    usb_device.buildEndpointDescriptor(.{
        .endpoint_number = 1,
        .in = true,
        .attributes = .{.transfer_type = .interrupt},
        .max_packet_size = usb_device.USB_FS_MAX_PACKET_SIZE,
        .interval = 255
    }),
    //cdc data interface
    usb_device.buildInterfaceDescriptor(.{
        .number = INTERFACE_DATA,
        .num_endpoints = 2,
        .class = .cdc_data,
        .subclass = 0,
        .protocol = 0
    }),
    // out endpoint
    usb_device.buildEndpointDescriptor(.{
        .endpoint_number = 2,
        .in = false,
        .attributes = .{.transfer_type = .bulk},
        .max_packet_size = usb_device.USB_FS_MAX_PACKET_SIZE
    }),
    // in endpoint
    usb_device.buildEndpointDescriptor(.{
        .endpoint_number = 3,
        .in = true,
        .attributes = .{.transfer_type = .bulk},
        .max_packet_size = usb_device.USB_FS_MAX_PACKET_SIZE
    })
});

pub fn buildDeviceInit(endpoint_status: *const fn (u8) usb_device.EndpointStatus,
                        halt_ep: *const fn (u8, bool) bool) usb_device.DeviceInit {
    comptime {
        return .{
            .descriptor = &descriptor,
            .config = config,
            .lang = .{0x04, 0x03, 0x09, 0x04},
            .manufacturer = &manufacturer,
            .product = &product,
            .serial_number = &serial_number,
            .max_transfer_size = usb_device.USB_FS_MAX_PACKET_SIZE,
            .endpoint_status = endpoint_status,
            .halt_ep = halt_ep
        };
    }
}
