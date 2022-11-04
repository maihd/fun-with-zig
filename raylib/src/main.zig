const rl = @import("raylib");

const RaylibWindowDesc = struct {
    width: i32 = 800,
    height: i32 = 600,
    title: [*c]const u8 = "Raylib",
    fps: i32 = 60
};

const RaylibDrawTextArgs = struct {
    text: [*c]const u8, 
    x: i32,
    y: i32,
    fontSize: i32,
    color: rl.Color,
};

const ziglike_raylib = struct {
    fn init(desc: RaylibWindowDesc) void {
        rl.InitWindow(desc.width, desc.height, desc.title);
        rl.SetTargetFPS(desc.fps);
    }

    fn deinit() void {
        rl.CloseWindow();
    }

    fn shouldClose() bool {
        return rl.WindowShouldClose();
    }

    fn beginDrawing() void {
        rl.BeginDrawing();
    }

    fn endDrawing() void {
        rl.EndDrawing();
    }

    fn clearBackground(color: rl.Color) void {
        rl.ClearBackground(color);
    }

    fn drawText(args: RaylibDrawTextArgs) void {
        rl.DrawText(args.text, args.x, args.y, args.fontSize, args.color);
    }
};

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    ziglike_raylib.init(.{
        .width = 800,
        .height = 450,
        .title = "raylib-zig [core] example - basic window",
        .fps = 60 // Set our game to run at 60 frames-per-second
    });
    defer ziglike_raylib.deinit();
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!ziglike_raylib.shouldClose()) { // Detect window close button or ESC key
        ziglike_raylib.beginDrawing();
        defer ziglike_raylib.endDrawing();

        ziglike_raylib.clearBackground(rl.WHITE);
        ziglike_raylib.drawText(.{
            .text = "Congrats! You created your first window!", 
            .x = 190, 
            .y = 200, 
            .fontSize = 20, 
            .color = rl.LIGHTGRAY
        });
    }
}