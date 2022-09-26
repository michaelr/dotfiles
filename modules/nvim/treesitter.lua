require 'nvim-treesitter.configs'.setup {
    -- Note: installing nix grammer requires treesitter installed as command line too
    ensure_installed = {
        "bash", "c", "css", "dockerfile", "elixir", "go", "haskell", "html",
        "java", "javascript", "json", "latex", "lua", "nix", "python",
        "regex", "ruby", "rust", "scss", "toml", "tsx", "typescript", "yaml",
        "heex"
    },
    highlight = {
        enable = true,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm"
        }
    },
    indent = { enable = true },
    parser_install_dir = "~/.local/treesitter-parsers",
    refactor = { highlight_definitions = { enable = true } },
    textobjects = {
        select = {
            enable = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["ab"] = "@block.outer",
                ["ib"] = "@block.inner",
                ["aa"] = "@parameter.outer",
                ["ia"] = "@parameter.inner"
            }
        },
        swap = {
            enable = true,
            swap_next = { ["<leader>npn"] = "@parameter.inner" },
            swap_previous = { ["<leader>npp"] = "@parameter.inner" }
        }
    }
}
vim.opt.runtimepath:append("~/.local/treesitter-parsers")
