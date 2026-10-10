const hal = @import("hal");
const i2c_memory_commands = @import("i2c_memory_commands");
const spi_memory_commands = @import("spi_memory_commands");
const allocator = @import("allocator");
const shell = @import("shell");
const usart_writer = @import("usart_writer");
//const usb_cdc = @import("usb_cdc");
//const usb_writer = @import("usb_writer");
const spi_memory = @import("spi_memory");

const shell_init = shell.ShellInit{
    .max_commands = 50,
    .max_parameters = 10,
    .max_parameter_length = 50,
    .max_command_length = 100,
    .history_length = 20
};

var led_status: bool = undefined;
var led_counter: usize = undefined;
//var cdc_buffer: [1024]u8 = undefined;

const spi_chip_init: spi_memory.SpiMemoryInit = .{.memory_type = .flash, .address_size = ._3bytes, .spi_transfer = hal.spiFlashTransfer};

fn ledHandler() void {
    if (!hal.timer_interrupt)
        return;
    hal.timer_interrupt = false;
    if (led_counter == 9) {
        led_counter = 0;
        led_status = !led_status;
        if (led_status) {
            hal.ledOn();
        } else {
            hal.ledOff();
        }
    } else {
        led_counter += 1;
    }
}

export fn main() callconv(.c) noreturn {
    //@setRuntimeSafety(false);
    //usb_cdc.USBFS_RCC_Init();
    //usb_cdc.USBFS_Device_Init();

    const a = allocator.buildAllocator();

    hal.sh = shell.Shell.init(&shell_init, a, &usart_writer.usart_writer.writer, hal.usartWrite) catch { while (true){} };
//    hal.sh = shell.Shell.init(&shell_init, a, &usb_writer.usb_writer, usb_writer.usbWrite) catch { while (true){} };

    i2c_memory_commands.registerCommands(hal.sh) catch { while (true){} };
    spi_memory_commands.registerCommands(hal.sh, &spi_chip_init) catch { while (true){} };

    hal.startTimer();

    led_status = false;
    led_counter = 0;

    while (true) {
        asm volatile ("wfi");
        // while (true) {
        //     const c = usb_cdc.CDC_getch();
        //     if (c == -1)
        //         break;
        //     hal.sh.processChar(@intCast(c));
        // }
        hal.sh.handler() catch { while (true){} };
        ledHandler();
    }
}
