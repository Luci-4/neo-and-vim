vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

vim.lsp.config('*', {
    capabilities = {
        textDocument = {
            semanticTokens = { multilineTokenSupport = true }
        }
    },
    root_markers = { '.git' },
})

local function buf_set_keymaps(bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'ge', vim.diagnostic.setloclist, opts)
    vim.keymap.set('n', '<leader>ds', vim.lsp.buf.document_symbol, opts)
    vim.keymap.set('n', '<leader>pg', function() print("Partial Project Graph Placeholder") end, opts)
    vim.keymap.set('n', '<leader>sc', function() print("Scope Status Placeholder") end, opts)

    local function term(code) return vim.api.nvim_replace_termcodes(code, true, true, true) end

    vim.keymap.set('i', '<M-j>', function() return vim.fn.pumvisible() == 1 and term('<C-n>') or '<M-j>' end, { expr = true, buffer = bufnr })
    vim.keymap.set('i', '<M-k>', function() return vim.fn.pumvisible() == 1 and term('<C-p>') or '<M-k>' end, { expr = true, buffer = bufnr })
    vim.keymap.set('i', '<Esc>j', function() return vim.fn.pumvisible() == 1 and term('<C-n>') or '<M-j>' end, { expr = true, buffer = bufnr })
    vim.keymap.set('i', '<Esc>k', function() return vim.fn.pumvisible() == 1 and term('<C-p>') or '<M-k>' end, { expr = true, buffer = bufnr })
    vim.keymap.set('i', '<Tab>', function() return vim.fn.pumvisible() == 1 and term('<C-y>') or '<Tab>' end, { expr = true, buffer = bufnr })

    vim.cmd [[highlight! link Pmenu Visual]]
    vim.cmd [[highlight link PmenuSel Search]]
end

local function setup_format_on_save(client, bufnr)
    if client.supports_method('textDocument/formatting') and
       not client.supports_method('textDocument/willSaveWaitUntil') then
        vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format({ bufnr = bufnr, id = client.id, timeout_ms = 1000 })
            end,
        })
    end
end

local function on_attach(client, bufnr)
    buf_set_keymaps(bufnr)
    setup_format_on_save(client, bufnr)
end

vim.lsp.config['clangd'] = {
    cmd = { 'clangd', '--compile-commands-dir=build' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
    root_markers = { '.clangd', 'compile_commands.json', '.git' },
    on_attach = on_attach,
}

vim.lsp.config['pyright'] = {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', '.git' },
    on_attach = on_attach,
}

vim.lsp.config['luals'] = {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
    settings = {
        Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim' } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
        }
    },
    on_attach = on_attach,
}

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

for _, server in ipairs({ 'clangd', 'pyright', 'luals', 'vimls', 'tsserver' }) do
    vim.lsp.enable(server)
end
