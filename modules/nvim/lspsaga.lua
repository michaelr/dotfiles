local keymap = vim.keymap.set
local saga = require('lspsaga')

saga.init_lsp_saga()

keymap("n", "gh", "<cmd>Lspsaga lsp_finder<CR>", { silent = true })
keymap({ "n", "v" }, "<leader>ca", "<cmd>Lspsaga code_action<CR>", { silent = true })
keymap("n", "gr", "<cmd>Lspsaga rename<CR>", { silent = true })
keymap("n", "gd", "<cmd>Lspsaga peek_definition<CR>", { silent = true })
keymap("n", "<F1>", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true })
keymap("n", "<F2>", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { silent = true })
-- Diagnsotic jump can use `<c-o>` to jump back
keymap("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { silent = true })
keymap("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", { silent = true })
-- keymap("n", "<leader>o", "<cmd>LSoutlineToggle<CR>", { silent = true })
keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { silent = true })
keymap("n", "<A-d>", "<cmd>Lspsaga open_floaterm lazygit<CR>", { silent = true })
keymap("t", "<A-d>", [[<C-\><C-n><cmd>Lspsaga close_floaterm<CR>]], { silent = true })
