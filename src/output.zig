pub const Color = enum { blue, green, red, yellow };

pub const ColoredString = struct {
    color: Color,
    msg: []u8,
};
