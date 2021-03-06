vim.g.nvim_tree_quit_on_open = 1
vim.g.nvim_tree_show_icons = {
    git = 1,
    folders = 1,
    files = 1,
    folder_arrows = 0
}
vim.g.nvim_tree_indent_markers = 1

require'nvim-tree'.setup {
    -- update the focused file on `BufEnter`, un-collapses the folders
    -- recursively until it finds the file
    update_focused_file = {enable = true}
}
