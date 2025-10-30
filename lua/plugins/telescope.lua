local function get_all_manager_entries(picker)
  local manager = picker.manager
  local entries = {}

  if not manager or not manager.linked_states then
    return entries
  end

  local node = manager.linked_states.head
  while node do
    local entry = node.item and node.item[1]
    if entry then
      table.insert(entries, entry)
    end
    node = node.next
  end

  return entries
end

local function handle_results_for_picker(picker_name, entries)
  print("Picker:", picker_name, "Entries:", #entries)
  for _, entry in ipairs(entries) do
    print(entry)
  end
end

local function collect_all_results(prompt_bufnr)
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
  local picker = action_state.get_current_picker(prompt_bufnr)
  local picker_name = picker.prompt_title 
    local results = {}

    -- print(picker_name)
    if picker_name == "Find Files" then
        for _, entry in ipairs(picker.finder.results) do
            table.insert(results, entry[1])  -- entry[1] is the file path
        end
        actions.close(prompt_bufnr)
        vim.fn.OpenSpecialListBuffer(results, vim.g.spectroscope_files_binds, 'filelist', 0, 0)
        return
    end

    if picker_name == "Live Grep" then

        -- print(vim.inspect(picker.manager))
        -- print(vim.inspect(get_all_manager_entries(picker)))
        for _, entry in ipairs(get_all_manager_entries(picker)) do
            table.insert(results, entry[1])  -- entry[1] is the file path
        end
        -- print(vim.inspect(results))
        actions.close(prompt_bufnr)
        vim.fn.OpenSpecialListBuffer(results, vim.g.spectroscope_grep_binds, 'greplist', 0, 0)
        return
    end
    -- for _, path in ipairs(results) do
        -- print(path)
    -- end

  -- New way to get all results
  -- for _, entry in ipairs(picker.manager:results()) do
    -- table.insert(results_, entry.value)
  -- end

  -- local picker_name = picker.prompt_title or "unknown"
  -- actions.close(prompt_bufnr)
  -- handle_results_for_picker(picker_name, results)
end

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
            ["<C-s>"] = collect_all_results
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
            ["<C-s>"] = collect_all_results
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
