const std = @import("std");

pub fn build(b: *std.Build) !void {
    var riscv_features_add = std.Target.Cpu.Feature.Set.empty;
    const riscv_features = std.Target.riscv.Feature;

    riscv_features_add.addFeature(@intFromEnum(riscv_features.i));
    riscv_features_add.addFeature(@intFromEnum(riscv_features.m));
    riscv_features_add.addFeature(@intFromEnum(riscv_features.a));
    riscv_features_add.addFeature(@intFromEnum(riscv_features.c));     // Compressed Instructions
    riscv_features_add.addFeature(@intFromEnum(riscv_features.f));
    riscv_features_add.addFeature(@intFromEnum(riscv_features.zicsr));
    riscv_features_add.addFeature(@intFromEnum(riscv_features.relax));

    var riscv_features_sub = std.Target.Cpu.Feature.Set.empty;
    riscv_features_sub.addFeature(@intFromEnum(riscv_features.d));
    riscv_features_sub.addFeature(@intFromEnum(riscv_features.zcf));

    const target = b.resolveTargetQuery(.{
        .cpu_arch = .riscv32,
        .os_tag = .freestanding,
        .abi = .ilp32,
        .cpu_features_add = riscv_features_add,
        .cpu_features_sub = riscv_features_sub
    });

    const optimize = b.standardOptimizeOption(.{});

    const rcc = b.addModule("rcc", .{
        .root_source_file = b.path("../lib/rcc.zig"),
        .target = target,
        .optimize = optimize
    });

    const cpu = b.addModule("cpu", .{
        .root_source_file = b.path("../../ch32lib/cpu.zig"),
        .target = target,
        .optimize = optimize
    });

    const gpio = b.addModule("gpio", .{
        .root_source_file = b.path("../lib/gpio.zig"),
        .target = target,
        .optimize = optimize
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

    const spi = b.addModule("spi", .{
        .root_source_file = b.path("../lib/spi.zig"),
        .target = target,
        .optimize = optimize
    });

    const timer = b.addModule("timer", .{
        .root_source_file = b.path("../lib/timer.zig"),
        .target = target,
        .optimize = optimize
    });

    const eth = b.addModule("eth", .{
        .root_source_file = b.path("../lib/eth.zig"),
        .target = target,
        .optimize = optimize
    });

    const eth_driver = b.addModule("eth_driver", .{
        .root_source_file = b.path("../lib/eth_driver.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "eth", .module = eth },
            .{ .name = "gpio", .module = gpio }
        },
    });

    const simple_allocator = b.addModule("simple_allocator", .{
       .root_source_file = b.path("../../../common_lib/simple_allocator.zig"),
       .target = target,
       .optimize = optimize
    });

    const allocator = b.addModule("allocator", .{
        .root_source_file = b.path("../../ch32lib/allocator.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "simple_allocator", .module = simple_allocator },
        },
    });

    // const allocator = b.addModule("allocator", .{
    //     .root_source_file = b.path("../lib/fb_allocator.zig"),
    //     .target = target,
    //     .optimize = optimize
    // });

    const usart_writer = b.addModule("usart_writer", .{
        .root_source_file = b.path("../../../common_lib/usart_writer.zig"),
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

    const hal = b.addModule("hal", .{
        .root_source_file = b.path("src/hal.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "rcc", .module = rcc },
            .{ .name = "gpio", .module = gpio },
            .{ .name = "afio", .module = afio },
            .{ .name = "system_timer", .module = system_timer },
            .{ .name = "usart", .module = usart },
            .{ .name = "cpu", .module = cpu },
            .{ .name = "pfic", .module = pfic },
            .{ .name = "interrupts", .module = interrupts },
            .{ .name = "spi", .module = spi },
            .{ .name = "timer", .module = timer },
            .{ .name = "eth_driver", .module = eth_driver },
            .{ .name = "shell", .module = shell },
            .{ .name = "usart_writer", .module = usart_writer }
        },
    });

    const system_commands = b.addModule("system_commands", .{
        .root_source_file = b.path("src/system_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "allocator", .module = allocator },
            .{ .name = "shell", .module = shell },
            .{ .name = "spi", .module = spi },
            .{ .name = "utils", .module = utils }
        }
    });

    const riscv_exe = b.addExecutable(.{
        .name = "iot_device_host_ch32v307.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "system_timer", .module = system_timer },
                .{ .name = "usart_writer", .module = usart_writer },
                .{ .name = "shell", .module = shell },
                .{ .name = "allocator", .module = allocator },
                .{ .name = "hal", .module = hal },
                .{ .name = "usart", .module = usart },
                .{ .name = "system_commands", .module = system_commands }
            },
        }),
    });

    riscv_exe.link_gc_sections = true;
    riscv_exe.link_function_sections = true;
    riscv_exe.link_data_sections = true;
    riscv_exe.lto = .full;                     // Whole-program optimization & inlining

    riscv_exe.root_module.addAssemblyFile(b.path("../startup_ch32v30x_D8C.S"));

    riscv_exe.setLinkerScript(b.path("../Link_192_128.ld"));

    b.installArtifact(riscv_exe);

    const riscv_size_report = b.addSystemCommand(&.{ "llvm-size-22" });
    riscv_size_report.addArtifactArg(riscv_exe);

    b.getInstallStep().dependOn(&riscv_size_report.step);
}
