const hal = @import("hal");
const shell = @import("shell");
const allocator = @import("allocator");
const usart_writer = @import("usart_writer");
const usb_cdc_impl = @import("usb_cdc_impl");
const system_commands = @import("system_commands");
const flash_commands = @import("flash_commands");
const trng_commands = @import("trng_commands");
const crc_commands = @import("crc_commands");
const rtc_commands = @import("rtc_commands");
const rng = @import("rng");
const crc = @import("crc");
const usb_writer = @import("usb_writer");
const system_timer = @import("system_timer");

const shell_init = shell.ShellInit{
    .max_commands = 50,
    .max_parameters = 10,
    .max_parameter_length = 50,
    .max_command_length = 100,
    .history_length = 20,
    .source_init = &.{
        shell.ShellSourceInit{
            .writer = &usart_writer.usart_writer.writer,
            .echo_func = hal.usartWrite
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
    return crc.crc.calculate(data);
}

fn trngGen(data: []u32) bool {
    rng.rng.generate(data) catch return false;
    return true;
}

fn trngInit(seed: usize) void {
    _ = seed;
}

inline fn timerHandler() void {
    if (!hal.timer_interrupt)
        return;
    hal.timer_interrupt = false;
    hal.ledToggle();
}

fn cdcRxCallback(data: []const u8) void {
    usb_cdc_impl.tx(data);
    //for (data) |c| {
    //    hal.sh.processChar(1, c);
    //}
}

export fn main() callconv(.c) noreturn {
    const a = allocator.buildAllocator();

    const ok = usb_cdc_impl.init(&cdcRxCallback, 10240, a) catch {
        while (true){
            system_timer.delayms(100);
            hal.ledToggle();
        }
    };
    if (!ok) {
        while (true) {
            system_timer.delayms(300);
            hal.ledToggle();
        }
    }

    //usb_writer.usb_writer.writeCharFunc = usb_cdc_impl.txChar;
    //usb_writer.usb_writer.writeFlushFunc = usb_cdc_impl.flush;

    hal.sh = shell.Shell.init(&shell_init, a) catch { while (true){} };
    system_commands.registerCommands(hal.sh) catch { while (true){} };
    flash_commands.registerCommands(hal.sh) catch { while (true){} };
    trng_commands.registerCommands(hal.sh, &rng_commands) catch { while (true){} };
    crc_commands.registerCommands(hal.sh, &crc_generators) catch { while (true){} };
    rtc_commands.registerCommands(hal.sh) catch { while (true){} };

    _ = usart_writer.usart_writer.writer.write(hal.getResetCause()) catch { while (true){} };

    hal.startTimer();

    while (true) {
        asm volatile ("wfi");
        hal.wdtReset();
        hal.sh.handler() catch { while (true){} };
        timerHandler();
    }
}
