{ config, pkgs, lib, colorscheme, ... }:
let
  vimPlugsFromSource = (import ./plugins.nix) pkgs;
in
{
  home.packages = with pkgs; [
    # C
    gcc
    # Clojure
    clojure
    # elixir
    elixir
    #hex
    #rebar3
    # go
    go
    # Haskell
    ghc
    haskellPackages.cabal-install
    haskellPackages.stack
    # JavaScript
    nodejs
    yarn
    # lua
    lua
    # markdown
    nodePackages.livedown
    pandoc
    # python
    (python3.withPackages (ps: with ps; [ setuptools pip debugpy ]))
    poetry
    autoflake
    python3Packages.pip
    python3Packages.ipython
    python3Packages.parso
    python3Packages.twine
    # rust
    rustc
    cargo
    rustfmt
    cargo-tarpaulin
    perl # perl (this is required by rust)
    lldb # debugging setup
    rust-analyzer
    clippy
  ] ++ (lib.optional pkgs.stdenv.isLinux sumneko-lua-language-server);

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

      # Programming
      which-key-nvim
      vim-nix # vimscript

      ## lsp
      nvim-lspconfig
      cmp-nvim-lsp
      lspkind-nvim
      lsp_signature-nvim

      nvim-treesitter
      nvim-treesitter-refactor
      nvim-treesitter-textobjects

      ## Autocompletion setup
      nvim-cmp
      cmp-path
      cmp-buffer
      cmp-cmdline
      cmp-nvim-lua
      cmp-treesitter
      luasnip # for cmp
      cmp_luasnip

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


    ];

    # cmake = {"${pkgs.cmake-language-server}/bin/cmake-language-server"},
    extraConfig = ''
      ${builtins.readFile ./sane_defaults.vim}
      ${builtins.readFile ./vim-test.vim}

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
          tsserver = {"${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server", "--stdio"},
          vimls = {"${pkgs.nodePackages.vim-language-server}/bin/vim-language-server", "--stdio"},
          yamlls = {"${pkgs.nodePackages.yaml-language-server}/bin/yaml-language-server", "--stdio"},
          prettier = "${pkgs.nodePackages.prettier}/bin/prettier",
          isort = "${pkgs.python3Packages.isort}/bin/isort",
          lua_format = "${pkgs.luaformatter}/bin/lua-format", 
          elixirls = {"${pkgs.elixir_ls}/bin/elixir-ls"}

        }

        ${builtins.readFile ./nvim-tree.lua}
        ${builtins.readFile ./sane_defaults.lua}
        ${builtins.readFile ./treesitter.lua}
        ${builtins.readFile ./telescope.lua}
        ${builtins.readFile ./tabs.lua}
        ${builtins.readFile ./lsp.lua}
        ${builtins.readFile ./statusline.lua}
        ${builtins.readFile ./git.lua}
        ${builtins.readFile ./todo.lua}
        ${builtins.readFile ./which_key.lua}
        ${builtins.readFile ./better_escape.lua}

      EOF

      ${builtins.readFile ./theme.vim}
      ${builtins.readFile ./indentline.vim}
    '';
  };
}
