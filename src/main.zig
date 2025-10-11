const std = @import("std");
const lib = @import("unlocked");

pub fn main() void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    std.debug.print("2 + 3 = {d}\n", .{lib.add(2, 3)});
}
