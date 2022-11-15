local keymap = vim.keymap.set

keymap('', '<F6>', '<cmd>Dispatch browser-sync start --server --files "*.js, *.html, *.css"<CR>')
keymap('', '<F7>', '<cmd>Dispatch npm run dev<CR>')

keymap({ 'n', 'v', }, '<leader>e', '<cmd>NvimTreeToggle<cr>')

-- buffers
keymap({ 'n', 'v', }, "<leader>bd", "<cmd>bd<CR>")

-- git
keymap({ 'n', 'v', }, "<leader>gbt", "<cmd>GitBlameToggle<CR>")
keymap({ 'n', 'v', }, "<leader>gbu", "<cmd>GitBlameOpenCommitURL<CR>")

-- telescope
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

-- tmux
keymap('', "<M-h>", "<cmd>TmuxNavigateLeft<CR>")
keymap('', "<M-j>", "<cmd>TmuxNavigateDown<CR>")
keymap('', "<M-k>", "<cmd>TmuxNavigateUp<CR>")
keymap('', "<M-l>", "<cmd>TmuxNavigateRight<CR>")

-- pounce (motion)
keymap({ 'n', 'v' }, "s", "<cmd>Pounce<CR>")
keymap({ 'n', 'v' }, "S", "<cmd>PounceRepeat<CR>")

-- zenmode
keymap('', "<M-z>", "<cmd>ZenMode<CR>")
