vim.o.mouse = "a"
vim.o.cursorline = true
vim.g.mapleader = " "

-- use system clipboard
-- NOTE: for WSL win32yank.exe must been in the path and xclip must not be
vim.o.clipboard = "unnamedplus"

-- More natural pane splitting
vim.o.splitbelow = true
vim.o.splitright = true

-- Indentation
-- filetype plugin indent on
-- Show existing tab with 4 spaces width
vim.o.tabstop = 4
-- When indenting with '>', use 4 spaces width
vim.o.shiftwidth = 4
-- On pressing tab, insert 4 spaces
vim.o.expandtab = true

-- Use terminal GUI colors
vim.o.termguicolors = true

vim.o.showmode = false

vim.o.backup = false
vim.o.writebackup = false

-- " Better display for messages
vim.o.cmdheight = 2

-- You will have bad experience for diagnostic messages when it's default 4000.
vim.o.updatetime = 300

-- " don't give |ins-completion-menu| messages.
vim.o.shortmess = vim.o.shortmess .. 'c'

-- " always show signcolumns
vim.o.signcolumn = 'yes'

-- Setup whitespace chars
vim.o.listchars = 'eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:.'

-- " Add line length end indicator
vim.o.colorcolumn = '80'

vim.o.shell = 'fish'

-- turn off search highlight
vim.o.hlsearch = false
