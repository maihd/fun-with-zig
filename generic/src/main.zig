const std = @import("std");

const ListError = error {
    OutOfRange
};

fn List(comptime T: type) type {
    return struct {
        items: []T,
        len: usize,

        const Self = @This();

        fn push(self: *Self, item: T) ListError!void {
            if (self.len > self.items.len) {
                return ListError.OutOfRange;
            }

            self.items[self.len] = item;
            self.len += 1;
        }

        fn pop(self: *Self) ListError!T {
            if (self.len > 0) {
                self.len -= 1;
                return self.items[self.len];
            } else {
                return ListError.OutOfRange;
            }
        }
    };
}

test "List(T)" {
    var buffer: [10]i32 = undefined;
    var list = List(i32) {
        .items = &buffer,
        .len = 0
    };

    try std.testing.expectEqual(list.items.len, 10);

    try list.push(10);
    try std.testing.expectEqual(list.items[0], 10);

    var item = try list.pop();
    try std.testing.expectEqual(item, 10);
}