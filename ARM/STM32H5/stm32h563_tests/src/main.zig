const std = @import("std");
const hal = @import("hal");
const shell = @import("shell");
const allocator = @import("allocator");
const usart_writer = @import("usart_writer");
const usb_writer = @import("usb_writer");
const system_commands = @import("system_commands");
const flash_commands = @import("flash_commands");
const board = @import("board");
const usb_cdc_impl = @import("usb_cdc_impl");
const rcc = @import("rcc");
const i2c_commands = @import("i2c_commands");
const spi_commands = @import("spi_commands");
const trng_commands = @import("trng_commands");
const crc_commands = @import("crc_commands");
const veml7700_commands = @import("veml7700_commands");
const scd4x_commands = @import("scd4x_commands");
const rng = @import("rng");
const crc = @import("crc");
const rtc_commands = @import("rtc_commands");

const shell_init = shell.ShellInit{
    .max_commands = 50,
    .max_parameters = 10,
    .max_parameter_length = 50,
    .max_command_length = 100,
    .history_length = 20,
    .source_init = &.{
        shell.ShellSourceInit{
            .writer = &usart_writer.usart_writer.writer,
            .echo_func = board.shellWriteCharDma
        },
        shell.ShellSourceInit{
            .writer = &usb_writer.usb_writer.writer,
            .echo_func = cdcWriteChar
        }
    }
};

const rng_commands: trng_commands.Rng = .{
    .gen = &trngGen,
    .init = &trngInit
};

const crc_generators: crc_commands.Generators = .{
    .crc8 = null,
    .crc16 = null,
    .crc32 = &crc32
};

fn crc32(data:[]const u8) u32 {
    return crc.crc.crc32(data);
}

fn trngGen(data: []u32) bool {
    return rng.rng.generate(data);
}

fn trngInit(seed: usize) void {
    _ = seed;
}

fn cdcWriteChar(c: u8) void {
    usb_cdc_impl.txChar(c);
    usb_cdc_impl.flush();
}

fn cdcRxCallback(data: []const u8) void {
    for (data) |c| {
        hal.sh.processChar(1, c);
    }
}

export fn main() callconv(.c) noreturn {
    const a = allocator.buildAllocator();

    usb_cdc_impl.init(.pll1q, &cdcRxCallback, 10240, a) catch { while (true){} };

    usb_writer.usb_writer.writeCharFunc = usb_cdc_impl.txChar;
    usb_writer.usb_writer.writeFlushFunc = usb_cdc_impl.flush;

    board.usartDmaInit(10*1024, a) catch { while (true){} };

    hal.sh = shell.Shell.init(&shell_init, a) catch { while (true){} };
    system_commands.registerCommands(hal.sh) catch { while (true){} };
    flash_commands.registerCommands(hal.sh) catch { while (true){} };
    i2c_commands.registerCommands(hal.sh, hal.i2cScan) catch { while (true){} };
    spi_commands.registerCommands(hal.sh, hal.spiSendReceive) catch { while (true){} };
    trng_commands.registerCommands(hal.sh, &rng_commands) catch { while (true){} };
    crc_commands.registerCommands(hal.sh, &crc_generators) catch { while (true){} };
    veml7700_commands.registerCommands(hal.sh, &hal.veml_device) catch { while (true){} };
    scd4x_commands.registerCommands(hal.sh, &hal.scd_device) catch { while (true){} };
    rtc_commands.registerCommands(hal.sh) catch { while (true){} };

    _ = usart_writer.usart_writer.writer.write(hal.getResetCause()) catch { while (true){} };

    hal.startTimer();

    while (true) {
        asm volatile ("wfi");
        hal.wdtReset();
        hal.sh.handler() catch { while (true){} };
        if (hal.timer_interrupt) {
            hal.timer_interrupt = false;
            hal.ledToggle();
        }
    }
}
