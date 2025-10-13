local M = {}

function M.insert_all(tbl, elements)
    for i, v in ipairs(elements) do
        table.insert(tbl, v)
    end
end

function M.filter(array, predicate)
    local result = {}
    for i, v in ipairs(array) do
        if predicate(v) then
            table.insert(result, v)
        end
    end
    return result
end

function M.map(array, transformation)
    local result = {}
    for i, v in ipairs(array) do
        result[i] = transformation(v, i)
    end
    return result
end

function M.path_concat(base, suffix)
    if base:sub(-1) == "/" then
        return base .. suffix
    else
        return base .. "/" .. suffix
    end
end

function M.starts_with(str, prefix)
    return str:sub(1, #prefix) == prefix
end

return M

