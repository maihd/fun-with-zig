const std = @import("std");
const capy = @import("capy");

pub fn main() !void {
    try capy.backend.init();

    var window = try capy.Window.init();
    try window.set(
        capy.Label(.{ .text = "Hello world!" })  
    );

    window.setTitle("Hello world!");
    window.resize(300, 100);
    window.show();

    capy.runEventLoop();
}