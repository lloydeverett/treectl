local nodes = require("treectl.nodes")

local function encode_key(path)
    if type(path) == "string" then
        return path
    elseif type(path) == "table" then
        local result = path[1]
        for i = 2, #path do
            -- delimit with null characters
            result = result .. "\0" .. path[i]
        end
        return result
    else
        error("cannot encode key: path is of unexpected type " .. type(path))
    end
end

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
    self._nodes[encode_key(path)] = n
    n.opts.cached_in = self
    return n
end

function Cache:get(path, rest)
    if rest == nil then
        return self._nodes[encode_key(path)]
    end
    return self._nodes[encode_key({ path, unpack(rest) })]
end

return Cache

