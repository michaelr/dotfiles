-- Set barbar's options
vim.g.bufferline = {
    animation = false,
    auto_hide = true,
    tabpages = false,
    clickable = true,
    closable = false,
    icons = true,
    icon_custom_colors = true,

    -- Sets the maximum buffer name length.
    maximum_length = 30,

    no_name_title = 'New file',
}

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map('n', '<A-1>', ':BufferGoto 1<CR>', opts)
map('n', '<A-2>', ':BufferGoto 2<CR>', opts)
map('n', '<A-3>', ':BufferGoto 3<CR>', opts)
map('n', '<A-4>', ':BufferGoto 4<CR>', opts)
map('n', '<A-5>', ':BufferGoto 5<CR>', opts)
map('n', '<A-6>', ':BufferGoto 6<CR>', opts)
map('n', '<A-7>', ':BufferGoto 7<CR>', opts)
map('n', '<A-8>', ':BufferGoto 8<CR>', opts)
map('n', '<A-9>', ':BufferGoto 9<CR>', opts)
map('n', '<A-0>', ':BufferLast<CR>', opts)
