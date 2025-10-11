const std = @import("std");
const lib = @import("unlocked");

const LockFreeStack = lib.lockfreestack.LockFreeStack(i32);
const LockedStack = lib.lockedstack.Stack(i32);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var unlocked_stack = LockFreeStack.init(allocator);
    try unlocked_stack.push(42);
    const value = unlocked_stack.pop();
    if (value) |v| {
        std.debug.print("Popped value: {d}\n", .{v});
    } else {
        std.debug.print("Stack is empty.\n", .{});
    }

    var locked_stack = LockedStack.init(allocator);
    defer locked_stack.deinit();
    try locked_stack.push(84);
    const locked_value = locked_stack.pop();
    if (locked_value) |v| {
        std.debug.print("Popped value: {d}\n", .{v});
    } else {
        std.debug.print("Stack is empty.\n", .{});
    }
}
