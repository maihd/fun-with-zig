const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "Basic vector usage" {
    const a = @Vector(4, i32){ 1, 2, 3, 4 };
    const b = @Vector(4, i32){ 5, 6, 7, 8 };

    const c = a + b;

    try expectEqual(6, c[0]);
    try expectEqual(8, c[1]);
    try expectEqual(10, c[2]);
    try expectEqual(12, c[3]);
    try expectEqual([4]i32{ 6, 8, 10, 12 }, c);
    try expectEqual(@Vector(4, i32){ 6, 8, 10, 12 }, c);
}

test "Conversion between vectors, arrays, and slices" {
    var arr1: [4]f32 = [_]f32{ 1.2, 2.3, 4.5, 5.6 };
    var v: @Vector(4, f32) = arr1;
    var arr2: [4]f32 = v;
    try expectEqual(arr1, arr2);

    var v2: @Vector(2, f32) = arr1[1..3].*;

    var slice: []const f32 = &arr1;
    var offset: u32 = 1;

    var v3: @Vector(2, f32) = slice[offset..][0..2].*;
    try expectEqual(slice[offset], v2[0]);
    try expectEqual(slice[offset + 1], v2[1]);
    try expectEqual(v2, v3);
}

const vec2 = @Vector(2, f32);
const vec3 = @Vector(3, f32);
const vec4 = @Vector(4, f32);

fn vec2_new(x: f32, y: f32) vec2 {
    return vec2 { x, y };
}

fn vec3_new(x: f32, y: f32, z: f32) vec3 {
    return vec3 { x, y, z };
}

fn vec4_new(x: f32, y: f32, z: f32, w: f32) vec4 {
    return vec4 { x, y, z, w };
}

test "vec2 operator+" {
    const a = vec2_new(1, 2);
    const b = vec2_new(3, 4);
    
    const c = a + b;
    try expectEqual(c, vec2_new(4, 6));
}

test "vec2 operator-" {
    const a = vec2_new(1, 2);
    const b = vec2_new(3, 4);
    
    const c = a - b;
    try expectEqual(c, vec2_new(-2, -2));
}

test "vec2 operator*" {
    const a = vec2_new(1, 2);
    const b = vec2_new(3, 4);
    
    const c = a * b;
    try expectEqual(c, vec2_new(3, 8));
}

test "vec2 operator/" {
    const a = vec2_new(1, 2);
    const b = vec2_new(3, 4);
    
    const c = a / b;
    try expectEqual(c, vec2_new(1.0/3.0, 0.5));
}

test "vec2 @rem" {
    const a = vec2_new(1, 2);
    const b = vec2_new(3, 4);
    
    const c = @rem(a, b);
    try expectEqual(c, vec2_new(1, 2));
}

test "vec2 @mod" {
    const a = vec2_new(1, 2);
    const b = vec2_new(3, 4);
    
    const c = @mod(a, b);
    try expectEqual(c, vec2_new(1, 2));
}