local keymap = vim.keymap.set

keymap('', '<F6>', '<cmd>Dispatch browser-sync start --server --files "*.js, *.html, *.css"<CR>')
keymap('', '<F7>', '<cmd>Dispatch npm run dev<CR>')
keymap({ 'n', 'v', }, '<leader>e', '<cmd>NvimTreeToggle<cr>')
keymap({ 'n', 'v', }, "<leader>bd", "<cmd>bd<CR>")
keymap('', "<leader>sb", "<cmd>Telescope buffers<CR>")
keymap('', "<leader>sc", "<cmd>Telescope command_history<CR>")
keymap('', "<leader>sC", "<cmd>Telescope commands<CR>")
keymap('', "<leader>sf", "<cmd>Telescope find_files<CR>")
keymap('', "<leader>sh", "<cmd>Telescope help_tags<CR>")
keymap('', "<leader>sm", "<cmd>Telescope marks<CR>")
keymap('', "<leader>sM", "<cmd>Telescope man_pages<CR>")
keymap('', "<leader>sn", "<cmd>Telescope manix<CR>")
keymap('', "<leader>sr", "<cmd>Telescope registers<CR>")
keymap('', "<leader>st", "<cmd>Telescope live_grep<CR>")
keymap('', "<leader>sT", "<cmd>TodoTelescope<CR>")
