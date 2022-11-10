{ pkgs, ... }:
{

  #  nvim-dap-python = pkgs.vimUtils.buildVimPluginFrom2Nix {
  #    pname = "nvim-dap-python";
  #    version = "master";
  #    src = pkgs.fetchFromGitHub {
  #      owner = "mfussenegger";
  #      repo = "nvim-dap-python";
  #      rev = "master";
  #      sha256 = "sha256-ZPJuv+XsizTZmYC4CZkzV8NGwt+Mlq+KmddQsLApEYQ=";
  #    };
  #  };

  nvim-treesitter = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvim-treesitter";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "master";
      #sha256 = pkgs.lib.fakeSha256;
      sha256 = "sha256-+nr+djSGtTi7Glneba8nT+Rn8lCJwBp3Cg/TjrTZxbo=";
    };
  };

  vim-venter = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "vim-venter";
    version = "2022-11-10";
    src = pkgs.fetchFromGitHub {
      owner = "JMcKiern";
      repo = "vim-venter";
      rev = "8cbb93f912a85e320a3eaeee0b9ee5934043930a";
      #sha256 = pkgs.lib.fakeSha256;
      sha256 = "sha256-mwOaGrgyvTCC3TnoATq65YqcQRipVOkYAlbobT1oVIo=";
    };
  };

  nvim-pounce = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvim-pounce";
    version = "2022-11-10";
    src = pkgs.fetchFromGitHub {
      owner = "rlane";
      repo = "pounce.nvim";
      rev = "a573820b20882c70d241a1ac94aa27670442c027";
      #sha256 = pkgs.lib.fakeSha256;
      sha256 = "sha256-tg2zplVKfbNLKCYTmhvJfc0GEh6u1e2T3kgG/ju3PGA==";
    };
  };
}
