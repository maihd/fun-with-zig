const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        if (gpa.deinit()) {
            @panic("Memory leaks occured!");
        }
    }

    var message = std.ArrayList(u8).init(allocator);
    defer message.deinit();

    try message.append('H');
    try message.append('e');
    try message.append('l');
    try message.append('l');
    try message.append('o');
    try message.append(' ');
    try message.append('W');
    try message.append('o');
    try message.append('r');
    try message.append('l');
    try message.append('d');
    try message.append('!');

    var redundant = "Thing need to be removed!";
    try message.appendSlice(redundant);
    try message.resize(message.items.len - redundant.len);

    std.debug.print("{s}\n", .{ message.items });
}