local clients = {}

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn",  { fg = "#F18FB0", bg = "#271e28" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#ac2958", bg = "#21131f" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo",  { fg = "#849be0", bg = "#1d1f2d" })
-- Signs (gutter icons)
vim.api.nvim_set_hl(0, "DiagnosticSignWarn",  { fg = "#F18FB0", bg = "#271e28" })
vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = "#ac2958", bg = "#21131f" })
vim.api.nvim_set_hl(0, "DiagnosticSignInfo",  { fg = "#849be0", bg = "#1d1f2d" })

vim.lsp.config('*', {
    capabilities = {
        textDocument = {
            semanticTokens = { multilineTokenSupport = true }
        }
    },
    root_markers = { '.git' },
})

local function get_scope_breadcrumbs(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({bufnr = bufnr})
    if not clients[1] then return end
    local client = clients[1]

    local params = vim.lsp.util.make_position_params(nil, client.offset_encoding)
    vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", params, function(err, result, _, _)
        if err or not result or vim.tbl_isempty(result) then
            vim.g.breadcrumbs = "__"
            return
        end

        local function recurse(symbols, pos, scope)
            for _, sym in ipairs(symbols) do
                local range = sym.range or sym.location.range
                local start_ = range.start
                local stop_ = range["end"]

                if not (
                    pos.line < start_.line
                    or pos.line > stop_.line
                    or (pos.line == start_.line and pos.character < start_.character)
                    or (pos.line == stop_.line and pos.character > stop_.character)
                ) then
                table.insert(scope, sym)
                if sym.children then
                    return recurse(sym.children, pos, scope)
                end
            end
        end
        return scope
    end

    local pos = vim.api.nvim_win_get_cursor(0)
    pos = { line = pos[1] - 1, character = pos[2] }

    local scope = recurse(result, pos, {}) or {}
    local breadcrumbs = vim
    .iter(scope)
    :map(function(s) return vim.fn.FormatSymbolForBreadcrumbs(s.name, s.kind) end)
    :join(" > ")

    vim.g.breadcrumbs = breadcrumbs
    vim.opt.statusline = "%f %y %{g:breadcrumbs} %=Ln:%l Col:%c"
end)
end


local function update_breadcrumbs(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    get_scope_breadcrumbs(bufnr)
end

local function go_to_definition()
    local params = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result, _, _)
        if err or not result or vim.tbl_isempty(result) then
            vim.notify("No definition found", vim.log.levels.INFO)
            return
        end

        local items = vim.lsp.util.locations_to_items(result, "utf-8")

        if #items == 1 then
            local loc = items[1]
            vim.api.nvim_win_set_buf(0, vim.fn.bufnr(loc.filename))
            vim.api.nvim_win_set_cursor(0, {loc.lnum, loc.col})
        else
            local formatted = vim.tbl_map(function(it)
                local relpath = vim.fn.fnamemodify(it.filename, ":.")
                return string.format("%s:%d:%d:%s", relpath, it.lnum, it.col, it.text or "")
            end, items)

            vim.fn.OpenSpecialListBuffer(formatted, vim.g.spectroscope_references_binds, "referenceslist", 1, 0)
        end
    end)
end

local function show_references()
    local params = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(0, "textDocument/references", params, function(err, result, _, _)
        if err or not result or vim.tbl_isempty(result) then
            vim.notify("No references found", vim.log.levels.INFO)
            return
        end

        local items = vim.lsp.util.locations_to_items(result, "utf-8")
        local formatted = vim.tbl_map(function(it)
            local relpath = vim.fn.fnamemodify(it.filename, ":.")
            return string.format("%s:%d:%d:%s", relpath, it.lnum, it.col, it.text or "")
        end, items)

        vim.fn.OpenSpecialListBuffer(formatted, vim.g.spectroscope_references_binds, "referenceslist", 1, 0)
    end)
end

local function show_diagnostics()
    local bufnr = vim.api.nvim_get_current_buf()
    local diags = vim.diagnostic.get(bufnr)

    local old_diags = vim.tbl_map(function(diag)
        local sign_map = {
            [vim.diagnostic.severity.ERROR] = "E",
            [vim.diagnostic.severity.WARN]  = "W",
            [vim.diagnostic.severity.INFO]  = "I",
            [vim.diagnostic.severity.HINT]  = "H",
        }
        local sign = sign_map[diag.severity] or "I"
        local msg = diag.message or ""
        local relfilepath = vim.fn.fnamemodify(diag.bufnr and vim.api.nvim_buf_get_name(diag.bufnr) or "", ":.")
        local line_num =  diag.end_lnum

        return {
            sign = sign,
            msg = msg,
            filename = relfilepath,
            end_line = line_num,
        }
    end, diags)

    vim.fn.OpenSpecialListBuffer(
        old_diags,
        vim.g.spectroscope_diagnostics_binds,
        "diagnosticslist",
        1,
        0,
        "FormatDiagnosticForList"
    )
end


local function custom_complete()
  if vim.api.nvim_get_mode().mode ~= "i" then
    return
  end
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/completion", params, function(err, result, _, _)
    if err or not result then return end
    local items = result.items or result
    if vim.tbl_isempty(items) then return end

    local line = vim.api.nvim_get_current_line()
    local col = vim.fn.col('.') - 1

    local start_col = col
    while start_col > 0 do
      local c = line:sub(start_col, start_col)
      if not c:match("[%w_]") then
        break
      end
      start_col = start_col - 1
    end
    start_col = start_col + 1

    local completions = vim.tbl_map(function(item)
        return item.filterText or item.label
    end, items)

    vim.fn.complete(start_col, completions)
  end)
end
local function format_selection()
    local start_pos = vim.api.nvim_buf_get_mark(0, "<") -- start of selection
    local end_pos   = vim.api.nvim_buf_get_mark(0, ">") -- end of selection

    vim.lsp.buf.format({
        range = {
            start = { line = start_pos[1] - 1, character = start_pos[2] },
            ["end"] = { line = end_pos[1] - 1, character = end_pos[2] },
        },
        async = true,
    })
end

local function buf_set_keymaps(bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set('n', 'gd', go_to_definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

    vim.keymap.set('n', 'gr', show_references, opts)
    vim.keymap.set('n', '<leader>sc', function() get_scope_breadcrumbs(bufnr) end, opts)
    vim.keymap.set('n', '<leader>dd', show_diagnostics, opts)
    vim.keymap.set('n', '<leader>fl', function() vim.lsp.buf.format({ async = true }) end, { noremap = true, silent = true, buffer = bufnr })
    vim.keymap.set('v', '<leader>fl', format_selection, { noremap = true, silent = true, buffer = bufnr })
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

    local function term(code) 
        return vim.api.nvim_replace_termcodes(code, true, true, true) 
    end
    vim.keymap.set('i', '<M-j>', function() return vim.fn.pumvisible() == 1 and term('<C-n>') or '<M-j>' end, { expr = true, buffer = bufnr })
    vim.keymap.set('i', '<M-k>', function() return vim.fn.pumvisible() == 1 and term('<C-p>') or '<M-k>' end, { expr = true, buffer = bufnr })

    local function term(code)
        return vim.api.nvim_replace_termcodes(code, true, true, true)
    end
    vim.keymap.set('i', '<M-j>', function() 
        return vim.fn.pumvisible() == 1 and term('<C-n>') or term('<M-j>')
    end, { expr = true })

    vim.keymap.set('i', '<M-k>', function()
        return vim.fn.pumvisible() == 1 and term('<C-p>') or term('<M-k>')
    end, { expr = true })

    vim.keymap.set('i', '<Tab>', function()
        return vim.fn.pumvisible() == 1 and term('<C-y>') or '<Tab>'
    end, { expr = true })

    vim.cmd [[highlight! link Pmenu Visual]]
    vim.cmd [[highlight link PmenuSel Search]]
    vim.api.nvim_create_autocmd("TextChangedI", {
      pattern = "*",
      callback = function()
        local col = vim.fn.col('.') - 1
        if col == 0 then return end

        local line = vim.api.nvim_get_current_line()

        local start_col = col
        while start_col > 0 do
          local c = line:sub(start_col, start_col)
          if not c:match("[%w_]") then
            break
          end
          start_col = start_col - 1
        end
        local current_word = line:sub(start_col + 1, col)

        if current_word ~= "" and vim.fn.pumvisible() == 0 then
          custom_complete()
        end
      end,
    })
end


local function on_attach(client, bufnr)
    buf_set_keymaps(bufnr)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = false
vim.lsp.config['clangd'] = {
    cmd = { 'clangd', '--compile-commands-dir=build' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cc', 'h', 'hpp'},
    root_markers = { '.clangd', 'compile_commands.json', '.git' },
    capabilities = capabilities,
    on_attach = on_attach,
}

vim.lsp.config['pyright'] = {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', '.git' },
    on_attach = on_attach,
}

--vim.lsp.config['luals'] = {
    --  cmd = { 'lua-language-server' },
    --  filetypes = { 'lua' },
    --  root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
    --  settings = {
        --    Lua = {
            --      runtime = { version = 'LuaJIT' },
            --      diagnostics = { globals = { 'vim' } },
            --      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
            --    }
            --  },
            --  on_attach = on_attach,
            --}

vim.lsp.config['vimls'] = {
    cmd = { 'vim-language-server', '--stdio' },
    filetypes = { 'vim', 'vimscript' },
    root_markers = { '.vimrc', '.git' },
    on_attach = on_attach,
}

vim.lsp.config['tsserver'] = {
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    root_markers = { 'package.json', 'tsconfig.json', '.git' },
    on_attach = on_attach,
}

local server_map = {
    c = "clangd",
    cpp = "clangd",
    python = "pyright",
    --  lua = "luals",
    vim = "vimls",
    vimscript = "vimls",
    javascript = "tsserver",
    typescript = "tsserver",
    javascriptreact = "tsserver",
    typescriptreact = "tsserver",
}

vim.opt.winborder = 'rounded'
vim.o.completeopt = "menuone,noselect,noinsert"

vim.api.nvim_create_augroup("BreadcrumbsUpdate", { clear = true })

vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
    group = "BreadcrumbsUpdate",
    callback = function()
        update_breadcrumbs()
    end,
})
local lsp_clients = {}  

local function get_or_start_client(server, root_dir)
    lsp_clients[server] = lsp_clients[server] or {}

    if lsp_clients[server][root_dir] then
        return lsp_clients[server][root_dir]
    end

    local client_id = vim.lsp.start_client(vim.lsp.config[server])
    lsp_clients[server][root_dir] = client_id
    return client_id
end

local function on_buf_enter()
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")

    local server = server_map[ft]
    if not server then return end
    if vim.fn.executable(server) ~= 1 then
        return
    end    

    local root_dir = vim.fn.getcwd()
    local client_id = get_or_start_client(server, root_dir)

    if not vim.lsp.buf_is_attached(bufnr, client_id) then
        vim.lsp.buf_attach_client(bufnr, client_id)
    end
end

vim.api.nvim_create_autocmd("BufEnter", { callback = on_buf_enter })
