const std = @import("std");
const item = @import("./item.zig");
const result = @import("./result.zig");

pub fn todo(todoList: *std.ArrayList(item.Item)) result.Result {
    std.debug.print("here {d}\n", .{todoList.capacity});
    return .{ .help = {} };
}
