const outputzig = @import("./output.zig");

pub const Result = union(enum) {
    exit,
    list,
    help,
};
