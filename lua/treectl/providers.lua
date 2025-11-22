local nodes = require("treectl.nodes")
local luautils = require("treectl.luautils")

local M = {}

M.reference_provider = {
    create_children = -- return list of child nodes
                      -- recycle current_children where possible for smoother UI
        function(self, n, current_children) return {} end,
    allows_expand =   -- true to show expand toggle
        function(self, n) return true end,
    text =            -- text to display (used if text == nil)
        function(self, n) return nil end,
    path =            -- stable path to node; otherwise return nil (used if opts.path == nil)
        function(self, n) return nil end,
}

function M.new_provider(partial)
    local provider = {}
    luautils.insert_all_kv(provider, M.reference_provider)
    luautils.insert_all_kv(provider, partial)
    return provider
end

-- sample implementations ---------------------------------------------------------------

M.empty_provider = M.new_provider({ allows_expand = false })

M.dummy_provider = M.new_provider({ create_children = function(self, n, current_children)
    return {
        nodes.node("foo"),
        nodes.node("bar"),
    }
end })

M.stress_test_provider = M.new_provider({ create_children = function(self, n, current_children)
    local result = {}
    for i = 1, 20000 do
        table.insert(result, nodes.node("foo." .. i))
    end
    return result
end })

return M

