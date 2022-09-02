require 'nvim-tree'.setup {
    -- update the focused file on `BufEnter`, un-collapses the folders
    -- recursively until it finds the file
    update_focused_file = {
        enable = true
    },
    actions = {
        open_file = {
            quit_on_open = true,
        }
    },
    renderer = {
        icons = {
            show = {
                git = true,
                folder = true,
                file = true,
                folder_arrow = false
            },

        },
        indent_markers = {
            enable = true
        }
    }
}
