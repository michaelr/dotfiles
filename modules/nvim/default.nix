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

    # Haskell
    # ghc
    # haskellPackages.cabal-install
    # haskellPackages.stack

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
      dracula-vim

      # sessions
      auto-session

      # terminal
      toggleterm-nvim

      # tmux integration
      vim-tmux-navigator

      # Programming
      which-key-nvim
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

      #vimPlugsFromSource.nvim-treesitter
      nvim-treesitter
      nvim-treesitter-refactor
      nvim-treesitter-textobjects
      nvim-treesitter-context

      ## Autocompletion setup
      nvim-cmp
      cmp-path
      cmp-buffer
      cmp-nvim-lua
      cmp-nvim-lsp
      cmp-treesitter
      luasnip # for cmp
      cmp_luasnip

      # Snippets
      friendly-snippets

      rust-tools-nvim
      symbols-outline-nvim

      # Text objects
      tcomment_vim # vimscript

      # Git
      gitsigns-nvim

      # DAP
      #vimPlugsFromSource.nvim-dap-python

      # Fuzzy Finder
      telescope-nvim

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
      lightspeed-nvim

      # formatting
      lsp-format-nvim
      editorconfig-nvim
    ];

    # cmake = {"${pkgs.cmake-language-server}/bin/cmake-language-server"},
    extraConfig = ''
      ${builtins.readFile ./sane_defaults.vim}
      ${builtins.readFile ./vim-test.vim}
      ${builtins.readFile ./vim-tmux-navigator.vim}
      ${builtins.readFile ./folding.vim}
      ${builtins.readFile ./dadbod.vim}

      colorscheme ${colorscheme.vim-name}

      lua << EOF
        local statusline_theme = '${colorscheme.vim-statusline}'

        local lang_servers_cmd = {
          bashls = {"${pkgs.nodePackages.bash-language-server}/bin/bash-language-server", "start"},
          cssls = {"${pkgs.nodePackages.vscode-css-languageserver-bin}/bin/css-languageserver", "--stdio"},
          dockerls = {"${pkgs.nodePackages.dockerfile-language-server-nodejs}/bin/docker-langserver", "--stdio"},
          gopls = {"${pkgs.gopls}/bin/gopls"},
          hls = {"${pkgs.haskellPackages.haskell-language-server}/bin/haskell-language-server", "--lsp"},
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

        ${builtins.readFile ./auto-session.lua}
        ${builtins.readFile ./better_escape.lua}
        ${builtins.readFile ./git.lua}
        ${builtins.readFile ./lsp.lua}
        ${builtins.readFile ./keymaps.lua}
        ${builtins.readFile ./nvim-tree.lua}
        ${builtins.readFile ./sane_defaults.lua}
        ${builtins.readFile ./snippets.lua}
        ${builtins.readFile ./statusline.lua}
        ${builtins.readFile ./tabs.lua}
        ${builtins.readFile ./telescope.lua}
        ${builtins.readFile ./todo.lua}
        ${builtins.readFile ./toggleterm.lua}
        ${builtins.readFile ./treesitter.lua}
        ${builtins.readFile ./which_key.lua}

      EOF

      ${builtins.readFile ./theme.vim}
      ${builtins.readFile ./indentline.vim}
    '';
  };
}
