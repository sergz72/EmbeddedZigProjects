const std = @import("std");
const rv = std.Target.riscv;

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .riscv32,
        .os_tag = .freestanding,
        .abi = .eabi,
        .cpu_model = .{ .explicit = &rv.cpu.rv32imafc },
        .cpu_features_add = rv.featureSet(&.{ .i, .m, .a, .c, .f, .xwchc, .zicsr, .zifencei }),
    });

    const optimize = b.standardOptimizeOption(.{});

    const cpu = b.addModule("cpu", .{
        .root_source_file = b.path("../lib/cpu.zig"),
        .target = target,
        .optimize = optimize
    });

    const rcc = b.addModule("rcc", .{
        .root_source_file = b.path("../lib/rcc.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cpu", .module = cpu }
        },
    });

    const gpio_common = b.addModule("gpio_common", .{
        .root_source_file = b.path("../../ch32lib/gpio_common.zig"),
        .target = target,
        .optimize = optimize
    });

    const gpio = b.addModule("gpio", .{
        .root_source_file = b.path("../lib/gpio.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "gpio_common", .module = gpio_common }
        },
    });

    const afio = b.addModule("afio", .{
        .root_source_file = b.path("../lib/afio.zig"),
        .target = target,
        .optimize = optimize
    });

    const pfic = b.addModule("pfic", .{
        .root_source_file = b.path("../../ch32lib/pfic.zig"),
        .target = target,
        .optimize = optimize
    });

    const interrupts = b.addModule("interrupts", .{
        .root_source_file = b.path("../lib/interrupts.zig"),
        .target = target,
        .optimize = optimize
    });

    const system_timer = b.addModule("system_timer", .{
        .root_source_file = b.path("../../ch32lib/system_timer64.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cpu", .module = cpu },
            .{ .name = "pfic", .module = pfic }
        },
    });

    const usart = b.addModule("usart", .{
        .root_source_file = b.path("../lib/usart.zig"),
        .target = target,
        .optimize = optimize
    });

    const timer = b.addModule("timer", .{
        .root_source_file = b.path("../lib/timer.zig"),
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

    const iwdg = b.addModule("iwdg", .{
        .root_source_file = b.path("../lib/iwdg.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cpu", .module = cpu }
        },
    });

    const flash = b.addModule("flash", .{
        .root_source_file = b.path("../lib/flash.zig"),
        .target = target,
        .optimize = optimize
    });

    const bkp = b.addModule("bkp", .{
        .root_source_file = b.path("../lib/bkp.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "rcc", .module = rcc }
        },
    });

    const pwr = b.addModule("pwr", .{
        .root_source_file = b.path("../lib/pwr.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "rcc", .module = rcc }
        },
    });

    const generic_rtc = b.addModule("generic_rtc", .{
        .root_source_file = b.path("../../../common_lib/rtc/generic_rtc.zig"),
        .target = target,
        .optimize = optimize
    });

    const rtc = b.addModule("rtc", .{
        .root_source_file = b.path("../lib/rtc.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "rcc", .module = rcc },
            .{ .name = "bkp", .module = bkp },
            .{ .name = "pwr", .module = pwr },
            .{ .name = "generic_rtc", .module = generic_rtc }
        },
    });

    const usb_device = b.addModule("usb_device", .{
        .root_source_file = b.path("../../../common_lib/usb/usb_device.zig"),
        .target = target,
        .optimize = optimize
    });

    const usbfs = b.addModule("usbfs", .{
        .root_source_file = b.path("../lib/usbfs.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "rcc", .module = rcc },
            .{ .name = "gpio", .module = gpio },
            .{ .name = "system_timer", .module = system_timer },
            .{ .name = "pfic", .module = pfic },
            .{ .name = "interrupts", .module = interrupts },
            .{ .name = "usb_device", .module = usb_device },
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
            .{ .name = "usbfs", .module = usbfs },
            .{ .name = "usb_device", .module = usb_device },
            .{ .name = "usb_cdc", .module = usb_cdc },
            .{ .name = "system_timer", .module = system_timer },
            .{ .name = "dma_sender", .module = dma_sender },
        },
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
        .root_source_file = b.path("../../ch32lib/fb_allocator.zig"),
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

    const rtc_commands = b.addModule("rtc_commands", .{
        .root_source_file = b.path("../lib/shell_commands/rtc_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell },
            .{ .name = "generic_rtc", .module = generic_rtc },
            .{ .name = "rtc", .module = rtc }
        }
    });


    const hal = b.addModule("hal", .{
        .root_source_file = b.path("src/hal.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "rcc", .module = rcc },
            .{ .name = "gpio", .module = gpio },
            .{ .name = "afio", .module = afio },
            .{ .name = "system_timer", .module = system_timer },
            .{ .name = "timer", .module = timer },
            .{ .name = "usart", .module = usart },
            .{ .name = "cpu", .module = cpu },
            .{ .name = "pfic", .module = pfic },
            .{ .name = "interrupts", .module = interrupts },
            .{ .name = "usart_writer", .module = usart_writer },
            .{ .name = "shell", .module = shell },
            .{ .name = "rng", .module = rng },
            .{ .name = "crc", .module = crc },
            .{ .name = "flash", .module = flash },
            .{ .name = "iwdg", .module = iwdg },
            .{ .name = "rtc", .module = rtc }
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

    const riscv_exe = b.addExecutable(.{
        .name = "ch32v303_tests.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "hal", .module = hal },
                .{ .name = "shell", .module = shell },
                .{ .name = "allocator", .module = allocator },
                .{ .name = "usart_writer", .module = usart_writer },
                .{ .name = "trng_commands", .module = trng_commands },
                .{ .name = "rng", .module = rng },
                .{ .name = "crc", .module = crc },
                .{ .name = "system_commands", .module = system_commands },
                .{ .name = "flash_commands", .module = flash_commands },
                .{ .name = "crc_commands", .module = crc_commands },
                .{ .name = "rtc_commands", .module = rtc_commands },
                .{ .name = "usb_cdc_impl", .module = usb_cdc_impl },
                .{ .name = "usb_writer", .module = usb_writer },
                .{ .name = "system_timer", .module = system_timer },
            },
        }),
    });

    riscv_exe.link_gc_sections = true;
    riscv_exe.function_sections = true;
    riscv_exe.data_sections = true;
    //riscv_exe.lto = .full;                     // Whole-program optimization & inlining

    riscv_exe.root_module.addAssemblyFile(b.path("../startup_ch32v30x_D8.S"));

    riscv_exe.setLinkerScript(b.path("../Link_3x_cb.ld"));

    b.installArtifact(riscv_exe);

    const riscv_size_report = b.addSystemCommand(&.{ "llvm-size-22" });
    riscv_size_report.addArtifactArg(riscv_exe);

    b.getInstallStep().dependOn(&riscv_size_report.step);
}
