require('lualine').setup {
    options = {
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        -- Hack : This is defined in the nvim/default.nix (String interpolation)
        theme = statusline_theme,
        iconsEnabled = true
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'filename' },
        lualine_c = { { 'diagnostics', sources = { 'nvim_lsp' } } },
        lualine_x = { 'diff', 'branch' },
        lualine_y = { 'filetype' },
        lualine_z = { 'progress', 'location' }
    }
}
