const std = @import("std");
const hal = @import("hal");
const board = @import("board");
const shell = @import("shell");
const allocator = @import("allocator");
const usart_writer = @import("usart_writer");
const system_commands = @import("system_commands");
const flash_commands = @import("flash_commands");
const trng_commands = @import("trng_commands");
const crc_commands = @import("crc_commands");
const i2c_commands = @import("i2c_commands");
const spi_commands = @import("spi_commands");
const veml7700_commands = @import("veml7700_commands");
const scd4x_commands = @import("scd4x_commands");
const rtc_commands = @import("rtc_commands");
const aes_commands = @import("aes_commands");
const trng = @import("trng");
const dsu = @import("dsu");
const dmac = @import("dmac");

const shell_init = shell.ShellInit{
    .max_commands = 50,
    .max_parameters = 10,
    .max_parameter_length = 50,
    .max_command_length = 100,
    .history_length = 20,
    .source_init = &.{
        shell.ShellSourceInit{
            .writer = &usart_writer.usart_writer.writer,
            .echo_func = board.usartWrite
        }
    }
};

const rng: trng_commands.Rng = .{
    .gen = &trngGen,
    .init = &trngInit
};

const crc_generators: crc_commands.Generators = .{
    .crc8 = null,
    .crc16 = null,
    .crc32 = &crc32dmac
};

const aes_engines: aes_commands.Engines = .{
    .gen_random = &trngGen,
    .implementations = &.{
        .{
            .encrypt = &aesEncrypt,
            .decrypt = &aesDecrypt
        }
    }
};

fn crc32dsu(data: []const align(4) u8) u32 {
    if (data.len == 0 or data.len & 3 != 0) return 0;
    const d = std.mem.bytesAsSlice(u32, data);
    return dsu.dsu.crc32(d) catch {
        return 0;
    };
}

fn crc32dmac(data: []const align(4) u8) u32 {
    return dmac.dmac.crc32(.chn0, 0, data);
}

fn trngGen(data: []u32) bool {
    trng.trng.generate(data);
    return true;
}

fn trngInit(seed: usize) void {
    _ = seed;
}

fn aesEncrypt(key: []const u8, iv: []const u8, in: []const u8, out: []u8) bool {
    _ = key;
    _ = iv;
    _ = in;
    _ = out;
    return false;
}

fn aesDecrypt(key: []const u8, iv: []const u8, in: []const u8, out: []u8) bool {
    _ = key;
    _ = iv;
    _ = in;
    _ = out;
    return false;
}

export fn main() callconv(.c) noreturn {
    const a = allocator.buildAllocator();

    hal.sh = shell.Shell.init(&shell_init, a) catch { while (true){} };
    system_commands.registerCommands(hal.sh) catch { while (true){} };
    flash_commands.registerCommands(hal.sh) catch { while (true){} };
    trng_commands.registerCommands(hal.sh, &rng) catch { while (true){} };
    aes_commands.registerCommands(hal.sh, &aes_engines) catch { while (true){} };
    crc_commands.registerCommands(hal.sh, &crc_generators) catch { while (true){} };
    i2c_commands.registerCommands(hal.sh, hal.i2cScan) catch { while (true){} };
    spi_commands.registerCommands(hal.sh, hal.spiSendReceive) catch { while (true){} };
    veml7700_commands.registerCommands(hal.sh, &hal.veml_device) catch { while (true){} };
    scd4x_commands.registerCommands(hal.sh, &hal.scd_device) catch { while (true){} };
    rtc_commands.registerCommands(hal.sh) catch { while (true){} };

    _ = usart_writer.usart_writer.writer.write(hal.getResetCause()) catch { while (true){} };

    hal.timerStart();

    while (true) {
        asm volatile("wfi");
        hal.wdtReset();
        hal.sh.handler() catch { while (true){} };
        if (hal.timer_interrupt) {
            hal.timer_interrupt = false;
            board.ledToggle();
        }
    }
}
