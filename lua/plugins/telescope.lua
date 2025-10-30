return {
  'nvim-telescope/telescope.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local telescope = require('telescope')
    local actions = require('telescope.actions')

    telescope.setup({
      defaults = {
        prompt_prefix = "> ",
        selection_caret = "➤ ",
        entry_prefix = "• ",
        initial_mode = "insert",
        scroll_strategy = "cycle",
        mappings = {
          i = {
            ["<A-j>"] = actions.cycle_history_next,
            ["<A-k>"] = actions.cycle_history_prev,
            ["<Esc>j"] = actions.cycle_history_next,
            ["<Esc>k"] = actions.cycle_history_prev,
            ["<A-j>"] = actions.move_selection_next,
            ["<A-k>"] = actions.move_selection_previous,
            ["<Esc>j"] = actions.move_selection_next,
            ["<Esc>k"] = actions.move_selection_previous,
            ["<C-c>"] = actions.close,
            ["<CR>"] = actions.select_default,
            ["<C-x>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-t>"] = actions.select_tab,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<PageUp>"] = actions.results_scrolling_up,
            ["<PageDown>"] = actions.results_scrolling_down,
            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-l>"] = actions.complete_tag,
          },
          n = {
            ["<C-c>"] = actions.close,
            ["<CR>"] = actions.select_default,
            ["<C-x>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-t>"] = actions.select_tab,
            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["j"] = actions.move_selection_next,
            ["k"] = actions.move_selection_previous,
            ["<Down>"] = actions.move_selection_next,
            ["<Up>"] = actions.move_selection_previous,
            ["gg"] = actions.move_to_top,
            ["G"] = actions.move_to_bottom,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
          },
        },
      },

      -- pickers = {
        -- find_files = {
          -- theme = "dropdown",
          -- previewer = false,
          -- hidden = true,
        -- },
        -- live_grep = {
          -- theme = "ivy",
        -- },
        -- buffers = {
          -- theme = "dropdown",
          -- sort_lastused = true,
          -- previewer = false,
        -- },
        -- help_tags = {
          -- theme = "dropdown",
        -- },
      -- },

      -- extensions = {
        -- fzf = {
          -- fuzzy = true,
          -- override_generic_sorter = true,
          -- override_file_sorter = true,
          -- case_mode = "smart_case",
        -- },
        -- file_browser = {
          -- theme = "ivy",
          -- hijack_netrw = true,
        -- },
        -- ["ui-select"] = {
          -- require("telescope.themes").get_dropdown({})
        -- },
      -- },
    })
  end
}
