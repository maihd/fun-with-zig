const std = @import("std");

fn indexOf(haystack: []const u8, needle: u8) ?usize {
    // Simply loop all items to search needle position
    for (haystack) |item, pos| {
        if (item == needle) {
            return pos;
        }
    }
    
    // Not found
    return null;
}

fn indexOfSimd128(haystack: []const u8, needle: u8) ?usize {
    // Local type to utility the algorithm
    const Simd128 = @Vector(8, u8);
    const simd_len = @sizeOf(Simd128);

    // Needles list to check local group of [pos..pos + simd_len]
    const needles_simd = @splat(simd_len, needle); 

    // Indexes list to check local group of [pos..pos + simd_len]
    // A range of 0..simd_len
    const indexes = std.simd.iota(u8, simd_len);
    
    // Nulls list to check local group of [pos..pos + simd_len]
    // 255 for first item search
    // -1 for last item search
    const nulls = @splat(simd_len, @as(u8, 255));

    // Start a vectorized loop to find the needle position
    var pos: usize = 0;
    while (pos + simd_len < haystack.len) : (pos += simd_len) {
        // Cast haystack to simd
        const haystack_simd: Simd128 = haystack[pos..][0..simd_len].*;

        // Compute matches with simd instructions
        const matches: @Vector(simd_len, bool) = (haystack_simd == needles_simd);

        // Check if any needles in [pos..pos + simd_len]
        // Perform like zmath.any(@Vector(simd_len, bool))
        if (@reduce(.Or, matches)) {
            // Select null or index base on matches items value
            // true -> indexes[i] -> i
            // false -> nulls[i] -> 255
            const selected_indexes = @select(u8, matches, indexes, nulls);

            // Find index of the local group [pos..pos + simd_len]
            // By marking the unequal items with 255, the min op will filter best result
            const offset = @reduce(.Min, selected_indexes);

            // The final result will be pos + offset
            const result = pos + offset;

            // Add simple assert to make sure the algorithm is correct
            std.debug.assert(haystack[result] == needle);

            // Return the result
            return result;
        }
    }

    // Find needles in remains items (number of items < simd_len)
    // Fallback to use scalar version
    while (pos < haystack.len) : (pos += 1) {
        if (haystack[pos] == needle) {
            return pos;
        }
    }

    // No items matches
    return null;
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test "Behaviour test" {
    const string: []const u8 = "Hello world";

    try std.testing.expectEqual(indexOf(string, 'H'), 0);
    try std.testing.expectEqual(indexOf(string, 'X'), null);
    
    try std.testing.expectEqual(indexOfSimd128(string, 'H'), 0);
    try std.testing.expectEqual(indexOfSimd128(string, 'X'), null);
}

test "Speed test" {
    const ops = 10000;
    const string: []const u8 = "Hello world, there is a long long string=)";

    var scalar_time = scalar: {
        var timer = try std.time.Timer.start();
        const start = timer.lap();

        var i: usize = 0;
        while (i < ops) : (i += 1) {
            try std.testing.expectEqual(indexOf(string, ')'), string.len - 1);
            try std.testing.expectEqual(indexOf(string, 'X'), null);
        }

        const end = timer.read();
        const elapsed_s = @intToFloat(f64, end - start) / std.time.ns_per_s;
        break :scalar elapsed_s;
    };

    var simd128_time = simd128: {
        var timer = try std.time.Timer.start();
        const start = timer.lap();

        var i: usize = 0;
        while (i < ops) : (i += 1) {
            try std.testing.expectEqual(indexOfSimd128(string, ')'), string.len - 1);
            try std.testing.expectEqual(indexOfSimd128(string, 'X'), null);
        }

        const end = timer.read();
        const elapsed_s = @intToFloat(f64, end - start) / std.time.ns_per_s;
        break :simd128 elapsed_s;
    };

    // Obviously simd128_time must be < scalar_time
    try std.testing.expect(simd128_time < scalar_time);
}

test "Speed test 2" {
    const ops = 10000;
    const string: []const u8 = "Hello world";

    var scalar_time = scalar: {
        var timer = try std.time.Timer.start();
        const start = timer.lap();

        var i: usize = 0;
        while (i < ops) : (i += 1) {
            try std.testing.expectEqual(indexOf(string, 'H'), 0);
            try std.testing.expectEqual(indexOf(string, 'X'), null);
        }

        const end = timer.read();
        const elapsed_s = @intToFloat(f64, end - start) / std.time.ns_per_s;
        break :scalar elapsed_s;
    };

    var simd128_time = simd128: {
        var timer = try std.time.Timer.start();
        const start = timer.lap();

        var i: usize = 0;
        while (i < ops) : (i += 1) {
            try std.testing.expectEqual(indexOfSimd128(string, 'H'), 0);
            try std.testing.expectEqual(indexOfSimd128(string, 'X'), null);
        }

        const end = timer.read();
        const elapsed_s = @intToFloat(f64, end - start) / std.time.ns_per_s;
        break :simd128 elapsed_s;
    };

    // If needle position is < 8 (best case), scalar version always faster than simd 
    try std.testing.expect(simd128_time > scalar_time);
}