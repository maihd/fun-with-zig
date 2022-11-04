const std = @import("std");

const DictionaryError = {

};

/// Dictionary
/// Base on C# Dictionary
/// Specify for String only like an real-life dictionary
const Dictionary = struct {
    hashMap: std.StringHashMap([]u8),
    allocator: std.mem.Allocator,

    const Self = @This();

    fn init(allocator: std.mem.Allocator) Self {
        return Self {
            .hashMap = std.StringHashMap([]u8).init(allocator),
            .allocator = allocator,
        };
    }

    fn deinit(self: *Self) void {
        //for (self.hashMap.keyIterator()) |key| {
        //    self.allocator.free(key);
        //}

        var values = self.hashMap.valueIterator();
        while (values.next()) |value| {
            self.allocator.free(value.*);
        }

        self.hashMap.deinit();
    }

    fn add(self: *Self, key: []const u8, value: []const u8) !void {
        //var storingKey = try self.allocator.alloc(u8, key.len);
        var storingValue = try self.allocator.alloc(u8, value.len);

        //std.mem.copy(u8, storingKey, key);
        std.mem.copy(u8, storingValue, value);

        return self.hashMap.put(key, storingValue);
        //return self.hashMap.put(storingKey, storingValue);
    }

    fn get(self: *Self, key: []const u8) ?[]const u8 {
        return self.hashMap.get(key);
    }
};

test "simple test" {
    var allocator = std.testing.allocator;
    var dictionary = Dictionary.init(allocator);
    defer dictionary.deinit();
    
    try dictionary.add("first_key", "first_value");
    try std.testing.expect(std.mem.eql(u8, dictionary.get("first_key").?, "first_value"));
}
