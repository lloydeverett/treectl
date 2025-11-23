local nodes = require("treectl.nodes")
local paths = require("treectl.paths")
local providers = require("treectl.providers")
local luautils = require("treectl.luautils")
local nvimutils = require("treectl.nvimutils")
local cache = require("treectl.cache")
local recycler = require("treectl.recycler")
local highlights = require("treectl.highlights")

return function()
local M = {}

M._max_recents = vim.g["treectl#nvim#max_recents"] or 20

M._root_nodes = {}
function M.root_nodes()
    return M._root_nodes
end

M._cache = cache:cache()
local function stash(n)
    return M._cache:stash(n)
end

function M.follow_path(path, try_node_expansion_fn)
    if not luautils.starts_with(path, "neovim/") and path ~= "neovim" then
        return nil, paths.PATH_NOT_HANDLED
    end
    local cached_value = M._cache:get(path)
    if cached_value ~= nil then
        return cached_value
    end
    if luautils.starts_with(path, "neovim/buffer") then
        local result = try_node_expansion_fn(M._cache:get("neovim/buffer"), function()
            return M._cache:get(path)
        end)
        if result ~= nil then
            return result
        else
            return nil, paths.PATH_NOT_FOUND
        end
    end
    if luautils.starts_with(path, "neovim/recent") then
        local result = try_node_expansion_fn(M._cache:get("neovim/recent"), function()
            return M._cache:get(path)
        end)
        if result ~= nil then
            return result
        else
            return nil, paths.PATH_NOT_FOUND
        end
    end
    return nil, paths.PATH_NOT_FOUND
end

table.insert(M._root_nodes, stash(nodes.lazy_node( "buffer", { hl = highlights.TreeModNvim, help_suffix = "lists open buffers", path = "neovim/buffer" },
    providers.new_provider({ create_children = function(n, current_children)
        local buffer_recycler = recycler:recycler(
            current_children,
            function (v) return v.opts.path end,
            function (a, b) return a.opts.path == b.opts.path end
        )

        return luautils.map(nvimutils.list_open_buffers(), function(b)
            local display_name = b.name
            if display_name == "" then
                display_name = "[No Name]"
            end
            return stash(buffer_recycler:try_recycle(nodes.node(
                { { "" .. b.bufnr, highlights.Number }, " ", display_name },
                { path = "neovim/buffer/" .. b.bufnr }
            )))
        end)
    end })))
)

table.insert(M._root_nodes, stash(nodes.lazy_node( "recent", { hl = highlights.TreeModNvim, help_suffix = "nvim oldfiles", path = "neovim/recent" },
    providers.new_provider({ create_children = function(n, current_children)
        local recents_recycler = recycler:recycler(
            current_children,
            function (v) return v.details.index .. ":" .. v.details.filepath end,
            function (a, b)
                return a.details.filepath == b.details.filepath and
                       a.details.index == b.details.index
            end
        )

        local files = luautils.filter(vim.v.oldfiles, function(f)
            if f:sub(1, #"term://") == "term://" then
                return false
            end
            return true
        end)

        files = { table.unpack(files, 1, M._max_recents) }

        return luautils.map(files, function(f, i)
            local shortened_path = nvimutils.try_shorten_path(f)
            return stash(recents_recycler:try_recycle(nodes.node(
                { { "" .. (i - 1), highlights.Number }, " ", shortened_path },
                {
                    path = "neovim/recent/" .. "\0" .. f,
                    details = {
                        filepath = f,
                        index = i - 1
                    }
                }
            )))
        end)
    end })))
)

local neovim_child_nodes = {}

table.insert(neovim_child_nodes, stash(nodes.lazy_node("window", { hl = highlights.TreeModNvim, path = "neovim/window" },
    providers.new_provider({ create_children = function(n, current_children)
        return {}
    end })
)))

table.insert(neovim_child_nodes, stash(nodes.lazy_node("highlight", { hl = highlights.TreeModNvim, path = "neovim/highlight" },
    providers.new_provider({ create_children = function(n, current_children)
        return {}
    end })
)))

table.insert(neovim_child_nodes, stash(nodes.lazy_node("tab", { hl = highlights.TreeModNvim, path = "neovim/tab" },
    providers.new_provider({ create_children = function(n, current_children)
        return {}
    end })
)))

table.insert(neovim_child_nodes, stash(nodes.lazy_node("register", { hl = highlights.TreeModNvim, path = "neovim/register" },
    providers.new_provider({ create_children = function(n, current_children)
        return {}
    end })
)))

table.insert(neovim_child_nodes, stash(nodes.lazy_node("symbol", { hl = highlights.TreeModNvim, path = "neovim/symbol" },
    providers.new_provider({ create_children = function(n, current_children)
        return {}
    end })
)))

table.insert(neovim_child_nodes, stash(nodes.lazy_node("mark", { hl = highlights.TreeModNvim, path = "neovim/mark" },
    providers.new_provider({ create_children = function(n, current_children)
        return {}
    end })
)))

table.insert(neovim_child_nodes, stash(nodes.lazy_node("colorscheme", { hl = highlights.TreeModNvim, path = "neovim/colorscheme" },
    providers.new_provider({ create_children = function(n, current_children)
        return {}
    end })
)))

table.insert(neovim_child_nodes, stash(nodes.lazy_node("plugin", { hl = highlights.TreeModNvim, path = "neovim/plugin" },
    providers.new_provider({ create_children = function(n, current_children)
        return {}
    end })
)))

table.insert(M._root_nodes, stash(nodes.node(
    "neovim",
    { hl = highlights.TreeModNvim, path = "neovim", help_suffix = "more neovim trees" },
    neovim_child_nodes
)))

return M
end

