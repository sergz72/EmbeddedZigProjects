const std = @import("std");

const linux = std.os.linux;

const GPIO_MAX_NAME_SIZE = 32;

// Maximum number of requested lines.
//
// Must be no greater than 64, as bitmaps are restricted here to 64-bits
// for simplicity, and a multiple of 2 to ensure 32/64-bit alignment of
// structs.
//
const GPIO_V2_LINES_MAX = 64;

// The maximum number of configuration attributes associated with a line
// request.
//
const GPIO_V2_LINE_NUM_ATTRS_MAX = 10;

// enum gpio_v2_line_flag - &struct gpio_v2_line_attribute.flags values
// @GPIO_V2_LINE_FLAG_USED: line is not available for request
// @GPIO_V2_LINE_FLAG_ACTIVE_LOW: line active state is physical low
// @GPIO_V2_LINE_FLAG_INPUT: line is an input
// @GPIO_V2_LINE_FLAG_OUTPUT: line is an output
// @GPIO_V2_LINE_FLAG_EDGE_RISING: line detects rising (inactive to active) edges
// @GPIO_V2_LINE_FLAG_EDGE_FALLING: line detects falling (active to inactive) edges
// @GPIO_V2_LINE_FLAG_OPEN_DRAIN: line is an open drain output
// @GPIO_V2_LINE_FLAG_OPEN_SOURCE: line is an open source output
// @GPIO_V2_LINE_FLAG_BIAS_PULL_UP: line has pull-up bias enabled
// @GPIO_V2_LINE_FLAG_BIAS_PULL_DOWN: line has pull-down bias enabled
// @GPIO_V2_LINE_FLAG_BIAS_DISABLED: line has bias disabled
//
const GPIO_V2_LINE_FLAG_USED               = 1;
pub const GPIO_V2_LINE_FLAG_ACTIVE_LOW     = 2;
const GPIO_V2_LINE_FLAG_INPUT              = 4;
const GPIO_V2_LINE_FLAG_OUTPUT             = 8;
pub const GPIO_V2_LINE_FLAG_EDGE_RISING    = 16;
pub const GPIO_V2_LINE_FLAG_EDGE_FALLING   = 32;
pub const GPIO_V2_LINE_FLAG_OPEN_DRAIN     = 64;
pub const GPIO_V2_LINE_FLAG_OPEN_SOURCE    = 128;
pub const GPIO_V2_LINE_FLAG_BIAS_PULL_UP   = 256;
pub const GPIO_V2_LINE_FLAG_BIAS_PULL_DOWN = 512;
pub const GPIO_V2_LINE_FLAG_BIAS_DISABLED  = 1024;

// enum gpio_v2_line_attr_id - &struct gpio_v2_line_attribute.id values
// identifying which field of the attribute union is in use.
// @GPIO_V2_LINE_ATTR_ID_FLAGS: flags field is in use
// @GPIO_V2_LINE_ATTR_ID_OUTPUT_VALUES: values field is in use
// @GPIO_V2_LINE_ATTR_ID_DEBOUNCE: debounce_period_us field is in use
//
const GPIO_V2_LINE_ATTR_ID_FLAGS: u32         = 1;
const GPIO_V2_LINE_ATTR_ID_OUTPUT_VALUES: u32 = 2;
const GPIO_V2_LINE_ATTR_ID_DEBOUNCE: u32      = 3;

pub const GpioChipInfo = extern struct {
    name:  [GPIO_MAX_NAME_SIZE]u8,
    label: [GPIO_MAX_NAME_SIZE]u8,
    lines: u32
};

pub const GpioLineAttribute = extern struct {
    id:           u32,
    padding:      u32 = 0,
    flags_values: u64
};

pub const GpioLineInfo = extern struct {
    name:      [GPIO_MAX_NAME_SIZE]u8,
    consumer:  [GPIO_MAX_NAME_SIZE]u8,
    offset:    u32,
    num_attrs: u32,
    flags:     u64,
    attrs:     [GPIO_V2_LINE_NUM_ATTRS_MAX]GpioLineAttribute,
    // Space reserved for future use.
    padding:   [4]u32
};

pub const GpioLineConfigAttribute = extern struct {
    attr: GpioLineAttribute,
    mask: u64
};

pub const GpioLineConfig = extern struct {
    flags:     u64,
    num_attrs: u32,
    // Pad to fill implicit padding and reserve space for future use.
    padding:   [5]u32,
    attrs:     [GPIO_V2_LINE_NUM_ATTRS_MAX]GpioLineConfigAttribute
};

pub const GpioLineRequest = extern struct {
    offsets:           [GPIO_V2_LINES_MAX]u32,
    consumer:          [GPIO_MAX_NAME_SIZE]u8,
    config:            GpioLineConfig,
    num_lines:         u32,
    event_buffer_size: u32,
    // Pad to fill implicit padding and reserve space for future use.
    padding:           [5]u32,
    fd:                i32
};

pub const GpioLineValues = extern struct {
    bits: u64,
    mask: u64
};

pub const InternalError = error {
    IoctlFailed,
    InvalidNumberOfGpioParameters,
    InvalidGpioParameter,
    InvalidChipId,
    InvalidOffset,
    InvalidLineSetOption,
    InvalidLevel,
    InvalidFlag
};

pub const GpioError = std.mem.Allocator.Error || std.Io.File.OpenError || InternalError;

const LineSetFn = *const fn (self: *GPIO, offset: u32, it: *std.mem.SplitIterator(u8, .scalar), io: std.Io) GpioError!void;

const line_set_options = std.StaticStringMap(LineSetFn).initComptime(.{
    .{ "out", GPIO.setLineOut },
    .{ "toggle", GPIO.toggleLine },
    .{ "in_float", GPIO.setLineInFloat },
    .{ "in_pullup", GPIO.setLineInPullup },
    .{ "in_pulldown", GPIO.setLineInPulldown }
});

const line_out_options = std.StaticStringMap(u64).initComptime(.{
    .{ "open_drain", GPIO_V2_LINE_FLAG_OPEN_DRAIN },
    .{ "open_source", GPIO_V2_LINE_FLAG_OPEN_SOURCE },
    .{ "active_low", GPIO_V2_LINE_FLAG_ACTIVE_LOW },
    .{ "pullup", GPIO_V2_LINE_FLAG_BIAS_PULL_UP },
    .{ "pulldown", GPIO_V2_LINE_FLAG_BIAS_PULL_DOWN }
});

const chip_info_ioctl = linux.IOCTL.IOR(0xB4, 0x01, GpioChipInfo);
const line_info_ioctl = linux.IOCTL.IOWR(0xB4, 0x05, GpioLineInfo);
const line_request_ioctl = linux.IOCTL.IOWR(0xB4, 0x07, GpioLineRequest);
const line_get_values_ioctl = linux.IOCTL.IOWR(0xB4, 0x0E, GpioLineValues);
const line_set_values_ioctl = linux.IOCTL.IOWR(0xB4, 0x0F, GpioLineValues);

pub const GPIO = struct {
    file: std.Io.File = undefined,
    linux_errno: linux.E = .SUCCESS,

    pub fn close(self: *const GPIO, io: std.Io) void {
        self.file.close(io);
    }

    pub fn init(self: *GPIO, io: std.Io, allocator: std.mem.Allocator, chip_number: usize) GpioError!void {
        const file_name = try std.fmt.allocPrint(allocator, "/dev/gpiochip{}", .{chip_number});
        defer allocator.free(file_name);
        self.file = try std.Io.Dir.cwd().openFile(io, file_name, .{ .mode = .read_write });
    }

    pub fn getChipInfo(self: *GPIO, info: *GpioChipInfo) GpioError!void {
        const bytes = std.mem.asBytes(info);
        @memset(bytes, 0);
        const rc = linux.ioctl(self.file.handle, chip_info_ioctl, @intFromPtr(info));
        self.linux_errno = linux.errno(rc);
        if (self.linux_errno != .SUCCESS) {
            return InternalError.IoctlFailed;
        }
    }

    pub fn getLineInfo(self: *GPIO, info: *GpioLineInfo, offset: u32) GpioError!void {
        const bytes = std.mem.asBytes(info);
        @memset(bytes, 0);
        info.offset = offset;
        const rc = linux.ioctl(self.file.handle, line_info_ioctl, @intFromPtr(info));
        self.linux_errno = linux.errno(rc);
        if (self.linux_errno != .SUCCESS) {
            return InternalError.IoctlFailed;
        }
    }

    pub fn printChipInfo(self: *GPIO) void {
        var info: GpioChipInfo = undefined;
        self.getChipInfo(&info) catch |err| {
            std.debug.print("{}, linux error {}\n", .{err, self.linux_errno});
            return;
        };
        std.debug.print("chip info: name={s} label={s} lines={}\n", .{
            std.mem.sliceTo(&info.name, 0), std.mem.sliceTo(&info.label, 0), info.lines
        });
    }

    pub fn printLineInfo(self: *GPIO, offset: u32) void {
        var info: GpioLineInfo = undefined;
        self.getLineInfo(&info, offset) catch |err| {
            std.debug.print("{}, linux error {}\n", .{err, self.linux_errno});
        };
        std.debug.print("line info: name={s} consumer={s} number of attributes={}\n",
                    .{std.mem.sliceTo(&info.name, 0), std.mem.sliceTo(&info.consumer, 0), info.num_attrs});
    }

    fn lineRequest(self: *GPIO, request: *GpioLineRequest) GpioError!void {
        const rc = linux.ioctl(self.file.handle, line_request_ioctl, @intFromPtr(request));
        self.linux_errno = linux.errno(rc);
        if (self.linux_errno != .SUCCESS) {
            return InternalError.IoctlFailed;
        }
    }

    fn get_offset(it: *std.mem.SplitIterator(u8, .scalar)) GpioError!u32 {
        const part3 = it.next() orelse return GpioError.InvalidNumberOfGpioParameters;
        return std.fmt.parseInt(u32, part3, 10) catch {
            return GpioError.InvalidOffset;
        };
    }

    pub fn setLineOutput(self: *GPIO, offset: u32, level: bool, flags: u64) GpioError!GPIOPin {
        const value: u64 = if (level) 1 else 0;
        var request = std.mem.zeroes(GpioLineRequest);
        request.offsets[0] = offset;
        request.num_lines = 1;
        @memcpy(request.consumer[0..18], "peripheral_library");
        request.config.flags = GPIO_V2_LINE_FLAG_OUTPUT | flags;
        request.config.num_attrs = 1;
        request.config.attrs[0] = .{
            .attr = .{.id = GPIO_V2_LINE_ATTR_ID_OUTPUT_VALUES, .flags_values = value},
            .mask = 1
        };
        try self.lineRequest(&request);
        return .{.file = std.Io.File{.handle = request.fd, .flags = .{ .nonblocking = false }}};
    }

    pub fn setLineInput(self: *GPIO, offset: u32, flags: u64) GpioError!GPIOPin {
        var request = std.mem.zeroes(GpioLineRequest);
        request.offsets[0] = offset;
        request.num_lines = 1;
        @memcpy(request.consumer[0..18], "peripheral_library");
        request.config.flags = GPIO_V2_LINE_FLAG_INPUT | flags;
        try self.lineRequest(&request);
        return .{.file = std.Io.File{.handle = request.fd, .flags = .{ .nonblocking = false }}};
    }

    fn setLineOut(self: *GPIO, offset: u32, it: *std.mem.SplitIterator(u8, .scalar), io: std.Io) GpioError!void {
        const part5 = it.next() orelse return GpioError.InvalidNumberOfGpioParameters;
        if ((part5.len != 1) or (part5[0] != '0' and part5[0] != '1')) {
            return GpioError.InvalidLevel;
        }
        const level = part5[0] != '0';
        var flags: u64 = 0;
        while (true) {
            const part = it.next() orelse break;
            const f = line_out_options.get(part) orelse return GpioError.InvalidFlag;
            flags |= f;
        }
        if (flags & (GPIO_V2_LINE_FLAG_BIAS_PULL_DOWN|GPIO_V2_LINE_FLAG_BIAS_PULL_UP) == 0) {
            flags |= GPIO_V2_LINE_FLAG_BIAS_DISABLED;
        }
        const pin = try self.setLineOutput(offset, level, flags);
        pin.close(io);
    }

    fn toggleLine(self: *GPIO, offset: u32, it: *std.mem.SplitIterator(u8, .scalar), io: std.Io) GpioError!void {
        if (it.next() != null) {
            return GpioError.InvalidNumberOfGpioParameters;
        }
        var level = false;
        var pin = try self.setLineOutput(offset, level, 0);
        defer pin.close(io);
        const one_second = std.Io.Duration.fromSeconds(1);
        for (0..4) |_| {
            try std.Io.sleep(io, one_second, .awake);
            level = !level;
            try pin.write(level);
        }
    }

    fn setLineInFloat(self: *GPIO, offset: u32, it: *std.mem.SplitIterator(u8, .scalar), io: std.Io) GpioError!void {
        try self.setLineIn(offset, it, io, GPIO_V2_LINE_FLAG_BIAS_DISABLED);
    }

    fn setLineInPullup(self: *GPIO, offset: u32, it: *std.mem.SplitIterator(u8, .scalar), io: std.Io) GpioError!void {
        try self.setLineIn(offset, it, io, GPIO_V2_LINE_FLAG_BIAS_PULL_UP);
    }

    fn setLineIn(self: *GPIO, offset: u32, it: *std.mem.SplitIterator(u8, .scalar), io: std.Io,
                    flags: u64) GpioError!void {
        if (it.next() != null) {
            return GpioError.InvalidNumberOfGpioParameters;
        }
        var pin = try self.setLineInput(offset, flags);
        const level = pin.read() catch |err| {
            std.debug.print("linux error {}\n", .{pin.linux_errno});
            return err;
        };
        std.debug.print("pin level = {}\n", .{level});
        pin.close(io);
    }

    fn setLineInPulldown(self: *GPIO, offset: u32, it: *std.mem.SplitIterator(u8, .scalar), io: std.Io) GpioError!void {
        try self.setLineIn(offset, it, io, GPIO_V2_LINE_FLAG_BIAS_PULL_DOWN);
    }

    pub fn testGpio(io: std.Io, allocator: std.mem.Allocator, parameters: []const u8) GpioError!void {
        var it = std.mem.splitScalar(u8, parameters, ',');
        const part1 = it.next() orelse return GpioError.InvalidNumberOfGpioParameters;
        const part2 = it.next() orelse return GpioError.InvalidNumberOfGpioParameters;
        const chip_id = std.fmt.parseInt(usize, part1, 10) catch {return GpioError.InvalidChipId;};
        var gpio = GPIO{};
        try gpio.init(io, allocator, chip_id);
        defer gpio.close(io);
        if (std.mem.eql(u8, part2, "chipinfo")) {
            gpio.printChipInfo();
        } else if (std.mem.eql(u8, part2, "lineinfo")) {
            const offset = try get_offset(&it);
            gpio.printLineInfo(offset);
        } else if (std.mem.eql(u8, part2, "lineset")) {
            const offset = try get_offset(&it);
            const part4 = it.next() orelse return GpioError.InvalidNumberOfGpioParameters;
            const line_fn = line_set_options.get(part4) orelse return GpioError.InvalidLineSetOption;
            try line_fn(&gpio, offset, &it, io);
        } else {
            return GpioError.InvalidGpioParameter;
        }
    }
};

pub const GPIOPin = struct {
    file: std.Io.File,
    linux_errno: linux.E = .SUCCESS,

    pub fn close(self: *const GPIOPin, io: std.Io) void {
        self.file.close(io);
    }

    pub fn write(self: *GPIOPin, level: bool) GpioError!void {
        const l: u64 = if (level) 1 else 0;
        var values: GpioLineValues = .{.bits = l, .mask = 1};
        const rc = linux.ioctl(self.file.handle, line_set_values_ioctl, @intFromPtr(&values));
        self.linux_errno = linux.errno(rc);
        if (self.linux_errno != .SUCCESS) {
            return InternalError.IoctlFailed;
        }
    }

    pub fn read(self: *GPIOPin) GpioError!bool {
        var values: GpioLineValues = .{.bits = 0, .mask = 1};
        const rc = linux.ioctl(self.file.handle, line_get_values_ioctl, @intFromPtr(&values));
        self.linux_errno = linux.errno(rc);
        if (self.linux_errno != .SUCCESS) {
            return InternalError.IoctlFailed;
        }
        return values.bits & 1 != 0;
    }
};

