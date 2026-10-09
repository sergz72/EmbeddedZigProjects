const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabi,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 }
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

    const rcc = b.addModule("rcc", .{
        .root_source_file = b.path("../lib/rcc.zig"),
        .target = target,
        .optimize = optimize
    });

    const nvic = b.addModule("nvic", .{
        .root_source_file = b.path("../../lib/nvic.zig"),
        .target = target,
        .optimize = optimize
    });

    const flash = b.addModule("flash", .{
        .root_source_file = b.path("../lib/flash.zig"),
        .target = target,
        .optimize = optimize
    });

    const usart = b.addModule("usart", .{
        .root_source_file = b.path("../lib/usart.zig"),
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

    const timer = b.addModule("timer", .{
        .root_source_file = b.path("../lib/timer.zig"),
        .target = target,
        .optimize = optimize
    });

    const sdram = b.addModule("sdram", .{
        .root_source_file = b.path("../../../common_lib/memory/sdram.zig"),
        .target = target,
        .optimize = optimize
    });

    const fmc = b.addModule("fmc", .{
        .root_source_file = b.path("../lib/fmc.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "sdram", .module = sdram }
        },
    });

    const ltdc = b.addModule("ltdc", .{
        .root_source_file = b.path("../lib/ltdc.zig"),
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

    const usart_writer = b.addModule("usart_writer", .{
        .root_source_file = b.path("../../../common_lib/usart_writer.zig"),
        .target = target,
        .optimize = optimize
    });

    const board = b.addModule("board", .{
        .root_source_file = b.path("../lib/f429i_discovery.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cpu", .module = cpu },
            .{ .name = "rcc", .module = rcc },
            .{ .name = "gpio", .module = gpio },
            .{ .name = "nvic", .module = nvic },
            .{ .name = "flash", .module = flash },
            .{ .name = "usart", .module = usart },
            .{ .name = "fmc", .module = fmc },
            .{ .name = "sdram", .module = sdram },
            .{ .name = "ltdc", .module = ltdc },
            .{ .name = "interrupts", .module = interrupts },
            .{ .name = "usart_writer", .module = usart_writer },
            .{ .name = "system_timer", .module = system_timer }
        },
    });

    const hal = b.addModule("hal", .{
        .root_source_file = b.path("src/hal.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cpu", .module = cpu },
            .{ .name = "rcc", .module = rcc },
            .{ .name = "board", .module = board },
            .{ .name = "timer", .module = timer },
            .{ .name = "shell", .module = shell },
            .{ .name = "nvic", .module = nvic },
            .{ .name = "interrupts", .module = interrupts }
        },
    });

    const exe = b.addExecutable(.{
        .name = "stm32f429i_discovery_test.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "shell", .module = shell },
                .{ .name = "board", .module = board },
                .{ .name = "usart_writer", .module = usart_writer },
                .{ .name = "hal", .module = hal },
                .{ .name = "allocator", .module = allocator }
            },
        }),
    });

    exe.entry = .{ .symbol_name = "Reset_Handler" };
    exe.link_gc_sections = true;
    exe.link_function_sections = true;
    exe.link_data_sections = true;
    //exe.lto = .full;                     // Whole-program optimization & inlining

    exe.root_module.addAssemblyFile(b.path("../startup_stm32f429xx.s"));

    exe.setLinkerScript(b.path("../STM32F429xx_FLASH.ld"));

    b.installArtifact(exe);

    const size_report = b.addSystemCommand(&.{ "llvm-size-22" });
    size_report.addArtifactArg(exe);

    b.getInstallStep().dependOn(&size_report.step);
}
