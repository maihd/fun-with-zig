const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        // Check leaks
        if (gpa.deinit()) {
            @panic("Memory leaks occurred");
        }
    }

    const bytes = try allocator.alloc(u8, 1024);
    defer allocator.free(bytes);
}
