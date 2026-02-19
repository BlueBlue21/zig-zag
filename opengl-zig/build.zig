const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) !void {
    if (builtin.os.tag != .windows) {
        return error.UnsupportedOS;
    }

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "opengl_zig",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    // special thanks to radarroark/zigl
    exe.root_module.link_libc = true;
    exe.root_module.addIncludePath(b.path("include"));
    exe.root_module.addCSourceFile(.{ .file = b.path("src/glad/glad.c") });

    exe.root_module.linkSystemLibrary("gdi32", .{});
    exe.root_module.linkSystemLibrary("user32", .{});
    exe.root_module.linkSystemLibrary("shell32", .{});
    exe.root_module.linkSystemLibrary("opengl32", .{});

    exe.root_module.addCMacro("_GLFW_WIN32", "1");
    exe.root_module.addCSourceFiles(.{
        .files = &[_][]const u8{
            "src/GLFW/context.c",
            "src/GLFW/egl_context.c",
            "src/GLFW/init.c",
            "src/GLFW/input.c",
            "src/GLFW/monitor.c",
            "src/GLFW/null_init.c",
            "src/GLFW/null_joystick.c",
            "src/GLFW/null_monitor.c",
            "src/GLFW/null_window.c",
            "src/GLFW/osmesa_context.c",
            "src/GLFW/platform.c",
            "src/GLFW/vulkan.c",
            "src/GLFW/window.c",

            "src/GLFW/wgl_context.c",
            "src/GLFW/win32_init.c",
            "src/GLFW/win32_joystick.c",
            "src/GLFW/win32_module.c",
            "src/GLFW/win32_monitor.c",
            "src/GLFW/win32_thread.c",
            "src/GLFW/win32_time.c",
            "src/GLFW/win32_window.c",
        },
    });

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });
    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_exe_tests.step);
}
