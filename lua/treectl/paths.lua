
local M = {}

M.PATH_NOT_FOUND = "PATH_NOT_FOUND"
M.PATH_NOT_HANDLED = "PATH_NOT_HANDLED"

function M.path_display_text(path)
    if path == nil then
        return "∅"
    end
    return path:gsub("%z", "␀")
end

return M

