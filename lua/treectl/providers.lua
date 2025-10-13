local nodes = require("treectl.nodes")

local M = {}

-- interface reference and sample implementations ---------------------------------------

M.empty_provider = {
    create_children = -- return list of child nodes
                      -- recycle current_children where possible for smoother UI
        function(self, n, current_children) return {} end,
    allows_expand =   -- true to show expand toggle
        function(self, n) return false end,
    text =            -- text to display (used if text == nil)
        function(self, n) return "empty_node" end,
    path =            -- stable path to node; otherwise return nil (used if opts.path == nil)
        function(self, n) return nil end,
}

M.dummy_provider = {
    create_children =
        function(self, n, current_children) return {
            nodes.node("foo"),
            nodes.node("bar"),
       } end,
    allows_expand =
        function(self, n) return true end,
    text =
        function(self, n) return "dummy_node" end,
    path =
        function(self, n) return nil end,
}

M.stress_test_provider = {
    create_children =
        function(self, n, current_children)
            local result = {}
            for i = 1, 20000 do
                table.insert(result, nodes.node("foo." .. i))
            end
            return result
        end,
    allows_expand =
        function(self, n) return true end,
    text =
        function(self, n) return "stress_test_node" end,
    path =
        function(self, n) return nil end,
}

-- helpers to define new providers ------------------------------------------------------

function M.simple_provider(create_children_fn) return {
    create_children =
        function(self, n, current_children)
            return create_children_fn(n, current_children)
        end,
    allows_expand =
        function(self, n) return true end,
    text =
        function(self, n) return nil end,
    path =
        function(self, n) return nil end,
} end

return M

