const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabihf,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m33 }
    });

    const optimize = b.standardOptimizeOption(.{});

    const cpu = b.addModule("cpu", .{
        .root_source_file = b.path("../lib/cpu.zig"),
        .target = target,
        .optimize = optimize
    });

    const gpio = b.addModule("gpio", .{
        .root_source_file = b.path("../lib/gpio.zig"),
        .target = target,
        .optimize = optimize
    });

    const dbgmcu = b.addModule("dbgmcu", .{
        .root_source_file = b.path("../lib/dbgmcu.zig"),
        .target = target,
        .optimize = optimize
    });

    const pwr = b.addModule("pwr", .{
        .root_source_file = b.path("../lib/pwr.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "dbgmcu", .module = dbgmcu }
        },
    });

    const icache = b.addModule("icache", .{
        .root_source_file = b.path("../lib/icache.zig"),
        .target = target,
        .optimize = optimize
    });

    const flash = b.addModule("flash", .{
        .root_source_file = b.path("../lib/flash.zig"),
        .target = target,
        .optimize = optimize
    });

    const rcc = b.addModule("rcc", .{
        .root_source_file = b.path("../lib/rcc.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "pwr", .module = pwr },
            .{ .name = "flash", .module = flash },
            .{ .name = "icache", .module = icache },
        },
    });

    const nvic = b.addModule("nvic", .{
        .root_source_file = b.path("../../lib/nvic.zig"),
        .target = target,
        .optimize = optimize
    });

    const usart = b.addModule("usart", .{
        .root_source_file = b.path("../lib/usart.zig"),
        .target = target,
        .optimize = optimize
    });

    const tim = b.addModule("tim", .{
        .root_source_file = b.path("../lib/tim.zig"),
        .target = target,
        .optimize = optimize
    });

    const gpdma = b.addModule("gpdma", .{
        .root_source_file = b.path("../lib/gpdma.zig"),
        .target = target,
        .optimize = optimize
    });

    const rng = b.addModule("rng", .{
        .root_source_file = b.path("../lib/rng.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "rcc", .module = rcc }
        },
    });

    const crc = b.addModule("crc", .{
        .root_source_file = b.path("../lib/crc.zig"),
        .target = target,
        .optimize = optimize
    });

    const i2c = b.addModule("i2c", .{
        .root_source_file = b.path("../lib/i2c.zig"),
        .target = target,
        .optimize = optimize
    });

    const spi = b.addModule("spi", .{
        .root_source_file = b.path("../lib/spi.zig"),
        .target = target,
        .optimize = optimize
    });

    const usb_device = b.addModule("usb_device", .{
        .root_source_file = b.path("../../../common_lib/usb/usb_device.zig"),
        .target = target,
        .optimize = optimize
    });

    const interrupts = b.addModule("interrupts", .{
        .root_source_file = b.path("../lib/interrupts.zig"),
        .target = target,
        .optimize = optimize
    });

    const usb = b.addModule("usb", .{
        .root_source_file = b.path("../lib/usb.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "usb_device", .module = usb_device },
            .{ .name = "gpio", .module = gpio },
            .{ .name = "rcc", .module = rcc },
            .{ .name = "nvic", .module = nvic },
            .{ .name = "interrupts", .module = interrupts },
            .{ .name = "pwr", .module = pwr }
        },
    });

    const usb_cdc = b.addModule("usb_cdc", .{
        .root_source_file = b.path("../../../common_lib/usb/usb_cdc.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "usb_device", .module = usb_device }
        },
    });

    const system_timer = b.addModule("system_timer", .{
        .root_source_file = b.path("../../lib/system_timer.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cpu", .module = cpu }
        },
    });

    const dma_sender = b.addModule("dma_sender", .{
        .root_source_file = b.path("../../../common_lib/dma_sender.zig"),
        .target = target,
        .optimize = optimize
    });

    const usb_cdc_impl = b.addModule("usb_cdc_impl", .{
        .root_source_file = b.path("../lib/usb/usb_cdc_impl.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "usb", .module = usb },
            .{ .name = "usb_device", .module = usb_device },
            .{ .name = "usb_cdc", .module = usb_cdc },
            .{ .name = "rcc", .module = rcc },
            .{ .name = "system_timer", .module = system_timer },
            .{ .name = "dma_sender", .module = dma_sender },
        },
    });

    const scb = b.addModule("scb", .{
        .root_source_file = b.path("../../lib/scb.zig"),
        .target = target,
        .optimize = optimize
    });

    const usart_writer = b.addModule("usart_writer", .{
        .root_source_file = b.path("../../../common_lib/usart_writer.zig"),
        .target = target,
        .optimize = optimize
    });

    const usb_writer = b.addModule("usb_writer", .{
        .root_source_file = b.path("../../../common_lib/usb_writer.zig"),
        .target = target,
        .optimize = optimize
    });

    const allocator = b.addModule("allocator", .{
        .root_source_file = b.path("../../lib/fb_allocator.zig"),
        .target = target,
        .optimize = optimize
    });

    const shell = b.addModule("shell", .{
        .root_source_file = b.path("../../../common_lib/shell.zig"),
        .target = target,
        .optimize = optimize
    });

    const utils = b.addModule("utils", .{
        .root_source_file = b.path("../../../common_lib/utils.zig"),
        .target = target,
        .optimize = optimize
    });

    const board = b.addModule("board", .{
        .root_source_file = b.path("../lib/nucleo.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cpu", .module = cpu },
            .{ .name = "rcc", .module = rcc },
            .{ .name = "gpio", .module = gpio },
            .{ .name = "flash", .module = flash },
            .{ .name = "system_timer", .module = system_timer },
            .{ .name = "usart_writer", .module = usart_writer },
            .{ .name = "nvic", .module = nvic },
            .{ .name = "usart", .module = usart },
            .{ .name = "interrupts", .module = interrupts },
            .{ .name = "dma_sender", .module = dma_sender },
            .{ .name = "gpdma", .module = gpdma },
            .{ .name = "i2c", .module = i2c },
            .{ .name = "spi", .module = spi },
        },
    });

    const hal = b.addModule("hal", .{
        .root_source_file = b.path("src/hal.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cpu", .module = cpu },
            .{ .name = "board", .module = board },
            .{ .name = "rcc", .module = rcc },
            .{ .name = "tim", .module = tim },
            .{ .name = "nvic", .module = nvic },
            .{ .name = "scb", .module = scb },
            .{ .name = "flash", .module = flash },
            .{ .name = "system_timer", .module = system_timer },
            .{ .name = "interrupts", .module = interrupts },
            .{ .name = "shell", .module = shell },
            .{ .name = "rng", .module = rng },
        },
    });

    const system_commands = b.addModule("system_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/system_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell },
            .{ .name = "allocator", .module = allocator },
            .{ .name = "hal", .module = hal },
            .{ .name = "system_timer", .module = system_timer },
        }
    });

    const flash_commands = b.addModule("flash_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/flash_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell },
            .{ .name = "hal", .module = hal },
            .{ .name = "utils", .module = utils },
        }
    });

    const i2c_commands = b.addModule("i2c_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/i2c_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell }
        }
    });

    const spi_commands = b.addModule("spi_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/spi_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell },
            .{ .name = "utils", .module = utils }
        }
    });

    const trng_commands = b.addModule("trng_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/trng_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell }
        }
    });

    const crc_commands = b.addModule("crc_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/crc_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell },
            .{ .name = "utils", .module = utils }
        }
    });

    const exe = b.addExecutable(.{
        .name = "stm32h563_tests.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "board", .module = board },
                .{ .name = "usart_writer", .module = usart_writer },
                .{ .name = "usb_writer", .module = usb_writer },
                .{ .name = "hal", .module = hal },
                .{ .name = "shell", .module = shell },
                .{ .name = "allocator", .module = allocator },
                .{ .name = "usart_writer", .module = usart_writer },
                .{ .name = "system_commands", .module = system_commands },
                .{ .name = "flash_commands", .module = flash_commands },
                .{ .name = "usb_cdc_impl", .module = usb_cdc_impl },
                .{ .name = "rcc", .module = rcc },
                .{ .name = "i2c_commands", .module = i2c_commands },
                .{ .name = "spi_commands", .module = spi_commands },
                .{ .name = "trng_commands", .module = trng_commands },
                .{ .name = "crc_commands", .module = crc_commands },
                .{ .name = "rng", .module = rng },
                .{ .name = "crc", .module = crc }
            },
        }),
    });

    exe.entry = .{ .symbol_name = "Reset_Handler" };
    exe.link_gc_sections = true;
    exe.function_sections = true;
    exe.data_sections = true;
    //exe.lto = .full;                     // Whole-program optimization & inlining

    exe.root_module.addAssemblyFile(b.path("../startup_stm32h563xx.s"));
    exe.root_module.addAssemblyFile(b.path("../../lib/usb_utils.s"));

    exe.setLinkerScript(b.path("../STM32H563xx_FLASH.ld"));

    b.installArtifact(exe);

    const size_report = b.addSystemCommand(&.{ "llvm-size-22" });
    size_report.addArtifactArg(exe);

    b.getInstallStep().dependOn(&size_report.step);
}
