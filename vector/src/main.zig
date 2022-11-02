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

fn SwizzleReturnType(comptime components: []const u8) type {
    if (components.len == 1) {
        return f32;
    } else {
        return @Vector(components.len, f32);
    }
}

fn getVectorComponentIndex(comptime component: u8) i32 {
    return switch (component) {
        'x' => 0,
        'y' => 1,
        'z' => 2,
        'w' => 3,
        
        'r' => 0,
        'g' => 1,
        'b' => 2,
        'a' => 3,
        
        'h' => 0,
        's' => 1,
        'l' => 2,
        //'a' => 3,

        else => @compileError("Unknown component!")
    };
}

fn swizzle(v: anytype, comptime components: []const u8) SwizzleReturnType(components) {
    const VectorType = @TypeOf(v);
    const componentCount = switch (@typeInfo(VectorType)) {
        .Vector => |info| info.len,
        else => @compileError("This type cannot swizzle!")
    };

    if (components.len == 0) {
        @compileError("Cannot swizzle without any components specify");
    }

    if (components.len > 4) {
        @compileError("Too many components on vector!");
    }

    if (components.len == 1) {
        return v[comptime getVectorComponentIndex(components[0])];
    }

    var result: @Vector(components.len, f32) = undefined;
    inline for (components) |component, i| {
        if (component == '0') {
            result[i] = 0;
            continue;
        }

        if (component == '1') {
            result[i] = 1;
            continue;
        }

        const index = comptime getVectorComponentIndex(component);
        if ((index < 0) or (index > componentCount - 1)) {
            @compileError("This vector does no has the component");
        }

        result[i] = v[index];
    }
    return result;
}

fn new1(length: comptime_int, scalar: f32) @Vector(length, f32) {
    if (length < 2 or length > 4) {
        @compileError("Unsupported vector type!");
    }

    var result: @Vector(length, f32) = undefined;
    var index = 0;
    inline while (index < length) : (index += 1) {
        result[index] = scalar;
    }
    return result;
}

fn new2(x: f32, y: f32) vec2 {
    return vec2 { x, y };
}

fn new3(x: f32, y: f32, z: f32) vec3 {
    return vec3 { x, y, z };
}

fn new4(x: f32, y: f32, z: f32, w: f32) vec4 {
    return vec4 { x, y, z, w };
}

test "vec2 operator+" {
    const a = new2(1, 2);
    const b = new2(3, 4);
    
    const c = a + b;
    try expectEqual(c, new2(4, 6));
}

test "vec2 operator-" {
    const a = new2(1, 2);
    const b = new2(3, 4);
    
    const c = a - b;
    try expectEqual(c, new2(-2, -2));
}

test "vec2 operator*" {
    const a = new2(1, 2);
    const b = new2(3, 4);
    
    const c = a * b;
    try expectEqual(c, new2(3, 8));
}

test "vec2 operator/" {
    const a = new2(1, 2);
    const b = new2(3, 4);
    
    const c = a / b;
    try expectEqual(c, new2(1.0/3.0, 0.5));
}

test "vec2 @rem" {
    const a = new2(1, 2);
    const b = new2(3, 4);
    
    const c = @rem(a, b);
    try expectEqual(c, new2(1, 2));
}

test "vec2 @mod" {
    const a = new2(1, 2);
    const b = new2(3, 4);
    
    const c = @mod(a, b);
    try expectEqual(c, new2(1, 2));
}

test "vec2 swizzle" {
    const a = new2(1, 2);
    const b = swizzle(a, "yx");
    try expectEqual(b[0], a[1]);
    try expectEqual(b[1], a[0]);
}

test "vec2 swizzle to vec3" {
    const a = new2(1, 2);
    const b = swizzle(a, "xy0");
    try expectEqual(b[0], a[0]);
    try expectEqual(b[1], a[1]);
    try expectEqual(b[2], 0);
}