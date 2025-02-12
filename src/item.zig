pub const State = enum {
    todo,
    done,
};

pub const Item = struct {
    description: []const u8,
    state: State = State.todo,
};
