const std = @import("std");

const c = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});

const WINDOW_WIDTH: i32 = 800;
const WINDOW_HIGHT: i32 = 600;

pub fn main() void {
    if (c.glfwInit() == 0) {
        std.debug.print("GLFW init failed.\n", .{});
        return;
    }
    defer c.glfwTerminate();

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    const window = c.glfwCreateWindow(WINDOW_WIDTH, WINDOW_HIGHT, "Hello, OpenGL!", null, null);
    if (window == null) {
        std.debug.print("Window create failed.\n", .{});
        return;
    }

    c.glfwMakeContextCurrent(window);

    const loader: c.GLADloadproc = @ptrCast(&c.glfwGetProcAddress);
    if (c.gladLoadGLLoader(loader) == 0) {
        std.debug.print("GLAD init failed.\n", .{});
        return;
    }

    c.glViewport(0, 0, WINDOW_WIDTH, WINDOW_HIGHT);
    _ = c.glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    while (c.glfwWindowShouldClose(window) == 0) {
        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }
}

fn framebuffer_size_callback(_: ?*c.GLFWwindow, width: i32, height: i32) callconv(.c) void {
    c.glViewport(0, 0, width, height);
}
