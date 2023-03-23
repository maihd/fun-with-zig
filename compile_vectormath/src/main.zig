const std = @import("std");
const vectormath = @cImport({
    @cDefine("VECTORMATH_SIMD_ENABLE", "0");
    @cInclude("vectormath_temp.h");
});

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    // const v2 = vectormath.vec2_new(1.0, 2.0);
    const v2 = vectormath.vec2{ .x = 1.0, .y = 2.0 };
    try stdout.print("v2 = ({d:0.2}, {d:0.2})", .{ v2.x, v2.y });

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
