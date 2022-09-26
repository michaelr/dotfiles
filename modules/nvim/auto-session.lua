require("auto-session").setup {
    log_level = "error",
    auto_session_suppress_dirs = { "~/", "/" },
}
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"
