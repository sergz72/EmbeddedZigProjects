const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabihf,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m33 }
    });

    const optimize = b.standardOptimizeOption(.{});

    const struct_modify = b.addModule("modify_struct", .{
        .root_source_file = b.path("../../../common_lib/struct_modify.zig"),
        .target = target,
        .optimize = optimize
    });

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

    const pwr = b.addModule("pwr", .{
        .root_source_file = b.path("../lib/pwr.zig"),
        .target = target,
        .optimize = optimize
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

    const lpdma = b.addModule("lpdma", .{
        .root_source_file = b.path("../lib/lpdma.zig"),
        .target = target,
        .optimize = optimize
    });

    const i2c = b.addModule("i2c", .{
        .root_source_file = b.path("../lib/i2c.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "struct_modify", .module = struct_modify }
        },
    });

    const spi = b.addModule("spi", .{
        .root_source_file = b.path("../lib/spi.zig"),
        .target = target,
        .optimize = optimize
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

    const interrupts = b.addModule("interrupts", .{
        .root_source_file = b.path("../lib/interrupts.zig"),
        .target = target,
        .optimize = optimize
    });

    const system_timer = b.addModule("system_timer", .{
        .root_source_file = b.path("../../lib/system_timer.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cpu", .module = cpu }
        },
    });

    const usart_writer = b.addModule("usart_writer", .{
        .root_source_file = b.path("../../../common_lib/usart_writer.zig"),
        .target = target,
        .optimize = optimize
    });

    const dma_sender = b.addModule("dma_sender", .{
        .root_source_file = b.path("../../../common_lib/dma_sender.zig"),
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
            .{ .name = "lpdma", .module = lpdma },
            .{ .name = "i2c", .module = i2c },
            .{ .name = "spi", .module = spi },
            .{ .name = "dma_sender", .module = dma_sender }
        },
    });

    const exe = b.addExecutable(.{
        .name = "stm32c5a3_blink.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "system_timer", .module = system_timer },
                .{ .name = "board", .module = board },
                .{ .name = "rcc", .module = rcc },
                .{ .name = "tim", .module = tim },
                .{ .name = "cpu", .module = cpu },
                .{ .name = "nvic", .module = nvic },
                .{ .name = "interrupts", .module = interrupts },
            },
        }),
    });

    exe.entry = .{ .symbol_name = "Reset_Handler" };
    exe.link_gc_sections = true;
    exe.function_sections = true;
    exe.data_sections = true;
    //exe.lto = .full;                     // Whole-program optimization & inlining

    exe.root_module.addAssemblyFile(b.path("../startup_stm32c5a3xg.s"));

    exe.setLinkerScript(b.path("../STM32C5A3xg_FLASH.ld"));

    b.installArtifact(exe);

    const size_report = b.addSystemCommand(&.{ "llvm-size-22" });
    size_report.addArtifactArg(exe);

    b.getInstallStep().dependOn(&size_report.step);
}
