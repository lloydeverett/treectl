
local M = {}

M.Comment = "treectl_Comment"
M.Hidden = "treectl_Hidden"
M.Directory = "treectl_Directory"
M.ErrorMsg = "treectl_ErrorMsg"
M.Number = "treectl_Number"
M.Debug = "treectl_Debug"
M.IndicatorActive = "treectl_IndicatorActive"
M.IndicatorInactive = "treectl_IndicatorInactive"
M.TreeModNvim = "treectl_TreeModNvim"
M.TreeModFs = "treectl_TreeModFs"
M.TreeModBuiltins = "treectl_TreeModBuiltins"
M.TreeModOther = "treectl_TreeModOther"

function M.configure()
    vim.api.nvim_set_hl(0, M.TreeModFs,         { fg = vim.g["terminal_color_" .. 2], ctermfg = 2, force = true })
    vim.api.nvim_set_hl(0, M.TreeModNvim,       { fg = vim.g["terminal_color_" .. 5], ctermfg = 5, force = true })
    vim.api.nvim_set_hl(0, M.TreeModBuiltins,   { fg = vim.g["terminal_color_" .. 6], ctermfg = 6, force = true })
    vim.api.nvim_set_hl(0, M.TreeModOther,      { fg = vim.g["terminal_color_" .. 4], ctermfg = 4, force = true })
    vim.api.nvim_set_hl(0, M.Comment,           { link = "Comment"     })
    vim.api.nvim_set_hl(0, M.Hidden,            { link = "Comment"     })
    vim.api.nvim_set_hl(0, M.Directory,         { link = M.TreeModFs   })
    vim.api.nvim_set_hl(0, M.ErrorMsg,          { link = "ErrorMsg"    })
    vim.api.nvim_set_hl(0, M.Number,            { link = "Number"      })
    vim.api.nvim_set_hl(0, M.Debug,             { link = "SpecialChar" })
    vim.api.nvim_set_hl(0, M.IndicatorActive,   { link = "SpecialChar" })
    vim.api.nvim_set_hl(0, M.IndicatorInactive, { link = "LineNr"      })
end

return M

