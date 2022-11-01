const std = @import("std");
const json = std.json;

const payload = 
    \\{
    \\  "vals": {
    \\      "testing": 1,
    \\      "production": 42
    \\  },
    \\  "uptime": 9999
    \\}
    ;

const Config = struct {
    vals: struct {
        testing: u8,
        production: u8
    },
    uptime: u64
};

const config = x: {
    var stream = json.TokenStream.init(payload);
    var result = json.parse(Config, &stream, .{});
    break :x result catch unreachable;
};

pub fn main() !void {
    if (config.vals.production > 50) {
        @compileError("Only up to 50 supported");
    }
    std.log.info("up={d}", .{config.uptime});
}