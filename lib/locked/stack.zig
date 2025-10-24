const std = @import("std");

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();

        const Node = struct {
            value: T,
            next: ?*Node,
        };

        top: ?*Node,
        allocator: std.mem.Allocator,
        mutex: std.Thread.Mutex,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .top = null,
                .allocator = allocator,
                .mutex = std.Thread.Mutex{},
            };
        }

        pub fn deinit(self: *Self) void {
            while (self.pop()) |value| {
                _ = value;
            }
        }

        pub fn push(self: *Self, value: T) !void {
            const new_head = try self.allocator.create(Node);

            self.mutex.lock();
            defer self.mutex.unlock();

            new_head.* = Node{
                .value = value,
                .next = self.top,
            };
            self.top = new_head;
        }

        pub fn pop(self: *Self) ?T {
            self.mutex.lock();
            defer self.mutex.unlock();

            if (self.top) |top| {
                const value = top.value;
                self.top = top.next;
                self.allocator.destroy(top);
                return value;
            } else {
                return null;
            }
        }

        pub fn peek(self: *Self) ?T {
            self.mutex.lock();
            defer self.mutex.unlock();

            if (self.backing.items.len > 0) {
                return self.backing.items[self.backing.items.len - 1];
            } else {
                return null;
            }
        }
    };
}
