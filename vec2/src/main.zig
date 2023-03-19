const std = @import("std");
const testing = std.testing;

// Fields

x: f32,
y: f32,

// Types

pub const Self = @This();
pub const F32x2 = @Vector(2, f32);

// Methods

pub fn new(x: f32, y: f32) Self {
    return Self{ .x = x, .y = y };
}
test "Vec2.new(f32, f32) Vec2" {
    const a = new(1.0, 2.0);
    const b = Self{ .x = 1.0, .y = 2.0 };
    try testing.expectEqual(a, b);
}

pub fn news(s: f32) Self {
    return Self{ .x = s, .y = s };
}
test "Vec2.news(f32) Vec2" {
    const a = news(1.0);
    const b = Self{ .x = 1.0, .y = 1.0 };
    try testing.expectEqual(a, b);
}

pub fn add(a: Self, b: Self) Self {
    const f32x2 = F32x2{a.x, a.y} + F32x2{b.x, b.y};
    return Self{ .x = f32x2[0], .y = f32x2[1] };
}
test "Vec2.add(Vec2, Vec2) Vec2" {
    const a = new(1.0, 2.0);
    const b = new(3.0, 4.0);
    const c = add(a, b);
    const d = Self{ .x = 4.0, .y = 6.0 };
    try testing.expectEqual(c, d);
}

pub fn sub(a: Self, b: Self) Self {
    const f32x2 = F32x2{a.x, a.y} - F32x2{b.x, b.y};
    return Self{ .x = f32x2[0], .y = f32x2[1] };
}
test "Vec2.sub(Vec2, Vec2) Vec2" {
    const a = new(1.0, 2.0);
    const b = new(3.0, 4.0);
    const c = sub(a, b);
    const d = Self{ .x = -2.0, .y = -2.0 };
    try testing.expectEqual(c, d);
}

pub fn mul(a: Self, b: Self) Self {
    const f32x2 = F32x2{a.x, a.y} * F32x2{b.x, b.y};
    return Self{ .x = f32x2[0], .y = f32x2[1] };
}
test "Vec2.mul(Vec2, Vec2) Vec2" {
    const a = new(1.0, 2.0);
    const b = new(3.0, 4.0);
    const c = mul(a, b);
    const d = Self{ .x = 3.0, .y = 8.0 };
    try testing.expectEqual(c, d);
}

pub fn div(a: Self, b: Self) Self {
    const f32x2 = F32x2{a.x, a.y} / F32x2{b.x, b.y};
    return Self{ .x = f32x2[0], .y = f32x2[1] };
}
test "Vec2.div(Vec2, Vec2) Vec2" {
    const a = new(1.0, 2.0);
    const b = new(3.0, 4.0);
    const c = div(a, b);
    const d = Self{ .x = 1.0/3.0, .y = 0.5 };
    try testing.expectEqual(c, d);
}
