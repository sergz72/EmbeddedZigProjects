const std = @import("std");
const hal = @import("hal");
const shell = @import("shell");
const allocator = @import("allocator");
const i2c_commands = @import("i2c_commands");
const spi_commands = @import("spi_commands");
const usart_writer = @import("usart_writer");
const veml7700_commands = @import("veml7700_commands");
const scd4x_commands = @import("scd4x_commands");
const bme280_commands = @import("bme280_commands");
const tsl2591_commands = @import("tsl2591_commands");
const system_commands = @import("system_commands");
const flash_commands = @import("flash_commands");
const trng_commands = @import("trng_commands");
const aes_commands = @import("aes_commands");
const prng = @import("prng");
const aes128 = @import("aes128");

const shell_init = shell.ShellInit{
    .max_commands = 50,
    .max_parameters = 10,
    .max_parameter_length = 50,
    .max_command_length = 100,
    .history_length = 20
};

const aes_engines: aes_commands.Engines = .{
    .gen_random = &prng.prngGen,
    .implementations = &.{
        .{
            .encrypt = &aesEncrypt,
            .decrypt = &aesDecrypt
        }
    }
};

const rng: trng_commands.Rng = .{
    .gen = &prng.prngGen,
    .init = &prng.prngInit
};

fn aesEncrypt(key: []const u8, iv: []const u8, in: []const u8, out: []u8) bool {
    @setRuntimeSafety(false);
    if (key.len != 16 or iv.len != 16) return false;
    var aes: aes128.Aes128 = undefined;
    aes.setKey(key[0..16]);
    return aes.encryptCbc(iv[0..16], in, out);
}

fn aesDecrypt(key: []const u8, iv: []const u8, in: []const u8, out: []u8) bool {
    @setRuntimeSafety(false);
    if (key.len != 16 or iv.len != 16) return false;
    var aes: aes128.Aes128 = undefined;
    aes.setKey(key[0..16]);
    return aes.decryptCbc(iv[0..16], in, out);
}

export fn main() callconv(.c) noreturn {
    const a = allocator.buildAllocator();

    hal.sh = shell.Shell.init(&shell_init, a, &usart_writer.usart_writer.writer, hal.usartWrite) catch { while (true){} };
    i2c_commands.registerCommands(hal.sh, hal.i2cScan) catch { while (true){} };
    spi_commands.registerCommands(hal.sh, hal.spiSendReceive) catch { while (true){} };
    veml7700_commands.registerCommands(hal.sh, &hal.veml_device) catch { while (true){} };
    scd4x_commands.registerCommands(hal.sh, &hal.scd_device) catch { while (true){} };
    bme280_commands.registerCommands(hal.sh, &hal.bme_device) catch { while (true){} };
    tsl2591_commands.registerCommands(hal.sh, &hal.tsl_device) catch { while (true){} };
    system_commands.registerCommands(hal.sh) catch { while (true){} };
    flash_commands.registerCommands(hal.sh) catch { while (true){} };
    trng_commands.registerCommands(hal.sh, &rng) catch { while (true){} };
    aes_commands.registerCommands(hal.sh, &aes_engines) catch { while (true){} };

    _ = usart_writer.usart_writer.writer.write(hal.getResetCause()) catch { while (true){} };

    hal.startTimer();

    while (true) {
        asm volatile("wfi");
        hal.wdtReset();
        hal.sh.handler() catch { while (true){} };
        if (hal.timer_interrupt) {
            hal.timer_interrupt = false;
            hal.ledToggle();
        }
    }
}
