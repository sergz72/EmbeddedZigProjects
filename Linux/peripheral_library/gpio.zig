const std = @import("std");

const linux = std.os.linux;

const GPIO_MAX_NAME_SIZE = 32;

//
// Maximum number of requested lines.
//
// Must be no greater than 64, as bitmaps are restricted here to 64-bits
// for simplicity, and a multiple of 2 to ensure 32/64-bit alignment of
// structs.
//
const GPIO_V2_LINES_MAX = 64;

//
// The maximum number of configuration attributes associated with a line
// request.
//
const GPIO_V2_LINE_NUM_ATTRS_MAX = 10;

pub const GpioChipInfo = extern struct {
    name:  [GPIO_MAX_NAME_SIZE]u8,
    label: [GPIO_MAX_NAME_SIZE]u8,
    lines: u32
};

pub const GpioLineAttribute = extern struct {
    id:           u32,
    padding:      u32,
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
    InvalidOffset
};

pub const GpioError = std.mem.Allocator.Error || std.Io.File.OpenError || InternalError;

fn getChipInfoIoctl() u32 {
    return linux.IOCTL.IOR(0xB4, 0x01, GpioChipInfo);
}

fn getLineInfoIoctl() u32 {
    return linux.IOCTL.IOWR(0xB4, 0x05, GpioLineInfo);
}

pub const GPIO = struct {
    file: std.Io.File = undefined,
    linux_errno: linux.E = .SUCCESS,

    pub fn close(self: *GPIO, io: std.Io) void {
        self.file.close(io);
    }

    pub fn init(self: *GPIO, io: std.Io, allocator: std.mem.Allocator, chip_number: usize) GpioError!void {
        const file_name = try std.fmt.allocPrint(allocator, "/dev/gpiochip{}", .{chip_number});
        defer allocator.free(file_name);
        self.file = try std.Io.Dir.cwd().openFile(io, file_name, .{ .mode = .read_write });
    }

    pub fn getChipInfo(self: *GPIO, info: *GpioChipInfo) GpioError!void {
        const rc = linux.ioctl(self.file.handle, getChipInfoIoctl(), @intFromPtr(info));
        self.linux_errno = linux.errno(rc);
        if (self.linux_errno != .SUCCESS) {
            return InternalError.IoctlFailed;
        }
    }

    pub fn getLineInfo(self: *GPIO, info: *GpioLineInfo) GpioError!void {
        const rc = linux.ioctl(self.file.handle, getLineInfoIoctl(), @intFromPtr(info));
        self.linux_errno = linux.errno(rc);
        if (self.linux_errno != .SUCCESS) {
            return InternalError.IoctlFailed;
        }
    }

    pub fn testGpio(io: std.Io, allocator: std.mem.Allocator, parameters: []const u8) GpioError!void {
        var it = std.mem.splitScalar(u8, parameters, ',');
        const part1 = it.next();
        const part2 = it.next();
        if (part1 == null or part2 == null) {
            return GpioError.InvalidNumberOfGpioParameters;
        }
        const chip_id = std.fmt.parseInt(usize, part1.?, 10) catch {return GpioError.InvalidChipId;};
        var gpio = GPIO{};
        try gpio.init(io, allocator, chip_id);
        defer gpio.close(io);
        if (std.mem.eql(u8, part2.?, "chipinfo")) {
            var info = std.mem.zeroes(GpioChipInfo);
            gpio.getChipInfo(&info) catch |err| {
                std.debug.print("linux error {}\n", .{gpio.linux_errno});
                return err;
            };
            std.debug.print("chip info: name={s} label={s} lines={}\n", .{info.name, info.label, info.lines});
        } else if (std.mem.eql(u8, part2.?, "lineinfo")) {
            const part3 = it.next();
            if (part3 == null) {
                return GpioError.InvalidNumberOfGpioParameters;
            }
            const offset = std.fmt.parseInt(u32, part3.?, 10) catch {
                return GpioError.InvalidOffset;
            };
            var info = std.mem.zeroes(GpioLineInfo);
            info.offset = offset;
            gpio.getLineInfo(&info) catch |err| {
                std.debug.print("linux error {}\n", .{gpio.linux_errno});
                return err;
            };
            std.debug.print("line info: name={s} consumer={s} number of attributes={}\n", .{info.name, info.consumer, info.num_attrs});
        } else {
            return GpioError.InvalidGpioParameter;
        }
    }
};

pub const GPIOPin = struct {
    file: std.Io.File,
};

