const std = @import("std");
const json = std.json;

const GitRepo = struct {
    name: []u8,
    link: []u8,
};

const GitUser = struct {
    name: []u8,
    repos: []GitRepo
};

const gitUserJson =
    \\{
    \\  "name": "MaiHD",
    \\  "repos": [
    \\      {
    \\          "name": "fun-with-zig",
    \\          "link": "https://github.com/maihd/fun-with-zig"
    \\      },
    \\      {
    \\          "name": "vectormath",
    \\          "link": "https://github.com/maihd/vectormath" 
    \\      }
    \\  ] 
    \\}
    ;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var user = x: {
        var stream = json.TokenStream.init(gitUserJson);
        var result = json.parse(GitUser, &stream, .{ .allocator = allocator });
        break :x result catch unreachable;
    };
    defer std.json.parseFree(
        GitUser,
        user,
        .{ .allocator = allocator },
    );

    
    std.log.info("user={s}", .{user.name});
    for (user.repos) |repo| {
        std.log.info("  - repo={s}", .{repo.name});
        std.log.info("    link={s}", .{repo.link});
    }
}