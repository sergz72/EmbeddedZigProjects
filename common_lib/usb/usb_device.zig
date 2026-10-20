const std = @import("std");
const builtin = @import("builtin");

pub const USB_FS_MAX_PACKET_SIZE = 64;
pub const USB_HS_MAX_PACKET_SIZE = 1024;

pub const Request = enum(u8) {
  get_status = 0,
  clear_feature = 1,
  set_feature = 3,
  set_address = 5,
  get_descriptor = 6,
  set_descriptor = 7,
  get_configuration = 8,
  set_configuration = 9,
  get_interface = 10,
  set_interface = 11,
  sync_frame = 12
};

pub const DeviceClass = enum(u8) {
    unspecified = 0,
    audio = 1,
    cdc = 2,
    hid = 3,
    pid = 5,
    image = 6,
    printer = 7,
    mass_storage = 8,
    hub = 9,
    cdc_data = 10,
    smart_card = 11,
    security = 13,
    video = 14,
    healthcare = 15,
    diagnostic = 0xDC,
    wireless = 0xE0,
    misc = 0xEF,
    application_specific = 0xFE,
    vendor_specific = 0xFF
};

pub const DescriptorType = enum(u8) {
    device = 1,
    configuration = 2,
    string = 3,
    interface = 4,
    endpoint = 5,
    device_qualifier = 6,
    other_speed_configuration = 7,
    interface_association = 11,
    bos = 15,
    cs_interface = 0x24
};

pub const RequestRecipient = enum(u5) {
    device = 0,
    interface = 1,
    endpoint = 2,
    other = 3
};

pub const RequestTypeType = enum(u2) {
    standard = 0,
    class = 1,
    vendor = 2,
    reserved = 3
};

pub const RequestType = packed struct(u8) {
    recipient: RequestRecipient,
    type: RequestTypeType,
    direction: bool
};

pub const SetupRequestValues = extern struct {
    lo: u8,
    hi: u8
};

pub const SetupRequestValue = extern union {
    value16: u16,
    value: SetupRequestValues
};

pub const SetupPacket = extern struct {
    request_type: RequestType,
    request: u8,
    value: SetupRequestValue,
    index: u16,
    length: u16
};

pub const SetupResult = struct {
    tx: ?[]const u8 = null,
    invalid_request: bool = false,
    receive_start: bool = false
};

pub const InResult = struct {
    tx: ?[]const u8 = null,
    r_tog_and_ack: bool = false,
    set_address: u7 = 0
};

pub const DeviceDescriptor = struct {
    device_class: DeviceClass,
    device_subclass: u8 = 0,
    device_protocol: u8 = 0,
    max_packet_size: u8 = USB_FS_MAX_PACKET_SIZE,
    vendor_id: u16,
    product_id: u16,
    release_no_lo: u8 = 0,
    release_no_hi: u8 = 1
};

pub const EndpointStatus = enum {
    ok,
    stall,
    invalid_request
};

pub const DeviceInit = struct {
    descriptor: []const u8,
    config: []const u8,
    lang: [4]u8,
    manufacturer: []const u8,
    product: []const u8,
    serial_number: []const u8,
    max_transfer_size: u16,
    endpoint_status: *const fn (u8) EndpointStatus,
    halt_ep: *const fn (u8, bool) bool
};

pub const ConfigurationDescriptor = struct {
    num_interfaces: u8,
    self_powered: bool,
    remote_wakeup: bool,
    max_power_ma: u16
};

pub const InterfaceDescriptor = struct {
    number: u8,
    alternate_setting: u8 = 0,
    num_endpoints: u8,
    class: DeviceClass,
    subclass: u8,
    protocol: u8
};

pub const EndpointTransferType = enum(u2) {
    control = 0,
    iso = 1,
    bulk = 2,
    interrupt = 3
};

pub const EndpointSyncType = enum(u2) {
    none = 0,
    async = 1,
    adaptive = 2,
    sync = 3
};

pub const EndpointUsageType = enum(u2) {
    data = 0,
    feedback = 1,
    implicit_feedback = 2
};

pub const EndpointAttributes = packed struct(u8) {
    transfer_type: EndpointTransferType,
    sync_type: EndpointSyncType = .none,
    usage_type: EndpointUsageType = .data,
    reserved: u2 = 0
};

pub const EndpointDescriptor = struct {
    endpoint_number: u4,
    in: bool,
    attributes: EndpointAttributes,
    max_packet_size: u16,
    interval: u8 = 0
};

pub const DeviceSleepStatus = struct {
    sleep_requested: bool = false,
    sleep_allowed: bool = false
};

pub const Device = struct {
    init: *const DeviceInit,
    address: u7 = undefined,
    current_config: [1]u8 = .{0},
    current_interface: [1]u8 = .{0},
    current_status: [2]u8 = .{0, 0},
    sleep_status: DeviceSleepStatus = .{},
    setup_packet: SetupPacket = undefined,
    next_transfer: []const u8 = &.{},

    fn startTransfer(self: *Device, data: []const u8, requested_length: u16) []const u8 {
        @setRuntimeSafety(if (builtin.is_test) true else false);
        const response_length = @min(requested_length, data.len);
        if (response_length > self.init.max_transfer_size) {
            self.next_transfer = data[self.init.max_transfer_size..response_length];
            return data[0..self.init.max_transfer_size];
        }
        self.next_transfer = &.{};
        return data[0..response_length];
    }

    fn continueTransfer(self: *Device) []const u8 {
        @setRuntimeSafety(if (builtin.is_test) true else false);
        const data = self.next_transfer;
        if (data.len > self.init.max_transfer_size) {
            self.next_transfer = data[self.init.max_transfer_size..];
            return data[0..self.init.max_transfer_size];
        }
        self.next_transfer = &.{};
        return data;
    }

    pub fn setup(self: *Device, request: *const SetupPacket) SetupResult {
        @setRuntimeSafety(if (builtin.is_test) true else false);
        self.setup_packet = request.*;
        switch (request.request) {
            @intFromEnum(Request.get_status) => {
                switch (request.request_type.recipient) {
                    .device => {
                        self.current_status[0] = if (self.sleep_status.sleep_allowed) 2 else 0;
                        return SetupResult{.tx = &self.current_status};
                    },
                    .endpoint => {
                        const status = self.init.endpoint_status(@truncate(request.index));
                        if  (status != .invalid_request) {
                            self.current_status[0] = if (status == .stall) 1 else 0;
                            return SetupResult{.tx = &self.current_status};
                        }
                    },
                    else => {}
                }
            },
            @intFromEnum(Request.clear_feature) => {
                switch (request.request_type.recipient) {
                    .device => {
                        if (request.value.value.lo == 1)  {// remote wakeup
                            self.sleep_status.sleep_allowed = false;
                            return .{.tx = &.{}};
                        }
                    },
                    .endpoint => {
                        if (request.value.value.lo == 0)  {// endpoint halt
                            if (self.init.halt_ep(@truncate(request.index), false)) {
                                return .{.tx = &.{}};
                            }
                        }
                    },
                    else => {}
                }
            },
            @intFromEnum(Request.set_feature) => {
                switch (request.request_type.recipient) {
                    .device => {
                        if (request.value.value.lo == 1)  {// remote wakeup
                            self.sleep_status.sleep_allowed = true;
                            return .{.tx = &.{}};
                        }
                    },
                    .endpoint => {
                        if (request.value.value.lo == 0)  {// endpoint halt
                            if (self.init.halt_ep(@truncate(request.index), true)) {
                                return .{.tx = &.{}};
                            }
                        }
                    },
                    else => {}
                }
            },
            @intFromEnum(Request.set_address) => {
                self.address = @truncate(request.value.value.lo);
            },
            @intFromEnum(Request.get_descriptor) => {
                switch (request.value.value.hi) {
                    @intFromEnum(DescriptorType.device) =>  {
                        return SetupResult{.tx = self.init.descriptor};
                    },
                    @intFromEnum(DescriptorType.configuration) =>  {
                        //todo
                        return SetupResult{.tx = self.startTransfer(self.init.config, request.length)};
                    },
                    @intFromEnum(DescriptorType.string) =>  {
                        switch (request.value.value.lo) {
                            0 => {
                                return SetupResult{.tx = &self.init.lang};
                            },
                            1 => {
                                return SetupResult{.tx = self.init.manufacturer};
                            },
                            2 => {
                                return SetupResult{.tx = self.init.product};
                            },
                            3 => {
                                return SetupResult{.tx = self.init.serial_number};
                            },
                            else => {}
                        }
                    },
                    else => {}
                }
            },
            @intFromEnum(Request.get_configuration) => {
                return SetupResult{.tx = &self.current_config};
            },
            @intFromEnum(Request.set_configuration) => {
                self.current_config[0] = request.value.value.lo;
                return SetupResult{.tx = &.{}};
            },
            @intFromEnum(Request.get_interface) => {
                return SetupResult{.tx = &self.current_interface};
            },
            @intFromEnum(Request.set_interface) => {
                return SetupResult{.tx = &.{}};
            },
            else => {}
        }
        return .{.invalid_request = true};
    }

    pub fn inPacket(self: *Device) InResult {
        @setRuntimeSafety(if (builtin.is_test) true else false);
        if (self.next_transfer.len == 0) {
            return InResult{.r_tog_and_ack = true};
        } else {
            switch (self.setup_packet.request) {
                @intFromEnum(Request.get_descriptor) => {
                    const data = self.continueTransfer();
                    return InResult{.tx = data};
                },
                @intFromEnum(Request.set_address) => {
                    return InResult{.set_address = self.address, .r_tog_and_ack = true};
                },
                else => {
                    return InResult{};
                }
            }
        }
    }

    pub fn outPacket(self: *Device) bool {
        @setRuntimeSafety(if (builtin.is_test) true else false);
        _ = self;
        return false;

    }

    pub fn suspendWakeup(self: *Device, suspended: bool) void {
        self.sleep_status.sleep_requested = suspended;
    }
};

pub fn buildStringDescriptor(comptime str: []const u8) [2 * str.len + 2]u8 {
    comptime {
        const total_size = 2 * str.len + 2;

        if (total_size > 255) {
            @compileError("USB String descriptor exceeds maximum allowed length of 255 bytes.");
        }

        var buffer: [total_size]u8 = undefined;

        buffer[0] = @truncate(total_size);
        buffer[1] = 3;

        var offset = 0;
        for (str) |char| {
            buffer[offset] = char;
            offset += 1;
            buffer[offset] = 0;
            offset += 1;
        }

        return buffer;
    }
}

pub fn buildDeviceDescriptor(comptime descriptor: DeviceDescriptor) [18]u8 {
    comptime {
        return [18]u8{18, 1, 0, 2, @intFromEnum(descriptor.device_class), descriptor.device_subclass,
                        descriptor.device_protocol, descriptor.max_packet_size,
                        @truncate(descriptor.vendor_id), @truncate(descriptor.vendor_id >> 8),
                        @truncate(descriptor.product_id), @truncate(descriptor.product_id >> 8),
                        descriptor.release_no_lo, descriptor.release_no_hi, 1, 2, 3, 1};
    }
}

fn calculateTotalLength(slices: []const []const u8) usize {
    var total_length: usize = 0;
    for (slices) |slice| {
        total_length += slice.len;
    }
    return total_length;
}

pub fn buildConfigDescriptor(comptime descriptor: ConfigurationDescriptor, comptime descriptors: []const []const u8) []const u8 {
    comptime {
        const total_length = calculateTotalLength(descriptors) + 9;
        var buffer: [total_length]u8 = undefined;
        buffer[0] = 9;
        buffer[1] = 2;
        buffer[2] = @truncate(total_length);
        buffer[3] = @truncate(total_length >> 8);
        buffer[4] = descriptor.num_interfaces;
        buffer[5] = 1;
        buffer[6] = 0;
        buffer[7] = 0x80 + if (descriptor.self_powered) 0x40 else 0 + if (descriptor.remote_wakeup) 0x20 else 0;
        buffer[8] = if (descriptor.max_power_ma > 510) 255 else @truncate(descriptor.max_power_ma / 2);
        var idx = 9; 
        for (descriptors) |d| {
            @memcpy(buffer[idx..idx + d.len], d);
            idx += d.len;
        }
        const b = buffer;
        return &b;
    }
}

pub fn buildInterfaceDescriptor(comptime descriptor: InterfaceDescriptor) []const u8 {
    comptime {
        var buffer: [9]u8 = undefined;
        buffer[0] = 9;
        buffer[1] = 4;
        buffer[2] = descriptor.number;
        buffer[3] = descriptor.alternate_setting;
        buffer[4] = descriptor.num_endpoints;
        buffer[5] = @intFromEnum(descriptor.class);
        buffer[6] = descriptor.subclass;
        buffer[7] = descriptor.protocol;
        buffer[8] = 0;
        const b = buffer;
        return &b;
    }
}

pub fn buildEndpointDescriptor(comptime descriptor: EndpointDescriptor) []const u8 {
    comptime {
        var buffer: [7]u8 = undefined;
        buffer[0] = 7;
        buffer[1] = 5;
        buffer[2] = @as(u8, descriptor.endpoint_number) | if (descriptor.in) 0x80 else 0;
        buffer[3] = @bitCast(descriptor.attributes);
        buffer[4] = @truncate(descriptor.max_packet_size);
        buffer[5] = @truncate(descriptor.max_packet_size >> 8);
        buffer[6] = descriptor.interval;
        const b = buffer;
        return &b;
    }
}

pub fn buildClassInterfaceDescriptor(subtype: u8, data1: u8, data2: u8) []const u8 {
    comptime {
        var buffer: [5]u8 = undefined;
        buffer[0] = 5;
        buffer[1] = 0x24;
        buffer[2] = subtype;
        buffer[3] = data1;
        buffer[4] = data2;
        const b = buffer;
        return &b;
    }
}

pub fn buildClassInterfaceDescriptor4(subtype: u8, data1: u8) []const u8 {
    comptime {
        var buffer: [4]u8 = undefined;
        buffer[0] = 4;
        buffer[1] = 0x24;
        buffer[2] = subtype;
        buffer[3] = data1;
        const b = buffer;
        return &b;
    }
}

test "config test" {
    const manufacturer = comptime buildStringDescriptor("test inc");
    const product = comptime buildStringDescriptor("test product");
    const serial_number = comptime buildStringDescriptor("12345");
    const descriptor = comptime buildDeviceDescriptor(.{
        .device_class = .cdc,
        .vendor_id = 0x1A86,
        .product_id = 0xFE0C
    });
    const INTERFACE_CONTROL = 0;
    const INTERFACE_DATA = 1;
    const config = comptime buildConfigDescriptor(.{
        .num_interfaces = 2,
        .self_powered = false,
        .remote_wakeup = false,
        .max_power_ma = 510
    }, &.{
        //cdc control interface
        buildInterfaceDescriptor(.{
            .number = INTERFACE_CONTROL,
            .num_endpoints = 1,
            .class = .cdc,
            .subclass = 2,
            .protocol = 1
        }),
        buildClassInterfaceDescriptor(0, 0x10, 1),
        buildClassInterfaceDescriptor(1, 0, INTERFACE_DATA),
        buildClassInterfaceDescriptor4(2, 2),
        buildClassInterfaceDescriptor(6, INTERFACE_CONTROL, INTERFACE_DATA),
        // control endpoint
        buildEndpointDescriptor(.{
            .endpoint_number = 1,
            .in = true,
            .attributes = .{.transfer_type = .interrupt},
            .max_packet_size = USB_FS_MAX_PACKET_SIZE,
            .interval = 255
        }),
        //cdc data interface
        buildInterfaceDescriptor(.{
            .number = INTERFACE_DATA,
            .num_endpoints = 2,
            .class = .cdc_data,
            .subclass = 0,
            .protocol = 0
        }),
        // out endpoint
        buildEndpointDescriptor(.{
            .endpoint_number = 2,
            .in = false,
            .attributes = .{.transfer_type = .bulk},
            .max_packet_size = USB_FS_MAX_PACKET_SIZE
        }),
        // in endpoint
        buildEndpointDescriptor(.{
            .endpoint_number = 3,
            .in = true,
            .attributes = .{.transfer_type = .bulk},
            .max_packet_size = USB_FS_MAX_PACKET_SIZE
        })
    });
    try std.testing.expectEqualSlices(u8, &descriptor, &.{0x12, 1, 0, 2, 2, 0, 0, 64, 0x86, 0x1a, 0x0C, 0xFE, 0, 1, 1, 2, 3, 1});
    try std.testing.expectEqual(67, config.len);
    try std.testing.expectEqualSlices(u8, config, &.{
        // Configure descriptor
        0x09, 0x02, 0x43, 0x00, 0x02, 0x01, 0x00, 0x80, 0xFF,
        // Interface 0 (CDC) descriptor
        0x09, 0x04, 0x00, 0x00, 0x01, 0x02, 0x02, 0x01,  0x00,
        // Functional Descriptors
        0x05, 0x24, 0x00, 0x10, 0x01,
        // Length/management descriptor (data class interface 1)
        0x05, 0x24, 0x01, 0x00, 0x01,
        0x04, 0x24, 0x02, 0x02,
        0x05, 0x24, 0x06, 0x00, 0x01,
        // Interrupt upload endpoint descriptor
        0x07, 0x05, 0x81, 0x03, 64, 0, 0xFF,
        // Interface 1 (data interface) descriptor
        0x09, 0x04, 0x01, 0x00, 0x02, 0x0A, 0x00, 0x00, 0x00,
        // Endpoint descriptor
        0x07, 0x05, 0x02, 0x02, 64, 0, 0x00,
        // Endpoint descriptor
        0x07, 0x05, 0x83, 0x02, 64, 0, 0x00
    });

    const device_init: DeviceInit = .{
        .descriptor = &descriptor,
        .config = config,
        .lang = .{0x04, 0x03, 0x09, 0x04},
        .manufacturer = &manufacturer,
        .product = &product,
        .serial_number = &serial_number,
        .max_transfer_size = USB_FS_MAX_PACKET_SIZE
    };

    var device: Device = .{
        .init = &device_init
    };
    try deviceDescriptorTests(&device, &descriptor);
    try configDescriptorTests(&device, config);
}

fn deviceDescriptorTests(device: *Device, descriptor: []const u8) !void {
    const setup_packet1: SetupPacket = .{
        .request_type = .{.direction = true, .recipient = .device, .type = .standard},
        .request = 6,
        .value = .{ .value = .{.lo = 0, .hi = 1} },
        .index = 0,
        .length = 64
    };
    const result1 = device.setup(&setup_packet1);
    try std.testing.expect(result1.tx != null);
    try std.testing.expectEqual(result1.tx.?.len, 18);
    try std.testing.expectEqual(result1.tx.?, descriptor);
    try std.testing.expectEqual(result1.receive_start, false);
    try std.testing.expectEqual(result1.invalid_request, false);
    const result_in1 = device.inPacket();
    try std.testing.expectEqual(result_in1.r_tog_and_ack, true);
    try std.testing.expectEqual(result_in1.set_address, 0);
    try std.testing.expectEqual(result_in1.tx, null);
}

fn configDescriptorTests(device: *Device, config: []const u8) !void {
    const setup_packet2: SetupPacket = .{
        .request_type = .{.direction = true, .recipient = .device, .type = .standard},
        .request = 6,
        .value = .{ .value = .{.lo = 0, .hi = 2} },
        .index = 0,
        .length = 9
    };
    const result2 = device.setup(&setup_packet2);
    try std.testing.expect(result2.tx != null);
    try std.testing.expectEqual(result2.tx.?.len, 9);
    try std.testing.expectEqual(result2.tx.?, config[0..9]);
    try std.testing.expectEqual(result2.receive_start, false);
    try std.testing.expectEqual(result2.invalid_request, false);
    const result_in2 = device.inPacket();
    try std.testing.expectEqual(result_in2.r_tog_and_ack, true);
    try std.testing.expectEqual(result_in2.set_address, 0);
    try std.testing.expectEqual(result_in2.tx, null);

    const setup_packet3: SetupPacket = .{
        .request_type = .{.direction = true, .recipient = .device, .type = .standard},
        .request = 6,
        .value = .{ .value = .{.lo = 0, .hi = 2} },
        .index = 0,
        .length = 67
    };
    const result3 = device.setup(&setup_packet3);
    try std.testing.expect(result3.tx != null);
    try std.testing.expectEqual(result3.tx.?.len, 64);
    try std.testing.expectEqual(result3.tx.?, config[0..64]);
    try std.testing.expectEqual(result3.receive_start, false);
    try std.testing.expectEqual(result3.invalid_request, false);
    const result_in3 = device.inPacket();
    try std.testing.expectEqual(result_in3.r_tog_and_ack, false);
    try std.testing.expectEqual(result_in3.set_address, 0);
    try std.testing.expect(result_in3.tx != null);
    try std.testing.expectEqualSlices(u8, result_in3.tx.?, config[64..]);
    const result_in4 = device.inPacket();
    try std.testing.expectEqual(result_in4.r_tog_and_ack, true);
    try std.testing.expectEqual(result_in4.set_address, 0);
    try std.testing.expect(result_in4.tx == null);
}
