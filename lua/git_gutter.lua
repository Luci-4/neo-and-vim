local M = {}

vim.wo.signcolumn = "yes:2"

vim.fn.sign_define('GitGutterChange', {
    text = '~',
    texthl = 'GitGutterChange',
    numhl = '',
    linehl = '',
})

vim.cmd [[
highlight GitGutterChange guifg=#A6E22E ctermfg=2
]]

local function get_git_changes()
    local file = vim.fn.expand('%')
    local handle = io.popen('git diff --unified=0 ' .. file)
    if not handle then return {} end
    local result = handle:read('*a')
    handle:close()

    local changed = {}

    for header in result:gmatch("@@.-@@") do
        local start_line, count = header:match("@@ %-%d+,?%d* %+([0-9]+),?([0-9]*) @@")
        start_line = tonumber(start_line)
        count = tonumber(count) or 1
        for i = 0, count-1 do
            table.insert(changed, start_line + i)
        end
    end
    return changed
end

local function place_git_signs()
    vim.fn.sign_unplace('git_gutter') 
    local changed_lines = get_git_changes()
    local bufnr = vim.fn.bufnr('%')

    local line_signs = {}

    for _, lnum in ipairs(changed_lines) do
        line_signs[lnum] = 'GitGutterChange'
    end

    for lnum, sign in pairs(line_signs) do
        vim.fn.sign_place(0, 'git_gutter', sign, bufnr, {lnum = lnum, priority = 1})
    end
end

function M.setup()
    if vim.g.has_repo ~= 1 then
        return
    end
    vim.api.nvim_create_autocmd({'BufWritePost', 'BufReadPost'}, {
        callback = function()
            place_git_signs()
        end
    })
end

return M
