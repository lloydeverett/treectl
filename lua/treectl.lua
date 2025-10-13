
local NuiTree = require("nui.tree")
local luautils = require("treectl.luautils")
local nodes = require("treectl.nodes")
local uiutils = require("treectl.uiutils")
local highlights = require("treectl.highlights")

local modfs_init = require("treectl.mod.modfs")
local modnvim_init = require("treectl.mod.modnvim")

local M = {}

local g_buf_suffix = "treectl#state#current_buf_suffix"
local g_main_bufnr = "treectl#state#main_bufnr"
local help_suffixes = {
    pin       = "pin references to tree nodes",
    outline   = "tree-based outlining and note-taking",
    task      = "TaskWarrior integration",
    calendar  = "inbuilt calendar",
    clock     = "set and manage timers and other clock functions",
    todo      = "dev roadmap",
    www       = "browse the web from treectl",
    bookmark  = "browser bookmarks and history integration",
    llm       = "llm command integration",
    steampipe = "steampipe integration",
    matrix    = "matrix-commander integration",
    man       = "indexes man pages",
    email     = "treectl email client",
    shell     = "shell integration",
    spotify   = "Spotify integration",
    gh        = "gh command integration",
    kubectl   = "kubectl integration",
    hs        = "macOS hammerspoon integration",
    systemd   = "manage systemd services",
    unix      = "process tree, volumes, etc.",
    brew      = "manage brew packages",
    sql       = "treectl SQL client",
    takeout   = "navigate Google Takeout exports",
    docker    = "docker command integration",
    podman    = "podman command integration",
    reference = "handy reference material",
    youtube   = "browse YouTube from treectl",
}

local function init_nodes()
    local modules = {
        kv = {
            modfs = modfs_init(),
            modnvim = modnvim_init(),
        },
        -- specify an iterative ordering for modules to dictate path resolution precedence
        -- if a module earlier in the list resolves a path, later modules will not be queried
        keys = {
            "modfs",
            "modnvim",
        }
    }

    local root = {}

    table.insert(root, nodes.debug_node("-- DEBUG MODE --"                                                                             , { indicator = "none" }))
    table.insert(root, nodes.debug_node("!; = refresh node children  !/ = follow current path     !? = inspect current node"           , { indicator = "none" }))
    table.insert(root, nodes.help_node ("? = toggle help             Shift-L = expand             Shift-H = collapse"                  , { indicator = "none" }))
    table.insert(root, nodes.help_node (". = toggle node             } = next top-level           { = prev top-level"                  , { indicator = "none" }))
    table.insert(root, nodes.help_node ("g. = toggle hidden          ]] = next open top-level     [[ = up or prev open top-level"      , { indicator = "none" }))
    table.insert(root, nodes.help_node ("` = toggle debug            _ = zoom traverse into       - = zoom traverse up"                , { indicator = "none" }))
    table.insert(root, nodes.help_node ("s = preview in hsplit       Enter = default action       Shift+Enter = preview + show actions", { indicator = "none" }))
    table.insert(root, nodes.help_node ("v = preview in vsplit       d = delete (if available)    p = paste (if available)"            , { indicator = "none" }))

    luautils.insert_all(root, modules.kv.modfs.root_nodes())
    luautils.insert_all(root, modules.kv.modnvim.root_nodes())

    table.insert(root, nodes.node("pin", { hl = highlights.TreeModBuiltins, path = "pin", help_suffix = help_suffixes.pin }, {
      nodes.node("pin nodes from other subtrees here"),
    }))
    table.insert(root, nodes.node("outline", { hl = highlights.TreeModBuiltins, path = "outline", help_suffix = help_suffixes.outline }, {
      nodes.node("make your own notes here"),
      nodes.node("can be based on files in ~/.treenote"),
      nodes.node("and then each file in there looks like an expanded tree"),
    }))
    table.insert(root, nodes.node("task", { hl = highlights.TreeModBuiltins, path = "task", help_suffix = help_suffixes.task }))
    table.insert(root, nodes.node("calendar", { hl = highlights.TreeModBuiltins, path ="calendar", help_suffix = help_suffixes.calendar }, {
      nodes.node("Yesterday"),
      nodes.node("Today"),
      nodes.node("Tomorrow"),
      nodes.node("September 2025"),
      nodes.node("October 2025"),
      nodes.node("November 2025"),
      nodes.node("December 2025"),
      nodes.node("2024", { path = "calendar/2024" }),
      nodes.node("2025", { path = "calendar/2025" }, {
        nodes.node("01 [January]", {
            nodes.node("events"),
            nodes.node("days")
        }),
      }),
      nodes.node("2026", { path = "calendar/2026" }),
    }))
    table.insert(root, nodes.node("clock", { hl = highlights.TreeModBuiltins, path = "clock", help_suffix = help_suffixes.clock }, {
        nodes.node("Start 5m timer",  { hl = highlights.TreeModBuiltins, indicator = "action", path = "clock/timer/start/5m" }),
        nodes.node("Start 15m timer", { hl = highlights.TreeModBuiltins, indicator = "action", path = "clock/timer/start/15m" }),
        nodes.node("Start timer...",  { hl = highlights.TreeModBuiltins, indicator = "action", path = "clock/timer/start/custom" }),
    }))
    table.insert(root, nodes.node("todo", { path = "todo", help_suffix = help_suffixes.todo }, {
        nodes.node("GC nodes stored in caches"),
        nodes.node("fix hl color refs"),
        nodes.node("clearlist gradients as part of note function?"),
        nodes.node("maybe also ties in with pomodoro / calendar?"),
        nodes.node("todo: scratch buffers that display as text with refs in insert mode, but in normal mode refs resolve to tree nodes and render as tree nodes"),
        nodes.node("build git support into fs module"),
        nodes.node("shift + enter to zoom if current node has stable path -- although it'd be nice to zoom into a folder without it necessarily having a fixed placement in the tree, so work that out too"),
        nodes.node("maybe uri syntax along the lines of: provider-name://arbitrary/path/defined/by/provider; where provdier can return path for node or resolve a path"),
        nodes.node("and, if the provider wants, it can use its parent node to help it figure out the path when asked to return a path, but it might not need to in the filesystem case"),
        nodes.node("popup for node preview + keybindings on enter"),
        nodes.node("optionally display preview + keybindings in a split too"),
        nodes.node("allow searching by opening a scratch buffer filled with cached fully expanded node contents that links back to the real tree " ..
                    "(although some nodes you don't need to use a cache, e.g. calendar, because you can just expand all the data anyway)"),
        nodes.node("low priority: raycast?"),
    }))
    table.insert(root, nodes.node("www", { path = "www", help_suffix = help_suffixes.www }, {
      nodes.node("tab"),
    }))
    table.insert(root, nodes.node("bookmark", { path = "bookmark", help_suffix = help_suffixes.bookmark }, {
      nodes.node("integrate with browser bookmarks, history, frequent tabs, etc.?"),
    }))
    table.insert(root, nodes.node("llm", { path = "llm", help_suffix = help_suffixes.llm }))
    table.insert(root, nodes.node("steampipe", { path = "steampipe", help_suffix = help_suffixes.steampipe }))
    table.insert(root, nodes.node("matrix", { path = "matrix", help_suffix = help_suffixes.matrix }, {
        nodes.node("e.g. slack"),
        nodes.node("e.g. whatsapp"),
    }))
    table.insert(root, nodes.node("man", { path = "man", help_suffix = help_suffixes.man }))
    table.insert(root, nodes.node("email", { path = "email", help_suffix = help_suffixes.email }))
    table.insert(root, nodes.node("shell", { path = "shell", help_suffix = help_suffixes.shell }, {
      nodes.node("env"),
      nodes.node("alias"),
      nodes.node("bin"),
      nodes.node("path"),
      nodes.node("job"),
    }))
    table.insert(root, nodes.node("spotify", { path = "spotify", help_suffix = help_suffixes.spotify }))
    table.insert(root, nodes.node("gh", { path = "gh", help_suffix = help_suffixes.gh }))
    table.insert(root, nodes.node("kubectl", { path = "kubectl", help_suffix = help_suffixes.kubectl }))
    table.insert(root, nodes.node("hs", { path = "hs", help_suffix = help_suffixes.hs }))
    table.insert(root, nodes.node("systemd", { path = "systemd", help_suffix = help_suffixes.systemd }))
    table.insert(root, nodes.node("unix", { path = "unix", help_suffix = help_suffixes.unix }, {
      nodes.node("storage"),
      nodes.node("process"),
      nodes.node("netstat"),
      nodes.node("application")
    }))
    table.insert(root, nodes.node("brew", { path = "brew", help_suffix = help_suffixes.brew }))
    table.insert(root, nodes.node("sql", { path = "sql", help_suffix = help_suffixes.sql }, {
      nodes.node("sqlite"),
      nodes.node("postgres"),
      nodes.node("mysql"),
    }))
    table.insert(root, nodes.node("takeout", { path = "takeout", help_suffix = help_suffixes.takeout }))
    table.insert(root, nodes.node("docker", { path = "docker", help_suffix = help_suffixes.docker }))
    table.insert(root, nodes.node("podman", { path = "podman", help_suffix = help_suffixes.podman }))
    table.insert(root, nodes.node("reference", { path = "reference", help_suffix = help_suffixes.reference }, {
        nodes.node("palette"),
        nodes.node("gradient"),
        nodes.node("treectl"),
        nodes.node("unicode"),
        nodes.node("nerdfont"),
        nodes.node("english"),
        nodes.node("tz"),
        nodes.node("syntax", {}, {
            nodes.node("C"),
            nodes.node("C++"),
            nodes.node("Swift"),
        }),
    }))
    table.insert(root, nodes.node("youtube", { path = "youtube", help_suffix = help_suffixes.youtube }))

    return root, modules
end


local function show_tree()

    local show_debug = false
    local show_help = vim.g["treectl#show_help_by_default"] or false

    local winid = vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_win_set_buf(winid, bufnr)
    if vim.g[g_main_bufnr] == nil then
        vim.api.nvim_buf_set_name(bufnr, "treectl#0")
        vim.g[g_main_bufnr] = bufnr
    else
        vim.api.nvim_buf_set_name(bufnr, "treectl#" .. vim.g[g_buf_suffix])
        vim.g[g_buf_suffix] = vim.g[g_buf_suffix] + 1
    end

    local root_nodes, modules = init_nodes()

    local tree = NuiTree({
      winid = winid,
      nodes = root_nodes,
      prepare_node = function(node)
          return uiutils.node_get_nui_line(node, { show_help = show_help, show_debug = show_debug })
      end,
    })

    local map_options = { noremap = true, nowait = true, buffer = true }

    -- debug: toggle debug
    vim.keymap.set("n", "`", function()
        uiutils.preserve_cursor_selection(tree, function()
            show_debug = not show_debug
            tree:render()
        end)
    end, map_options)

    -- debug: follow current path and output
    vim.keymap.set("n", "!/", function()
        local node = uiutils.current_node(tree)
        local path = nodes.node_get_path(node)
        if path ~= nil then
            uiutils.follow_path(path, modules, true)
        else
            print("node path is nil")
        end
    end, map_options)

    -- debug: refresh nodes
    vim.keymap.set("n", "!;", function()
        uiutils.preserve_cursor_selection(tree, function()
            uiutils.refresh_all_children(tree, nil)
            tree:render()
        end)
    end, map_options)

    -- debug: inspect current node
    vim.keymap.set("n", "!?", function()
        local node = uiutils.current_node(tree)
        print(vim.inspect(node))
    end, map_options)

    -- toggle modfs hidden files
    vim.keymap.set("n", "g.", function()
        uiutils.preserve_cursor_selection(tree, function()
            modules.kv.modfs.toggle_show_hidden()
            uiutils.refresh_all_children(tree, modules.kv.modfs.directory_provider())
            tree:render()
        end)
    end, map_options)

    -- toggle help
    vim.keymap.set("n", "?", function()
        uiutils.preserve_cursor_selection(tree, function()
            show_help = not show_help
            tree:render()
        end)
    end, map_options)

    -- collapse current node
    vim.keymap.set("n", "H", function()
        local node = uiutils.current_node(tree)
        uiutils.node_collapse(tree, node)
        tree:render()
    end, map_options)

    -- expand current node
    vim.keymap.set("n", "L", function()
        local node = uiutils.current_node(tree)
        uiutils.node_expand(tree, node)
        tree:render()
    end, map_options)

    -- toggle current node
    vim.keymap.set("n", ".", function()
        local node = uiutils.current_node(tree)
        if node:is_expanded() then
            uiutils.node_collapse(tree, node)
        else
            uiutils.node_expand(tree, node)
        end
        tree:render()
    end, map_options)

    -- next top-level node
    vim.keymap.set("n", "}", function()
        uiutils.place_cursor_on_next_top_level_node(tree)
    end, map_options)

    -- previous top-level node
    vim.keymap.set("n", "{", function()
        uiutils.place_cursor_on_prev_top_level_node(tree)
    end, map_options)

    -- parent, or previous open top level node if at top level
    vim.keymap.set("n", "[[", function()
        uiutils.place_cursor_on_parent_or_prev_open_top_level_node(tree)
    end, map_options)

    -- next open top level node
    vim.keymap.set("n", "]]", function()
        uiutils.place_cursor_on_next_open_top_level_node(tree)
    end, map_options)

    -- add new node under current node
    -- vim.keymap.set("n", "a", function()
    --   local node = uiutils.current_node(tree)
    --   tree:add_node(
    --     node("d", {
    --       node("d-1"),
    --     }),
    --     node:get_id()
    --   )
    --   tree:render()
    -- end, map_options)

    -- delete current node
    -- vim.keymap.set("n", "d", function()
    --   local node = uiutils.current_node(tree)
    --   tree:remove_node(node:get_id())
    --   tree:render()
    -- end, map_options)

    tree:render()

end

function M.setup()

    vim.g[g_buf_suffix] = 1
    vim.g[g_main_bufnr] = nil

    math.randomseed(os.time())

    highlights.configure()

    local augroup = vim.api.nvim_create_augroup('treectl_highlights', { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            highlights.configure()
        end,
        group = augroup
    })

    vim.keymap.set("n", "<leader>n", function()
        if vim.g[g_main_bufnr] ~= nil and vim.api.nvim_buf_is_loaded(vim.g[g_main_bufnr]) then
            local winid = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(winid, vim.g[g_main_bufnr])
        else
            vim.g[g_main_bufnr] = nil
            show_tree()
        end
    end)

    vim.keymap.set("n", "<leader>m", function()
        show_tree()
    end)

end

return M

