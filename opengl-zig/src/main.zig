const std = @import("std");

const c = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});

pub fn main() void {
    if (c.glfwInit() == 0) {
        std.debug.print("GLFW init failed.\n", .{});
        return;
    }
    defer c.glfwTerminate();

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    const window = c.glfwCreateWindow(1600, 800, "Hello, OpenGL!", null, null);
    if (window == null) {
        std.debug.print("Window create failed.\n", .{});
        return;
    }

    c.glfwMakeContextCurrent(window);
}
