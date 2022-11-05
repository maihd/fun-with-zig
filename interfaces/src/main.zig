const std = @import("std");

const Pick = struct {
    impl: *anyopaque,
    pickFn: std.meta.FnPtr(fn (*anyopaque) i32),
    
    pub fn pick(self: *const Pick) i32 {
        return self.pickFn(self.impl);
    }
};

fn foo(interface: Pick) void {
    var i: i32 = 1;
    while (i < 4) : (i += 1) {
        const p = interface.pick();
        std.debug.print("foo {d}: {d}\n", .{ i, p });
    }
}

const PickRandom = struct {
    r: std.rand.DefaultPrng,

    fn init() PickRandom {
        return .{
            .r = std.rand.DefaultPrng.init(0)
        };
    }

    fn interface(self: *PickRandom) Pick {
        return Pick {
            .impl = @ptrCast(*anyopaque, self),
            .pickFn = comptime myPick
        };
    }

    fn myPick(self_void: *anyopaque) i32 {
        const self = @ptrCast(*PickRandom, @alignCast(@alignOf(*PickRandom), self_void));
        return self.r.random().intRangeAtMost(i32, 10, 20);
    }
};

const PickSequence = struct {
    x: i32,

    fn init() PickSequence {
        return .{
            .x = 0,
        };
    }

    fn interface(self: *PickSequence) Pick {
        return Pick {
            .impl = @ptrCast(*anyopaque, self),
            .pickFn = myPick
        };
    }

    fn myPick(self_void: *anyopaque) i32 {
        const self = @ptrCast(*PickSequence, @alignCast(@alignOf(*PickSequence), self_void));
        defer self.x += 1;
        return self.x;
    }
};

pub fn main() !void {
    var pick_random = PickRandom.init();
    const pick_random_interface = pick_random.interface();
    foo(pick_random_interface);

    var pick_sequence = PickSequence.init();
    const pick_sequence_interface = pick_sequence.interface();
    foo(pick_sequence_interface);
}
