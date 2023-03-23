const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("c_bindings", "src/main.zig");
    exe.addCSourceFile("src/greeting.c", &[_][]const u8 {});
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.linkLibC();
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}

fn rmem(b: *std.build.Builder, target: std.zig.CrossTarget, mode: std.builtin.Mode) *std.build.LibExeObjStep {
    const rmem_dir = @thisDir() ++ "/libs/rmem";
    const step = b.addStaticLibrary("rmem", null);
    step.setBuildMode(mode);
    step.setTarget(target);

    // Compile sources

    const c_flags = &[_][]const u8{
        // mingw
        // "-Wl,--wrap=_malloc_init--export-all-symbols"

        //"-std=gnu99",
        //"-DPLATFORM_DESKTOP",
        //"-DGL_SILENCE_DEPRECATION=199309L",
        //"-fno-sanitize=undefined", // https://github.com/raysan5/raylib/issues/1891
    };

    step.linkLibC();
    step.addIncludePath(rmem_dir ++ "/inc");
    step.addCSourceFiles(&.{
        rmem_dir ++ "/src/rmem_get_module_info.cpp",
        rmem_dir ++ "/src/rmem_hook.cpp",
        rmem_dir ++ "/src/rmem_lib.cpp",
    }, c_flags);

    const target_os = step.target.toTarget().os.tag;
    if (target_os == .windows) {
        step.addCSourceFiles(&.{
            rmem_dir ++ "/src/rmem_wrap_win.cpp"
        }, c_flags);
    } // No support xbox yet

    // Link system libraries

    switch (target_os) {
        .windows => {
            step.linkSystemLibrary("psapi");
            step.linkSystemLibrary("gdi32");
            step.linkSystemLibrary("opengl32");
        },

        else => {
            // Do nothings
        }
    }

    return step;
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirName(@src().file) orelse ".";
}