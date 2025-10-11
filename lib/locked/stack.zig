const std = @import("std");

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        backing: std.ArrayList(T),
        mutex: std.Thread.Mutex,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .allocator = allocator,
                .backing = std.ArrayList(T).init(allocator),
                .mutex = std.Thread.Mutex{},
            };
        }

        pub fn deinit(self: *Self) void {
            self.backing.deinit();
        }

        pub fn push(self: *Self, item: T) !void {
            self.mutex.lock();
            defer self.mutex.unlock();

            try self.backing.append(item);
        }

        pub fn pop(self: *Self) ?T {
            self.mutex.lock();
            defer self.mutex.unlock();

            return self.backing.pop();
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
