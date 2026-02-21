const std = @import("std");

const c = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});

const window_width: u32 = 800;
const window_height: u32 = 600;

// TODO: load shader from file
const vertexShaderSource: [:0]const u8 =
    \\#version 330 core
    \\layout (location = 0) in vec3 aPos;
    \\void main()
    \\{
    \\  gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    \\}
;
const fragmentShaderSource: [:0]const u8 =
    \\#version 330 core
    \\out vec4 FragColor;
    \\void main()
    \\{
    \\  FragColor = vec4(0.8, 0.8, 0.8, 1.0);
    \\}
;

pub fn main() void {
    if (c.glfwInit() == 0) {
        std.debug.print("GLFW init failed.\n", .{});
        return;
    }
    defer c.glfwTerminate();

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
    c.glfwWindowHint(c.GLFW_SAMPLES, 8);

    const window = c.glfwCreateWindow(
        window_width,
        window_height,
        "Hello, OpenGL!",
        null,
        null,
    );
    if (window == null) {
        std.debug.print("Window create failed.\n", .{});
        return;
    }

    c.glfwMakeContextCurrent(window);
    _ = c.glfwSetFramebufferSizeCallback(window, framebufferSizeCallback);

    const loader: c.GLADloadproc = @ptrCast(&c.glfwGetProcAddress);
    if (c.gladLoadGLLoader(loader) == 0) {
        std.debug.print("GLAD load failed.\n", .{});
        return;
    }

    _ = c.glEnable(c.GL_MULTISAMPLE);

    // TODO: code optimize
    const vertexShader: u32 = c.glCreateShader(c.GL_VERTEX_SHADER);
    c.glShaderSource(vertexShader, 1, &vertexShaderSource.ptr, null);
    c.glCompileShader(vertexShader);

    var success: i32 = 0;
    var infoLog: [512]u8 = undefined;
    var logLength: i32 = 0;

    c.glGetShaderiv(vertexShader, c.GL_COMPILE_STATUS, &success);
    if (success == 0) {
        c.glGetShaderInfoLog(
            vertexShader,
            infoLog.len,
            &logLength,
            infoLog[0..].ptr,
        );
        std.debug.print("Shader compile failed.\n{s}", .{infoLog[0..@intCast(logLength)]});

        return;
    }

    const fragmentShader: u32 = c.glCreateShader(c.GL_FRAGMENT_SHADER);
    c.glShaderSource(fragmentShader, 1, &fragmentShaderSource.ptr, null);
    c.glCompileShader(fragmentShader);

    c.glGetShaderiv(fragmentShader, c.GL_COMPILE_STATUS, &success);
    if (success == 0) {
        c.glGetShaderInfoLog(
            fragmentShader,
            infoLog.len,
            &logLength,
            infoLog[0..].ptr,
        );
        std.debug.print("Shader compile failed.\n{s}", .{infoLog[0..@intCast(logLength)]});

        return;
    }

    const shaderProgram: u32 = c.glCreateProgram();
    c.glAttachShader(shaderProgram, vertexShader);
    c.glAttachShader(shaderProgram, fragmentShader);
    c.glLinkProgram(shaderProgram);

    c.glGetProgramiv(shaderProgram, c.GL_LINK_STATUS, &success);
    if (success == 0) {
        c.glGetProgramInfoLog(
            shaderProgram,
            infoLog.len,
            &logLength,
            infoLog[0..].ptr,
        );
        std.debug.print("Program link failed.\n{s}", .{infoLog[0..@intCast(logLength)]});

        return;
    }

    c.glDeleteShader(vertexShader);
    c.glDeleteShader(fragmentShader);

    const vertices = [_]f32{
        -0.5, -0.5, 0.0, // left
        0.5, -0.5, 0.0, // right
        0.0, 0.5, 0.0, //top
    };

    var vao: u32 = 0;
    var vbo: u32 = 0;

    c.glGenVertexArrays(1, &vao);
    c.glGenBuffers(1, &vbo);

    c.glBindVertexArray(vao);

    c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);
    c.glBufferData(
        c.GL_ARRAY_BUFFER,
        @sizeOf(@TypeOf(vertices)),
        vertices[0..].ptr,
        c.GL_STATIC_DRAW,
    );

    c.glVertexAttribPointer(
        0,
        3,
        c.GL_FLOAT,
        c.GL_FALSE,
        3 * @sizeOf(f32),
        @ptrFromInt(0),
    );
    c.glEnableVertexAttribArray(0);

    c.glBindBuffer(c.GL_ARRAY_BUFFER, 0);

    c.glBindVertexArray(0);

    while (c.glfwWindowShouldClose(window) == 0) {
        processInput(window);

        c.glClearColor(0.2, 0.4, 0.6, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        c.glUseProgram(shaderProgram);
        c.glBindVertexArray(vao);
        c.glDrawArrays(c.GL_TRIANGLES, 0, 3);

        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }
}

fn framebufferSizeCallback(_: ?*c.GLFWwindow, width: i32, height: i32) callconv(.c) void {
    c.glViewport(0, 0, width, height);
}

fn processInput(window: ?*c.GLFWwindow) void {
    if (c.glfwGetKey(window, c.GLFW_KEY_ESCAPE) == c.GLFW_PRESS)
        c.glfwSetWindowShouldClose(window, 1);
}
