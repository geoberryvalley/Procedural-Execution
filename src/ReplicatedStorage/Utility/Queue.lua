--I stole this from reddit https://www.reddit.com/r/lua/comments/7d0rjc/how_to_approach_a_queue_in_lua_for_pathfinding/
-- I modified it to not be super slow though
queue = {}

function queue.enqueue(self, item) --TODO implement garbage collection when you reach a certain index of the list (use two lists and switch over)
	table.insert(self.list, item)
	--print("queue length",#self.list)
end

function queue.dequeue(self)
	self.cIndex += 1
	return self.list[self.cIndex-1]
end

function queue.is_empty(self)
	return self.cIndex > #self.list
end

function queue.len(self)
	return #self.list - self.cIndex + 1
end

function queue.new()
	return {
		list = {},
		push = queue.push,
		pop = queue.pop,
		is_empty = queue.is_empty,
		len = queue.len,
		cIndex = 1
	}
end

return queue