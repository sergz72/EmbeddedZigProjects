const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabi,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m23 }
    });

    const optimize = b.standardOptimizeOption(.{});

    const rcu = b.addModule("rcu", .{
        .root_source_file = b.path("../lib/rcu.zig"),
        .target = target,
        .optimize = optimize
    });

    const cpu = b.addModule("cpu", .{
        .root_source_file = b.path("../../lib/cpu.zig"),
        .target = target,
        .optimize = optimize
    });

    const gpio = b.addModule("gpio", .{
        .root_source_file = b.path("../lib/gpio.zig"),
        .target = target,
        .optimize = optimize
    });

    const timer = b.addModule("timer", .{
        .root_source_file = b.path("../lib/timer.zig"),
        .target = target,
        .optimize = optimize
    });

    const usart = b.addModule("usart", .{
        .root_source_file = b.path("../lib/usart.zig"),
        .target = target,
        .optimize = optimize
    });

    const nvic = b.addModule("nvic", .{
        .root_source_file = b.path("../../lib/nvic.zig"),
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
            .{ .name = "cpu", .module = cpu },
            .{ .name = "nvic", .module = nvic }
        },
    });

    const exe = b.addExecutable(.{
        .name = "gd32e230_blink.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "timer", .module = timer },
                .{ .name = "usart", .module = usart },
                .{ .name = "rcu", .module = rcu },
                .{ .name = "gpio", .module = gpio },
                .{ .name = "system_timer", .module = system_timer },
                .{ .name = "cpu", .module = cpu },
                .{ .name = "nvic", .module = nvic },
                .{ .name = "interrupts", .module = interrupts }
            },
        }),
    });

    exe.entry = .{ .symbol_name = "Reset_Handler" };
    exe.link_gc_sections = true;
    exe.link_function_sections = true;
    exe.link_data_sections = true;
    exe.lto = .full;                     // Whole-program optimization & inlining

    exe.root_module.addAssemblyFile(b.path("../startup_gd32e23x.S"));

    exe.setLinkerScript(b.path("../gd32e230x8_flash.ld"));

    b.installArtifact(exe);

    const size_report = b.addSystemCommand(&.{ "llvm-size-22" });
    size_report.addArtifactArg(exe);

    b.getInstallStep().dependOn(&size_report.step);
}
