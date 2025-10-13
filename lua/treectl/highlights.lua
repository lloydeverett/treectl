
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
    vim.api.nvim_set_hl(0, "treectl_Comment"          , { link = "Comment" })
    vim.api.nvim_set_hl(0, "treectl_Hidden"           , { link = "Comment" })
    vim.api.nvim_set_hl(0, "treectl_Directory"        , { link = "Directory" })
    vim.api.nvim_set_hl(0, "treectl_ErrorMsg"         , { link = "ErrorMsg" })
    vim.api.nvim_set_hl(0, "treectl_Number"           , { link = "Number" })
    vim.api.nvim_set_hl(0, "treectl_Debug"            , { link = "SpecialChar" })
    vim.api.nvim_set_hl(0, "treectl_IndicatorActive"  , { link = "SpecialChar" })
    vim.api.nvim_set_hl(0, "treectl_IndicatorInactive", { link = "LineNr" })
    vim.api.nvim_set_hl(0, "treectl_TreeModFs"        , { link = "markdownH4" })
    vim.api.nvim_set_hl(0, "treectl_TreeModNvim"      , { link = "markdownH2" })
    vim.api.nvim_set_hl(0, "treectl_TreeModBuiltins"  , { link = "markdownH5" })
    vim.api.nvim_set_hl(0, "treectl_TreeModOther"     , { link = "markdownH6" })
end

return M

