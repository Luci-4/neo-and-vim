
local function get_scope_breadcrumbs(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({bufnr = bufnr})
    if not clients[1] then return end
    local client = clients[1]

    local params = vim.lsp.util.make_position_params(nil, client.offset_encoding)
    vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", params, function(err, result, _, _)
        if err or not result or vim.tbl_isempty(result) then
            vim.g.breadcrumbs_per_buffer = {}
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

    -- vim.g.breadcrumbs_per_buffer[bufnr] = breadcrumbs
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == bufnr then
        vim.api.nvim_set_option_value("winbar", breadcrumbs, { scope = "local", win = win })
      end
    end
end)
end
local function update_breadcrumbs(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    get_scope_breadcrumbs(bufnr)
end


vim.api.nvim_create_augroup("BreadcrumbsUpdate", { clear = true })

vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
    group = "BreadcrumbsUpdate",
    callback = function()
        update_breadcrumbs()
    end,
})
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
vim.opt.winborder = 'rounded'
vim.lsp.config("clangd", {
    cmd = { "clangd", '--compile-commands-dir=build' },
    filetypes = { "c", "cpp" , 'h', 'hpp', 'cc'},
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cc', 'h', 'hpp'},
    root_markers = { '.clangd', 'compile_commands.json', '.git' },
})

vim.lsp.config("pyright", {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', '.git' },
})

vim.lsp.config['vimls'] = {
    cmd = { 'vim-language-server', '--stdio' },
    filetypes = { 'vim', 'vimscript' },
    root_markers = { '.vimrc', '.git' },
}

vim.lsp.enable({ "clangd", "pyright" })

vim.diagnostic.config({
virtual_lines = false,
virtual_text = true,
underline = true,
update_in_insert = false,
severity_sort = true,
float = {
  border = "rounded",
  source = true,
},
signs = {
  text = {
    [vim.diagnostic.severity.ERROR] = "E ",
    [vim.diagnostic.severity.WARN]  = "W ",
    [vim.diagnostic.severity.INFO]  = "I ",
    [vim.diagnostic.severity.HINT]  = "H ",
  },
  numhl = {
    [vim.diagnostic.severity.ERROR] = "ErrorMsg",
    [vim.diagnostic.severity.WARN]  = "WarningMsg",
  },
},
})
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        local bufnr = event.buf

        vim.cmd [[set completeopt+=menuone,noselect,popup]]

        vim.lsp.completion.enable(true, client.id, bufnr, {
          autotrigger = true,

        convert = function(item)
            local token = item.label:match("^[%w_]+") or item.label

          return {
            abbr = item.filterText,        -- what shows in the menu

            menu = "",
            kind = vim.lsp.protocol.CompletionItemKind[item.kind] or "",    -- symbol kind for icon in menu
            insertText = token,  -- insert just the function/variable name
            textEdit = nil,      -- ignore LSP textEdit (prevents signature insertion)
          }
        end,
        })

        local completion_group = vim.api.nvim_create_augroup('lsp-auto-complete', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHoldI', 'TextChangedI' }, {
          buffer = bufnr,
          group = completion_group,
          callback = function()
            vim.lsp.completion.get()
          end,
        })

        vim.keymap.set('i', '<Esc>j', '<C-n>', { noremap = true, silent = true, desc = 'Next completion item' })
        vim.keymap.set('i', '<Esc>k', '<C-p>', { noremap = true, silent = true, desc = 'Previous completion item' })
        local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        vim.keymap.set('n', "<leader>gd", vim.diagnostic.open_float)
        vim.keymap.set('n', "<leader>gi", vim.lsp.buf.implementation)
        vim.keymap.set('n', "<leader>ic", vim.lsp.buf.incoming_calls)
        vim.keymap.set('n', "gr", vim.lsp.buf.references)
        vim.keymap.set('n', "K", vim.lsp.buf.hover)
        vim.keymap.set('n', "gs", vim.lsp.buf.signature_help)
        vim.keymap.set('n', "gD", vim.lsp.buf.declaration)
        vim.keymap.set('n', "<leader>ca", vim.lsp.buf.code_action)
        vim.keymap.set('n', "<leader>lr", vim.lsp.buf.rename)
        vim.keymap.set('n', "<leader>fl", vim.lsp.buf.format)
        vim.keymap.set('v', '<leader>fl', format_selection)
        vim.keymap.set('n', "gd", vim.lsp.buf.definition)

        local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
                return client:supports_method(method, bufnr)
            else
                return client.supports_method(method, { bufnr = bufnr })
            end
        end

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })

            -- When cursor stops moving: Highlights all instances of the symbol under the cursor
            -- When cursor moves: Clears the highlighting
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
            })

            -- When LSP detaches: Clears the highlighting
            vim.api.nvim_create_autocmd('LspDetach', {
                group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
                callback = function(event2)
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
                end,
            })
        end
    end,


})
