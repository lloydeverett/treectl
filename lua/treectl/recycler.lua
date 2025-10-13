
local Recycler = {}
Recycler.__index = Recycler

function Recycler:recycler(current_children, key_fn, eq_fn)
    local instance = setmetatable({}, Recycler)

    instance._current_children = current_children
    instance._key_fn = key_fn
    instance._eq_fn = eq_fn

    instance._current_children_kv = {}
    for _, v in ipairs(current_children) do
        instance._current_children_kv[key_fn(v)] = v
    end

    return instance
end

function Recycler:try_recycle(new_node)
    local current_candidate = self._current_children_kv[self._key_fn(new_node)]

    if current_candidate == nil then
        return new_node
    end

    if self._eq_fn(new_node, current_candidate) then
        return current_candidate
    end

    return new_node
end

return Recycler

