
local M = {}

M.Comment = "treectl_Comment"
M.Hidden = "treectl_Hidden"
M.Directory = "treectl_Directory"
M.ErrorMsg = "treectl_ErrorMsg"
M.Special = "treectl_Special"
M.Debug = "treectl_Debug"
M.IndicatorActive = "treectl_IndicatorActive"
M.IndicatorInactive = "treectl_IndicatorInactive"
M.TreeModNvim = "treectl_TreeModNvim"
M.TreeModFs = "treectl_TreeModFs"
M.TreeModBuiltins = "treectl_TreeModBuiltins"
M.TreeModOther = "treectl_TreeModOther"

function M.configure()
    local function define_hl(name, color_index)
        vim.api.nvim_set_hl(0, name, { fg = vim.g["terminal_color_" .. color_index], ctermfg = color_index, force = true })
    end
    define_hl(M.Special,         3)
    define_hl(M.TreeModFs,       2)
    define_hl(M.TreeModNvim,     5)
    define_hl(M.TreeModBuiltins, 6)
    define_hl(M.TreeModOther,    4)

    vim.api.nvim_set_hl(0, M.Comment,           { link = "Comment"     })
    vim.api.nvim_set_hl(0, M.Hidden,            { link = "Comment"     })
    vim.api.nvim_set_hl(0, M.Directory,         { link = M.TreeModFs   })
    vim.api.nvim_set_hl(0, M.ErrorMsg,          { link = "ErrorMsg"    })
    vim.api.nvim_set_hl(0, M.Debug,             { link = M.Special     })
    vim.api.nvim_set_hl(0, M.IndicatorActive,   { link = M.Special     })
    vim.api.nvim_set_hl(0, M.IndicatorInactive, { link = "LineNr"      })
end

return M

