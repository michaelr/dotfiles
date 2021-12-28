autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })
let g:db_ui_auto_execute_table_helpers = 1
let g:db_ui_use_nerd_fonts = 1
let g:db_ui_win_position = "right"

function SqlFormatBuffer()
    if &modified
        let cursor_pos = getpos('.')
        :%!sql-formatter -u -l mysql
        call setpos('.', cursor_pos)
    endif
endfunction
autocmd FileType mysql autocmd BufWritePre <buffer> :call SqlFormatBuffer()
