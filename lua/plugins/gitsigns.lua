return {
    'lewis6991/gitsigns.nvim',
    config = function()
        require('gitsigns').setup {
          signs = {
            add          = { text = '┃' },
            change       = { text = '┃' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
          },
          signs_staged = {
            add          = { text = '┃' },
            change       = { text = '┃' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
          },
          signs_staged_enable = true,
          signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
          numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
          linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
          word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
          watch_gitdir = {
            follow_files = true
          },
          auto_attach = true,
          attach_to_untracked = false,
          current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
          current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
            delay = 1000,
            ignore_whitespace = false,
            virt_text_priority = 100,
            use_focus = true,
          },
          current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
          sign_priority = 6,
          update_debounce = 400,
          status_formatter = nil, -- Use default
          max_file_length = 40000, -- Disable if file is longer than this (in lines)
          preview_config = {
            -- Options passed to nvim_open_win
            style = 'minimal',
            relative = 'cursor',
            row = 0,
            col = 1
          },
        on_attach = function(bufnr)
            local gitsigns = require('gitsigns')

            local function map(mode, l, r, opts)
              opts = opts or {}
              opts.buffer = bufnr
              vim.keymap.set(mode, l, r, opts)
            end

            -- Navigation
            -- map('n', ']c', function()
              -- if vim.wo.diff then
                -- vim.cmd.normal({']c', bang = true})
              -- else
                -- gitsigns.nav_hunk('next')
              -- end
            -- end)

            -- map('n', '[c', function()
              -- if vim.wo.diff then
                -- vim.cmd.normal({'[c', bang = true})
              -- else
                -- gitsigns.nav_hunk('prev')
              -- end
            -- end)

            -- Actions
            -- map('n', '<leader>hs', gitsigns.stage_hunk)
            -- map('n', '<leader>hr', gitsigns.reset_hunk)

            -- map('v', '<leader>hs', function()
              -- gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            -- end)

            -- map('v', '<leader>hr', function()
              -- gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            -- end)

            -- map('n', '<leader>hS', gitsigns.stage_buffer)
            -- map('n', '<leader>hR', gitsigns.reset_buffer)
            map('n', '<leader>ghp', gitsigns.preview_hunk)
            map('n', '<leader>ghi', gitsigns.preview_hunk_inline)

            map('n', '<leader>ghb', function()
              gitsigns.blame_line({ full = true })
            end)

            map('n', '<leader>ghd', gitsigns.diffthis)

            map('n', '<leader>ghD', function()
              gitsigns.diffthis('~')
            end)

            -- map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
            -- map('n', '<leader>hq', gitsigns.setqflist)

            -- Toggles
            map('n', '<leader>gtb', gitsigns.toggle_current_line_blame)
            map('n', '<leader>gtw', gitsigns.toggle_word_diff)

            -- Text object
            -- map({'o', 'x'}, 'ih', gitsigns.select_hunk)
        end
        }
    end
}
