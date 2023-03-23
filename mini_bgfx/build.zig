const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("mini_bgfx", "src/main.zig");

    exe.addIncludePath("src");

    // SDL
    const sdl_path = thisDir() ++ "/lib/SDL2-2.0.14/";
    exe.addIncludePath(sdl_path ++ "include");
    exe.addLibraryPath(sdl_path ++ "lib/x64");
    b.installBinFile(sdl_path ++ "lib/x64/SDL2.dll", "SDL2.dll");
    exe.linkSystemLibrary("sdl2");

    // bgfx and family
    const bgfx_path = "lib/bgfx/";
    exe.addIncludePath(bgfx_path ++ "include");
    exe.addLibraryPath(bgfx_path ++ "lib/x64");
    exe.addObjectFile(bgfx_path ++ "lib/x64/libbx.a");
    exe.addObjectFile(bgfx_path ++ "lib/x64/libbimg.a");
    exe.addObjectFile(bgfx_path ++ "lib/x64/libbgfx.a");

    exe.linkLibC();
    exe.linkLibCpp();
    exe.linkSystemLibrary("winmm");
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("opengl32");

    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}