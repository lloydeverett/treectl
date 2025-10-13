local luautils = require("treectl.luautils")

local uv = vim.loop

local M = {}

M._home_path = luautils.path_concat(os.getenv("HOME"), "")

function M.home_path()
    return M._home_path
end

function M.try_shorten_path(path)
    if luautils.starts_with(path, M._home_path) then
        return "~/" .. path:sub(#M._home_path + 1)
    end
    return path
end

function M.resolve_type(path)
    local stat = uv.fs_stat(path)
    if stat == nil then
        return nil
    end
    return stat.type
end

function M.list_directory(path, opts)
    local omit_hidden = opts ~= nil and opts.omit_hidden

    local fd = uv.fs_scandir(path)
    local results = {}

    if not fd then
        print("Failed to open directory:", path)
        return {}
    end

    while true do
        local name, type = uv.fs_scandir_next(fd)
        if not name then break end

        local hidden = luautils.starts_with(name, ".")

        if not omit_hidden or not hidden then
            local subpath = luautils.path_concat(path, name)
            local resolved_type = type
            local resolved_path = subpath

            if type == "link" then
                local stat = uv.fs_stat(subpath)
                if stat ~= nil then
                    resolved_type = stat.type
                end

                local readlink_path = uv.fs_readlink(subpath)
                if readlink_path  ~= nil then
                    resolved_path = readlink_path
                end
            end

            table.insert(results, {
                name = name,
                path = subpath,
                type = type,
                hidden = hidden,
                resolved_type = resolved_type,
                resolved_path = resolved_path
            })
        end
    end

    return results
end

function M.list_open_buffers()
    local buffers = vim.api.nvim_list_bufs()
    local result = {}

    for _, bufnr in ipairs(buffers) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
            local name = vim.api.nvim_buf_get_name(bufnr)
            table.insert(result, { bufnr = bufnr, name = name })
        end
    end

    return result
end

return M

