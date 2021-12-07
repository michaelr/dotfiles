set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set nofoldenable

let g:markdown_folding = 1
" for markdown files, fold using syntax highlighting because there isn't a
" treesitter markdown parser yet
" see https://github.com/nvim-treesitter/nvim-treesitter/issues/872
autocmd FileType markdown setlocal foldmethod=syntax
