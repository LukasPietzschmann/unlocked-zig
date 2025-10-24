const std = @import("std");

pub fn LockFreeStack(comptime T: type) type {
    return struct {
        const Self = @This();

        const Node = struct {
            value: T,
            next: ?*Node,
        };

        top: std.atomic.Value(?*Node),
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .top = std.atomic.Value(?*Node).init(null),
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            while (self.pop()) |value| {
                _ = value;
            }
        }

        pub fn push(self: *Self, value: T) !void {
            var new_head = try self.allocator.create(Node);
            new_head.* = Node{
                .value = value,
                .next = null,
            };

            while (true) {
                const old_head = self.top.load(.acquire);
                new_head.next = old_head;
                if (self.top.cmpxchgWeak(old_head, new_head, .release, .acquire) == null) {
                    return;
                }
            }
        }

        pub fn pop(self: *Self) ?T {
            while (true) {
                const old_head = self.top.load(.acquire) orelse {
                    return null;
                };
                const new_head = old_head.next;
                if (self.top.cmpxchgWeak(old_head, new_head, .acquire, .monotonic) == null) {
                    const value = old_head.value;
                    self.allocator.destroy(old_head);
                    return value;
                }
            }
        }

        pub fn peek(self: Self) ?T {
            const head = self.top.load(.seq_cst);
            if (head) |node| {
                return node.value;
            } else {
                return null;
            }
        }
    };
}
