const std = @import("std");
const hal = @import("hal");
const shell = @import("shell");
const allocator = @import("allocator");
const i2c_commands = @import("i2c_commands");
const usart_writer = @import("usart_writer");
const veml7700_commands = @import("veml7700_commands");
const scd4x_commands = @import("scd4x_commands");
const bme280_commands = @import("bme280_commands");
const tsl2591_commands = @import("tsl2591_commands");
const system_commands = @import("system_commands");
const flash_commands = @import("flash_commands");
const trng_commands = @import("trng_commands");
const aes_commands = @import("aes_commands");
const mathacl_commands = @import("mathacl_commands");

const shell_init = shell.ShellInit{
    .max_commands = 50,
    .max_parameters = 10,
    .max_parameter_length = 50,
    .max_command_length = 100,
    .history_length = 20
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

const rng: trng_commands.Rng = .{
    .gen = &trngGen,
    .init = &trngInit
};

inline fn timerHandler() void {
    if (!hal.timer_interrupt)
        return;
    hal.timer_interrupt = false;
    hal.ledToggle();
}

fn trngGen(data: []u32) bool {
    hal.trngGen(data);
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

    hal.sh = shell.Shell.init(&shell_init, a, &usart_writer.usart_writer.writer, hal.usartWrite) catch { while (true){} };
    i2c_commands.registerCommands(hal.sh, hal.i2cScan) catch { while (true){} };
    veml7700_commands.registerCommands(hal.sh, &hal.veml_device) catch { while (true){} };
    scd4x_commands.registerCommands(hal.sh, &hal.scd_device) catch { while (true){} };
    bme280_commands.registerCommands(hal.sh, &hal.bme_device) catch { while (true){} };
    tsl2591_commands.registerCommands(hal.sh, &hal.tsl_device) catch { while (true){} };
    system_commands.registerCommands(hal.sh) catch { while (true){} };
    flash_commands.registerCommands(hal.sh) catch { while (true){} };
    trng_commands.registerCommands(hal.sh, &rng) catch { while (true){} };
    aes_commands.registerCommands(hal.sh, &aes_engines) catch { while (true){} };
    aes_commands.registerCommands(hal.sh, &aes_engines) catch { while (true){} };
    mathacl_commands.registerCommands(hal.sh) catch { while (true){} };

    hal.startTimer();

    while (true) {
        hal.enterSleep();
        hal.sh.handler() catch { while (true){} };
        timerHandler();
    }
}
