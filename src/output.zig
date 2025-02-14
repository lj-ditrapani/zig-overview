pub const Color = enum {
    red,
    green,
    yellow,
    blue,

    pub fn toCode(self: Color) []const u8 {
        return switch (self) {
            .red => "31",
            .green => "32",
            .yellow => "33",
            .blue => "34",
        };
    }
};
