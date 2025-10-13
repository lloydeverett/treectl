local NuiTree = require("nui.tree")

local function insert_opts(opts, additions)
    local new_opts = {}
    if opts ~= nil then
        for k, v in pairs(opts) do
            new_opts[k] = v
        end
    end
    for k, v in pairs(additions) do
        new_opts[k] = v
    end
    return new_opts
end

local function random8()
  return math.random(0, 255)
end

local M = {}

function M.gen_id()
    -- random 128-bit int encoded as a string
    return string.char(
        random8(), random8(), random8(), random8(),
        random8(), random8(), random8(), random8(),
        random8(), random8(), random8(), random8(),
        random8(), random8(), random8(), random8()
    )
end

function M.node(text, opts, children)
    if opts == nil then
        opts = {}
    end
    local id = opts.id
    if id == nil then
        id = M.gen_id()
    end
    if children == nil then
        children = {}
    end
    return NuiTree.Node({
        text = text,
        opts = opts,
        id = id,
        details = opts.details
    }, children)
end

function M.separator_node()
    return M.node(nil, { separator = true })
end

function M.lazy_node(text, opts, provider)
    opts = insert_opts(opts, { lazy = true, provider = provider })
    return M.node(text, opts)
end

function M.help_node(text, opts)
    opts = insert_opts(opts, { help = true })
    return M.node(text, opts)
end

function M.debug_node(text, opts)
    opts = insert_opts(opts, { debug = true })
    return M.node(text, opts)
end

function M.node_get_path(n)
    if n.opts.path ~= nil then
        return n.opts.path
    end
    if n.opts.provider ~= nil then
        local path = n.opts.provider:path(n)
        if path ~= nil then
            return path
        end
    end
    return nil
end

return M

