const std = @import("std");

pub fn build(b: *std.Build) !void {
    const Target = std.Target.x86;
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .x86,
        .os_tag = .freestanding,
        .abi = .none,
        .cpu_features_add = Target.featureSet(&.{.soft_float}),
        .cpu_features_sub = Target.featureSet(&.{ .avx, .avx2, .sse, .sse2, .mmx }),
    });
    const optimize = b.standardOptimizeOption(.{});

    const os = b.addExecutable(.{
        .name = "os.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .code_model = .kernel,
        }),
    });
    os.setLinkerScript(b.path("src/linker.ld"));
    b.installArtifact(os);

    const os_path = os.getEmittedBin();
    const qemu_cmd = b.addSystemCommand(&.{
        "qemu-system-x86_64",
        "-display",
        "sdl",
    });
    qemu_cmd.addArg("-kernel");
    qemu_cmd.addFileArg(os_path);
    qemu_cmd.step.dependOn(b.getInstallStep());

    const run_cmd = b.addRunArtifact(os);
    run_cmd.step.dependOn(&qemu_cmd.step);

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the os");
    run_step.dependOn(&run_cmd.step);
}
