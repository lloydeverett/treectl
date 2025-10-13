
local M = {}

M.PATH_NOT_FOUND = "PATH_NOT_FOUND"
M.PATH_NOT_HANDLED = "PATH_NOT_HANDLED"

function M.path_display_text(path)
    if path == nil then
        return "∅"
    elseif type(path) == "string" then
        return path
    elseif type(path) == "table" then
        local result = ""
        for i, v in ipairs(path) do
            if i > 1 then
                result = result .. "␀"
            end
            result = result .. v
        end
        return result
    else
        return "???"
    end
end

return M

