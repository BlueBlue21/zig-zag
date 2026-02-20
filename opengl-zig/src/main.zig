const std = @import("std");

const c = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});

const window_width: i32 = 800;
const window_height: i32 = 600;

pub fn main() void {
    if (c.glfwInit() == 0) {
        std.debug.print("GLFW init failed.\n", .{});
        return;
    }
    defer c.glfwTerminate();

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    const window = c.glfwCreateWindow(window_width, window_height, "Hello, OpenGL!", null, null);
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

    c.glViewport(0, 0, window_width, window_height);
    _ = c.glfwSetFramebufferSizeCallback(window, framebufferSizeCallback);

    while (c.glfwWindowShouldClose(window) == 0) {
        processInput(window);

        c.glClearColor(0.2, 0.3, 0.3, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        const vertices = [_]f32{
            -0.5, -0.5, 0.0, // left
            0.5, -0.5, 0.0, // right
            0.0, 0.5, 0.0, //top
        };

        var vbo: u32 = undefined;
        c.glGenBuffers(1, &vbo);
        c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);

        c.glBufferData(
            c.GL_ARRAY_BUFFER,
            @sizeOf(@TypeOf(vertices)),
            &vertices,
            c.GL_STATIC_DRAW,
        );

        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }
}

fn framebufferSizeCallback(_: ?*c.GLFWwindow, width: i32, height: i32) callconv(.c) void {
    c.glViewport(0, 0, width, height);
}

fn processInput(window: ?*c.GLFWwindow) callconv(.c) void {
    if (c.glfwGetKey(window, c.GLFW_KEY_ESCAPE) == c.GLFW_PRESS)
        c.glfwSetWindowShouldClose(window, 1);
}
