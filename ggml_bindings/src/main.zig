const std = @import("std");
const assert = std.debug.assert;

const c = @cImport({
    @cInclude("ggml/ggml.h");
});

pub fn main() !void {
    var params = c.ggml_init_params{
        .mem_size   = 128 * 1024 * 1024,
        .mem_buffer = c.NULL,
    };

    c.ggml_time_init(); // Need this, or we face Illegal Instruction (core dumped) on Windows
    var ctx0 = c.ggml_init(params);

    var t1 = c.ggml_new_tensor_1d(ctx0, c.GGML_TYPE_F32, 10);
    var t2 = c.ggml_new_tensor_2d(ctx0, c.GGML_TYPE_I16, 10, 20);
    var t3 = c.ggml_new_tensor_3d(ctx0, c.GGML_TYPE_I32, 10, 20, 30);

    assert(t1.*.n_dims == 1);
    assert(t1.*.ne[0]  == 10);
    assert(t1.*.nb[1]  == 10 * @sizeOf(f32));

    assert(t2.*.n_dims == 2);
    assert(t2.*.ne[0]  == 10);
    assert(t2.*.ne[1]  == 20);
    assert(t2.*.nb[1]  == 10 * @sizeOf(i16));
    assert(t2.*.nb[2]  == 10 * 20 * @sizeOf(i16));

    assert(t3.*.n_dims == 3);
    assert(t3.*.ne[0]  == 10);
    assert(t3.*.ne[1]  == 20);
    assert(t3.*.ne[2]  == 30);
    assert(t3.*.nb[1]  == 10 * @sizeOf(i32));
    assert(t3.*.nb[2]  == 10 * 20 * @sizeOf(i32));
    assert(t3.*.nb[3]  == 10 * 20 * 30 * @sizeOf(i32));

    c.ggml_print_objects(ctx0);

    c.ggml_free(ctx0);
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
