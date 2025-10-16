local nodes = require("treectl.nodes")

local Cache = {}
Cache.__index = Cache

function Cache:cache()
    local instance = setmetatable({}, Cache)
    instance._nodes = {}
    return instance
end

function Cache:stash(n)
    local path = nodes.node_get_path(n)
    if path == nil then
        error("cannot insert node into cache because node path is nil")
    end
    self._nodes[path] = n
    n.opts.cached_in = self
    return n
end

function Cache:get(path)
    return self._nodes[path]
end

return Cache

