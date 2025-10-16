local NuiLine = require("nui.line")
local luautils = require("treectl.luautils")
local nodes = require("treectl.nodes")
local paths = require("treectl.paths")
local highlights = require("treectl.highlights")

local M = {}

function M.is_node_decorative(n)
    return n.opts.help == true or n.opts.debug == true
end

function M.is_node_lazy(n)
    return n.opts.lazy == true
end

function M.is_node_text_dynamic(n)
    return n.text == nil
end

function M.node_get_path_display_text(n)
    return paths.path_display_text(nodes.node_get_path(n))
end

function M.node_allows_expand(n)
    if M.is_node_lazy(n) then
        local provider = n.opts.provider
        if provider ~= nil then
            return provider:allows_expand(n)
        else
            return false
        end
    end

    return n:has_children()
end

function M.node_expand(tree, n)
    if n:is_expanded() then
        return
    end

    if M.is_node_lazy(n) then
        local provider = n.opts.provider
        if provider ~= nil then
            for index, child_node in ipairs(provider:create_children(n, {})) do
                tree:add_node(child_node, n:get_id())
            end
        end
    end

    n:expand()

    -- auto-expand subtree if there is only one child node
    local child_ids = n:get_child_ids()
    if #child_ids == 1 then
        M.node_expand(tree, tree:get_node(child_ids[1]))
    end
end

function M.node_collapse(tree, n)
    if not n:is_expanded() then
        return
    end

    n:collapse()
    if M.is_node_lazy(n) then
        for index, child_id in ipairs(n:get_child_ids()) do
            tree:remove_node(child_id)
        end
    end
end

function M.node_refresh_children(tree, n)
    if not n:is_expanded() or not M.is_node_lazy(n) then
        return
    end

    local provider = n.opts.provider
    if not provider:allows_expand(n) then
        return
    end

    local current_children = {}
    for index, child_id in ipairs(n:get_child_ids()) do
        local node = tree:get_node(child_id)
        table.insert(current_children, node)
    end

    local new_children = provider:create_children(n, current_children)
    if new_children == nil then
        return
    end

    tree:set_nodes(new_children, n:get_id())
end

function M.refresh_all_children(tree, filter_for_provider)
    local refresh_recursively
    refresh_recursively = function(node_id)
        local n = tree:get_node(node_id)

        if filter_for_provider == nil or n.opts.provider == filter_for_provider then
            M.node_refresh_children(tree, n)
        end

        for index, child_id in ipairs(n:get_child_ids()) do
            refresh_recursively(child_id)
        end
    end
    for index, top_level_node in ipairs(tree:get_nodes()) do
        refresh_recursively(top_level_node:get_id())
    end
end

function M.line_append_content(line, content, hl)
    if type(content) == "string" then
        line:append(content, hl)
    elseif type(content) == "table" then
        -- looks like a sequence; concatenate parts
        for i, segment in ipairs(content) do
            -- could be a plain string or a { str, hl } table specifying hl override; handle either
            if type(segment) == "string" then
                line:append(segment, hl)
            elseif type(segment) == "table" then
                line:append(segment[1], segment[2])
            else
                print("ignoring invalid node text segment:", segment)
            end
        end
    else
        line:append("unknown", highlights.ErrorMsg)
    end
end

function M.node_append_display_text(n, line, render_opts)
    local content = nil
    local hl = nil

    if M.is_node_text_dynamic(n) then
        local provider = n.opts.provider
        if provider ~= nil then
            content, hl = provider:text(n)
        else
            content = "nil"
            hl = highlights.ErrorMsg
        end
    else
        if n.opts.hl ~= nil then
            hl = n.opts.hl
        elseif n.opts.help then
            hl = highlights.Comment
        elseif n.opts.debug then
            hl = highlights.Debug
        elseif n:get_parent_id() == nil then
            hl = highlights.TreeModOther
        end
        content = n.text
    end

    M.line_append_content(line, content, hl)

    if n.opts.help_suffix ~= nil and render_opts ~= nil and render_opts.show_help then
        line:append(" - ", highlights.Comment)
        M.line_append_content(line, n.opts.help_suffix, highlights.Comment)
    end

    if not n.opts.debug and not n.opts.help and render_opts ~= nil and render_opts.show_debug then
        line:append(" ")
        line:append("[" .. M.node_get_path_display_text(n) .. "]", highlights.Debug)
    end
end

function M.node_get_nui_line(n, render_opts)
    local line = NuiLine()

    if n.opts.separator then
        return line
    end

    if n.opts.help and not (render_opts ~= nil and render_opts.show_help) then
        return {} -- skip render
    end
    if n.opts.debug and not (render_opts ~= nil and render_opts.show_debug) then
        return {} -- skip render
    end

    line:append(string.rep("  ", n:get_depth() - 1))

    if n.opts.indicator == "none" then
        line:append("  ")
    elseif n.opts.indicator == "action" then
        line:append("→ ", highlights.IndicatorActive)
    elseif M.node_allows_expand(n) then
        line:append(n:is_expanded() and "- " or "+ ", highlights.IndicatorActive)
    elseif n.opts.help then
        line:append("* ", highlights.IndicatorInactive)
    else
        line:append("- ", highlights.IndicatorInactive)
    end

    M.node_append_display_text(n, line, render_opts)

    return line
end

function M.current_cursor_pos()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    return row, col
end

function M.set_cursor_row(new_row)
    local row, col = M.current_cursor_pos()
    vim.api.nvim_win_set_cursor(0, {new_row, col})
end

function M.place_cursor_on_node(tree, node)
    local n, line_start, line_end = tree:get_node(node:get_id())
    M.set_cursor_row(line_start)
end

function M.current_node(tree)
    local row, col = M.current_cursor_pos()
    local node, line_start, line_end = tree:get_node(row)
    return node
end

function M.find_node(nodes, node_id)
    local index = nil
    for i, node in ipairs(nodes) do
        if node:get_id() == node_id then
            return i
        end
    end
    return nil
end

function M.node_ancestors(tree, node)
    local node_id = node:get_id()
    local node_ancestor_ids = { node_id }
    local current_ancestor = node
    while current_ancestor:get_parent_id() ~= nil do
        table.insert(node_ancestor_ids, current_ancestor:get_parent_id())
        current_ancestor = tree:get_node(current_ancestor:get_parent_id())
    end
    return node_ancestor_ids
end

function M.place_cursor_on_prev_top_level_node(tree)
    local ancestors = M.node_ancestors(tree, M.current_node(tree))
    local row, col = M.current_cursor_pos()
    local toplevel_node_id = ancestors[#ancestors]
    local toplevel_node, toplevel_node_start, toplevel_node_end = tree:get_node(toplevel_node_id)

    if row ~= toplevel_node_start then
        M.set_cursor_row(toplevel_node_start)
        return
    end

    local toplevel_nodes = luautils.filter(tree:get_nodes(), function(n)
        return (not M.is_node_decorative(n)) or n:get_id() == toplevel_node_id
    end)
    local index = M.find_node(toplevel_nodes, toplevel_node_id)
    if index == nil then
        return
    end
    index = index - 1
    if index < 1 then
        return
    end

    M.place_cursor_on_node(tree, toplevel_nodes[index])
end

function M.place_cursor_on_next_top_level_node(tree)
    local ancestors = M.node_ancestors(tree, M.current_node(tree))
    local toplevel_node_id = ancestors[#ancestors]

    local toplevel_nodes = luautils.filter(tree:get_nodes(), function(n)
        return (not M.is_node_decorative(n)) or n:get_id() == toplevel_node_id
    end)
    local index = M.find_node(toplevel_nodes, toplevel_node_id)
    if index == nil then
        return
    end
    index = index + 1
    if index > #toplevel_nodes then
        return
    end

    M.place_cursor_on_node(tree, toplevel_nodes[index])
end

function M.place_cursor_on_parent_or_prev_open_top_level_node(tree)
    local ancestors = M.node_ancestors(tree, M.current_node(tree))
    local row, col = M.current_cursor_pos()

    if #ancestors == 1 then
        local toplevel_nodes = luautils.filter(tree:get_nodes(), function(n)
            return (not M.is_node_decorative(n)) or n:get_id() == ancestors[1]
        end)
        local index = M.find_node(toplevel_nodes, ancestors[1])
        if index == nil then
            return
        end
        while true do
            index = index - 1
            if index < 1 then
                M.place_cursor_on_node(tree, toplevel_nodes[1])
                return
            end
            if toplevel_nodes[index]:is_expanded() then
                M.place_cursor_on_node(tree, toplevel_nodes[index])
                return
            end
        end
    elseif #ancestors > 1 then
        M.place_cursor_on_node(tree, tree:get_node(ancestors[2]))
    end
end

function M.place_cursor_on_next_open_top_level_node(tree)
    local ancestors = M.node_ancestors(tree, M.current_node(tree))
    local toplevel_nodes = luautils.filter(tree:get_nodes(), function(n)
        return (not M.is_node_decorative(n)) or n:get_id() == ancestors[#ancestors]
    end)
    local index = M.find_node(toplevel_nodes, ancestors[#ancestors])
    if index == nil then
        return
    end
    while true do
        index = index + 1
        if index > #toplevel_nodes then
            M.place_cursor_on_node(tree, toplevel_nodes[#toplevel_nodes])
            return
        end
        if toplevel_nodes[index]:is_expanded() then
            M.place_cursor_on_node(tree, toplevel_nodes[index])
            return
        end
    end
end

function M.preserve_cursor_selection(tree, callback)
    local selection_ancestor_ids  = M.node_ancestors(tree, M.current_node(tree))

    -- do some work that may disrupt cursor position
    -- typically this would involve a call to tree:render()
    callback()

    -- try to place cursor on the node on which it was previously placed
    -- if no longer present, try to find the nearest ancestor
    for index, ancestor_id in ipairs(selection_ancestor_ids) do
        local node, line_start, line_end = tree:get_node(ancestor_id)
        if line_start ~= nil then
            M.set_cursor_row(line_start)
            break
        end
    end
end

function M.follow_path(path, modules, print_debug)
    local log = nil
    if print_debug then
        log = paths.path_display_text(path) .. " -> "
    end
    for _, module_name in ipairs(modules.keys) do
        local module = modules.kv[module_name]
        local result, err = module.follow_path(path)
        if err == nil then
            assert(result ~= nil, module_name .. ".follow_path returned nil path with no error code for path " .. M.node_get_path_display_text(path))
            if print_debug then
                log = log .. "(" .. module_name .. ") " .. M.node_get_path_display_text(result)
                print(log)
            end
            return result
        else
            if err ~= paths.PATH_NOT_HANDLED then
                if print_debug then
                    log = log .. "(" .. module_name .. ") " .. err
                    print(log)
                end
                return nil, err
            elseif print_debug then
                log = log .. "(" .. module_name .. ") " .. err .. " -> "
            end
        end
    end
    if print_debug then
        log = log .. "nil (fail)"
        print(log)
    end
    return nil, paths.PATH_NOT_HANDLED
end

return M

