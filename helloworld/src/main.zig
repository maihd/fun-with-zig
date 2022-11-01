const std = @import("std");

pub fn main() void {
    // Zig has no built-in print functions like C's printf
    // More info: https://zig.news/kristoff/where-is-print-in-zig-57e9
    std.debug.print("Hello world!\n", .{});
}
