const std = @import("std");

const linux = std.os.linux;

const SPI_IOC_MAGIC: u32 = 107;

const spi_ioc_wr_mode = linux.IOCTL.IOW(SPI_IOC_MAGIC, 1, u8);
const spi_ioc_wr_lsb_first = linux.IOCTL.IOW(SPI_IOC_MAGIC, 2, u8);
const spi_ioc_wr_bits_per_word = linux.IOCTL.IOW(SPI_IOC_MAGIC, 3, u8);
const spi_ioc_wr_max_speed_hz = linux.IOCTL.IOW(SPI_IOC_MAGIC, 4, u32);
const spi_ioc_transfer = linux.IOCTL.IOW(SPI_IOC_MAGIC, 0, SpiIocTransfer);

const SpiIocTransfer = extern struct {
    tx_buf:           usize,
    rx_buf:           usize,
    length:           u32,
    speed_hz:         u32,
    delay_usecs:      u16,
    bits_per_word:    u8,
    cs_change:        u8,
    tx_nbits:         u8,
    rx_nbits:         u8,
    word_delay_usecs: u8,
    pad:              u8
};

pub const InternalError = error {
    IoctlFailed,
};

pub const SPIError = std.mem.Allocator.Error || std.Io.File.OpenError || InternalError;

pub const SPIMaster = struct {
    file: std.Io.File = undefined,
    linux_errno: linux.E = .SUCCESS,
    speed_hz:      u32,
    bits_per_word: u8,

    pub fn close(self: *const SPIMaster, io: std.Io) void {
        self.file.close(io);
    }

    pub fn init(self: *SPIMaster, io: std.Io, allocator: std.mem.Allocator, bus_number: usize, device_number: usize) SPIError!void {
        const file_name = try std.fmt.allocPrint(allocator, "/dev/spidev{}.{}", .{bus_number, device_number});
        defer allocator.free(file_name);
        self.file = try std.Io.Dir.cwd().openFile(io, file_name, .{ .mode = .read_write });
    }

    pub fn setMode(self: *SPIMaster, mode: u8) SPIError!void {
        const rc = linux.ioctl(self.file.handle, spi_ioc_wr_mode, @intFromPtr(&mode));
        self.linux_errno = linux.errno(rc);
        if (self.linux_errno != .SUCCESS) {
            return SPIError.IoctlFailed;
        }
    }

    pub fn setBitsPerWord(self: *SPIMaster, bpw: u8) SPIError!void {
        self.bits_per_word = bpw;
        const rc = linux.ioctl(self.file.handle, spi_ioc_wr_bits_per_word, @intFromPtr(&bpw));
        self.linux_errno = linux.errno(rc);
        if (self.linux_errno != .SUCCESS) {
            return SPIError.IoctlFailed;
        }
    }

    pub fn setSpeed(self: *SPIMaster, speed: u32) SPIError!void {
        self.speed_hz = speed;
        const rc = linux.ioctl(self.file.handle, spi_ioc_wr_max_speed_hz, @intFromPtr(&speed));
        self.linux_errno = linux.errno(rc);
        if (self.linux_errno != .SUCCESS) {
            return SPIError.IoctlFailed;
        }
    }

    pub fn transfer(self: *SPIMaster, wdata: []const u8, rdata: []u8) SPIError!void {
        //std.debug.print("transfer {x} {x} {} {}\n", .{wdata, rdata, self.speed_hz, self.bits_per_word});
        var trfr: SpiIocTransfer = .{
            .tx_buf           = @intFromPtr(&wdata[0]),
            .rx_buf           = @intFromPtr(&rdata[0]),
            .length           = @truncate(wdata.len),
            .speed_hz         = self.speed_hz,
            .delay_usecs      = 0,
            .bits_per_word    = self.bits_per_word,
            .tx_nbits         = 0,
            .rx_nbits         = 0,
            .word_delay_usecs = 0,
            .cs_change        = 0,
            .pad              = 0,
        };
        const rc = linux.ioctl(self.file.handle, spi_ioc_transfer, @intFromPtr(&trfr));
        self.linux_errno = linux.errno(rc);
        if (self.linux_errno != .SUCCESS) {
            return SPIError.IoctlFailed;
        }
    }

    pub fn write(self: *SPIMaster, wdata: []const u8) SPIError!void {
        //std.debug.print("write {x} {} {}\n", .{wdata, self.speed_hz, self.bits_per_word});
        var trfr: SpiIocTransfer = .{
            .tx_buf           = @intFromPtr(&wdata[0]),
            .rx_buf           = 0,
            .length           = @truncate(wdata.len),
            .speed_hz         = self.speed_hz,
            .delay_usecs      = 0,
            .bits_per_word    = self.bits_per_word,
            .tx_nbits         = 0,
            .rx_nbits         = 0,
            .word_delay_usecs = 0,
            .cs_change        = 0,
            .pad              = 0,
        };
        const rc = linux.ioctl(self.file.handle, spi_ioc_transfer, @intFromPtr(&trfr));
        self.linux_errno = linux.errno(rc);
        if (self.linux_errno != .SUCCESS) {
            return SPIError.IoctlFailed;
        }
    }

    pub fn testTransfer(self: *SPIMaster) SPIError!void {
        const wdata: [3]u8 = .{ 0x55, 0xAA, 0xA5 };
        var rdata: [3]u8 = undefined;
        try self.transfer(&wdata, &rdata);
        std.debug.print("Sent data: {x}\n", .{wdata});
        std.debug.print("Received data: {x}\n", .{rdata});
        try self.transfer(wdata[0..1], rdata[0..1]);
        std.debug.print("Sent data: {x}\n", .{wdata[0..1]});
        std.debug.print("Received data: {x}\n", .{rdata[0..1]});
    }
};
