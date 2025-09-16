
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


local function get_scope_breadcrumbs(bufnr)
  local params = vim.lsp.util.make_position_params()
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

    vim.fn.OpenSpecialListBuffer(formatted, vim.g.spectroscope_binds_reference_directions, "referenceslist", 1, 0)
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
    vim.g.spectroscope_binds_diagnostics_directions,
    "diagnosticslist",
    1,
    0,
    "FormatDiagnosticForList"
  )
end

local function custom_complete()
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/completion", params, function(err, result, _, _)
    if err or not result then return end
    local items = result.items or result
    local completions = vim.tbl_map(function(item)
      return item.insertText or item.label
    end, items)
    vim.fn.complete(vim.fn.col(".") - 1, completions)
  end)
end


local function buf_set_keymaps(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'ge', vim.diagnostic.setloclist, opts)
  vim.keymap.set('n', '<leader>ds', vim.lsp.buf.document_symbol, opts)

  vim.keymap.set('n', 'gr', show_references, opts)
  vim.keymap.set('n', '<leader>sc', function() get_scope_breadcrumbs(bufnr) end, opts)
  vim.keymap.set('n', '<leader>dd', show_diagnostics, opts)

  local function term(code) return vim.api.nvim_replace_termcodes(code, true, true, true) end
  vim.keymap.set('i', '<M-j>', function() return vim.fn.pumvisible() == 1 and term('<C-n>') or '<M-j>' end, { expr = true, buffer = bufnr })
  vim.keymap.set('i', '<M-k>', function() return vim.fn.pumvisible() == 1 and term('<C-p>') or '<M-k>' end, { expr = true, buffer = bufnr })
  vim.keymap.set('i', '<Esc>j>', function() return vim.fn.pumvisible() == 1 and term('<C-n>') or '<M-j>' end, { expr = true, buffer = bufnr })
  vim.keymap.set('i', '<Esc>k>', function() return vim.fn.pumvisible() == 1 and term('<C-p>') or '<M-k>' end, { expr = true, buffer = bufnr })
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
