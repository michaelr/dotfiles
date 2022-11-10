{ config, pkgs, lib, ... }:
let
  vimPlugsFromSource = (import ./plugins.nix) pkgs;
  colorscheme = (import ../../colorschemes/dracula.nix);
in
{
  home.packages = with pkgs; [

    # for live syncing html, js, css to a browser
    nodePackages.browser-sync

    # formatting
    nodePackages.prettier

    # C
    # gcc

    # Clojure
    # clojure

    # elixir
    # elixir
    #hex
    #rebar3

    # go
    # go

    # JavaScript
    nodejs
    yarn
    nodePackages.eslint_d
    nodePackages.typescript-language-server
    nodePackages.typescript

    # lua
    # lua
    sumneko-lua-language-server

    # markdown
    nodePackages.livedown
    pandoc

    # python
    # (python3.withPackages (ps: with ps; [ setuptools pip debugpy ]))
    # poetry
    # autoflake
    # python3Packages.pip
    # python3Packages.ipython
    # python3Packages.parso
    # python3Packages.twine

    # rust
    # rustc
    # cargo
    # rustfmt
    # cargo-tarpaulin
    # perl # perl (this is required by rust)
    # lldb # debugging setup
    # rust-analyzer
    # clippy
  ];

  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;

    plugins = with pkgs.vimPlugins; [
      # Appearance
      indent-blankline-nvim
      barbar-nvim # tabline
      nvim-tree-lua
      nvim-web-devicons
      lualine-nvim
      vim-better-whitespace
      vimPlugsFromSource.vim-venter

      # themes
      dracula-vim
      nightfox-nvim
      catppuccin-nvim

      # sessions
      auto-session

      # terminal
      toggleterm-nvim

      # tmux integration
      vim-tmux-navigator

      # Programming
      # which-key-nvim
      vim-nix # vimscript

      neoformat

      # build
      vim-dispatch

      ## lsp
      nvim-lspconfig
      lspkind-nvim
      lsp_signature-nvim
      null-ls-nvim
      nvim-lsp-ts-utils
      lspsaga-nvim

      #vimPlugsFromSource.nvim-treesitter
      nvim-treesitter
      nvim-treesitter-refactor
      nvim-treesitter-textobjects
      nvim-treesitter-context
      nvim-ts-autotag # auto close html tags with treesitter

      ## Autocompletion setup
      nvim-cmp
      cmp-path
      cmp-buffer
      cmp-nvim-lua
      cmp-nvim-lsp
      cmp-treesitter
      luasnip # for cmp
      cmp_luasnip
      nvim-autopairs

      # Snippets
      friendly-snippets

      rust-tools-nvim
      symbols-outline-nvim

      # Text objects
      tcomment_vim # vimscript

      # Git
      gitsigns-nvim
      git-blame-nvim

      # DAP
      #vimPlugsFromSource.nvim-dap-python

      # Fuzzy Finder
      telescope-nvim
      telescope-manix

      # Text Helpers
      todo-comments-nvim

      # General Deps
      popup-nvim
      plenary-nvim

      # jj/jk to escape
      better-escape-nvim

      # testing
      vim-test

      # elixir
      vim-elixir

      # db
      vim-dadbod
      vim-dadbod-ui
      vim-dadbod-completion

      # fast motion
      vimPlugsFromSource.nvim-pounce
      vimPlugsFromSource.nvim-delaytrain

      # formatting
      lsp-format-nvim
      editorconfig-nvim
    ];

    # cmake = {"${pkgs.cmake-language-server}/bin/cmake-language-server"},
    extraConfig = ''
      ${builtins.readFile ./sane_defaults.vim}
      ${builtins.readFile ./vim-test.vim}
      ${builtins.readFile ./folding.vim}
      ${builtins.readFile ./dadbod.vim}

      " colorscheme ${colorscheme.vim-name}
      " colorscheme nightfox
      " colorscheme dawnfox
      " colorscheme catppuccin-latte
      colorscheme catppuccin-mocha

      lua << EOF
        local statusline_theme = '${colorscheme.vim-statusline}'

        local lang_servers_cmd = {
          bashls = {"${pkgs.nodePackages.bash-language-server}/bin/bash-language-server", "start"},
          cssls = {"${pkgs.nodePackages.vscode-css-languageserver-bin}/bin/css-languageserver", "--stdio"},
          dockerls = {"${pkgs.nodePackages.dockerfile-language-server-nodejs}/bin/docker-langserver", "--stdio"},
          gopls = {"${pkgs.gopls}/bin/gopls"},
          html = {"${pkgs.nodePackages.vscode-html-languageserver-bin}/bin/html-languageserver", "--stdio"},
          jsonls = {"${pkgs.nodePackages.vscode-json-languageserver-bin}/bin/json-languageserver", "--stdio"},
          rnix = {"${pkgs.rnix-lsp}/bin/rnix-lsp"},
          tsserver = {"${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server", "--stdio", "--tsserver-path", "tsserver"},
          vimls = {"${pkgs.nodePackages.vim-language-server}/bin/vim-language-server", "--stdio"},
          yamlls = {"${pkgs.nodePackages.yaml-language-server}/bin/yaml-language-server", "--stdio"},
          dls = "${pkgs.nodePackages.diagnostic-languageserver}/bin/diagnostic-languageserver",
          isort = "${pkgs.python3Packages.isort}/bin/isort",
          lua_format = "${pkgs.luaformatter}/bin/lua-format",
          elixirls = {"${pkgs.elixir_ls}/bin/elixir-ls"},
          eslint_d_bin = "${pkgs.nodePackages.eslint_d}/bin/eslint_d",
          tailwindcss = {"${pkgs.nodePackages."@tailwindcss/language-server"}/bin/tailwindcss-language-server", "--stdio" },

        }

        -- this needs to be at the beginning
        ${builtins.readFile ./sane_defaults.lua}

        ${builtins.readFile ./autopair.lua}
        ${builtins.readFile ./auto-session.lua}
        ${builtins.readFile ./better_escape.lua}
        ${builtins.readFile ./delaytrain.lua}
        ${builtins.readFile ./git.lua}
        ${builtins.readFile ./gitblame.lua}
        ${builtins.readFile ./keymaps.lua}
        ${builtins.readFile ./lsp.lua}
        ${builtins.readFile ./lspsaga.lua}
        ${builtins.readFile ./nvim-tree.lua}
        ${builtins.readFile ./snippets.lua}
        ${builtins.readFile ./statusline.lua}
        ${builtins.readFile ./tabs.lua}
        ${builtins.readFile ./telescope.lua}
        ${builtins.readFile ./vim-tmux-navigator.lua}
        ${builtins.readFile ./todo.lua}
        ${builtins.readFile ./toggleterm.lua}
        ${builtins.readFile ./treesitter.lua}

        ${builtins.readFile ./indentline.lua}

      EOF

      ${builtins.readFile ./theme.vim}
    '';
    # ${builtins.readFile ./which_key.lua}
  };
}
