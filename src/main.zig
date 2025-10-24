const std = @import("std");
const lib = @import("unlocked");

const LockFreeStack = lib.lockfreestack.LockFreeStack(i32);
const LockedStack = lib.lockedstack.Stack(i32);

var pushed = std.atomic.Value(i32).init(0);
var popped = std.atomic.Value(i32).init(0);

fn runner(s: anytype, i: usize) void {
    for (0..10000) |_| {
        if (i % 2 == 0) {
            const v: i32 = @intCast(i);
            _ = s.push(v) catch {
                std.debug.print("Push failed in thread {}\n", .{i});
            };
            _ = pushed.fetchAdd(v, .acquire);
        } else {
            while (true) {
                const v = s.pop();
                if (v) |vv| {
                    _ = popped.fetchAdd(vv, .acquire);
                    break;
                }
            }
        }
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var locked_stack = LockedStack.init(allocator);
    defer locked_stack.deinit();

    var unlocked_stack = LockFreeStack.init(allocator);
    defer unlocked_stack.deinit();

    var threads: [2]std.Thread = undefined;
    for (&threads, 1..) |*thread, i| {
        thread.* = try std.Thread.spawn(.{}, runner, .{ &unlocked_stack, i });
    }
    for (threads) |thread| {
        thread.join();
    }

    if (pushed.load(.seq_cst) != popped.load(.seq_cst)) {
        std.debug.print("Mismatch: pushed = {}, popped = {}\n", .{ pushed.load(.seq_cst), popped.load(.seq_cst) });
    } else {
        std.debug.print("Success: pushed = {}, popped = {}\n", .{ pushed.load(.seq_cst), popped.load(.seq_cst) });
    }
}
