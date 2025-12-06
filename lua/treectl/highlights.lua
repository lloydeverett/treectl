
local minicolors = require("treectl.mini.colors")

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
    local color_scheme = minicolors.get_colorscheme()
    local function term_palette_color(index)
        return color_scheme.terminal[index]
    end
    vim.notify(vim.inspect(color_scheme.terminal))
    local function set_termcolor_hl(name, color_index)
        local cmd = "hi! def " .. name .. " ctermfg=" .. color_index
        if term_palette_color(color_index) ~= nil then
            cmd = cmd .. " guifg=" .. term_palette_color(color_index)
        end
        vim.cmd(cmd)
    end

    set_termcolor_hl(M.TreeModFs,       2)
    set_termcolor_hl(M.TreeModNvim,     5)
    set_termcolor_hl(M.TreeModBuiltins, 6)
    set_termcolor_hl(M.TreeModOther,    4)

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

