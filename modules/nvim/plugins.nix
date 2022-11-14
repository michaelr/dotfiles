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

  nvim-delaytrain = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvim-delaytrain";
    version = "2022-11-10";
    src = pkgs.fetchFromGitHub {
      owner = "ja-ford";
      repo = "delaytrain.nvim";
      rev = "f22db9e58d9f839aff0208766a0734c4794e5a68";
      #sha256 = pkgs.lib.fakeSha256;
      sha256 = "sha256-mQQf39UoZV/A/pAIdyCSiI7WZ7Kc3V4ZvOJhMgxlHUQ=";
    };
  };

  nvim-grapple = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvim-grapple";
    version = "2022-11-11";
    src = pkgs.fetchFromGitHub {
      owner = "cbochs";
      repo = "grapple.nvim";
      rev = "218a58bff8a91b1959cbab670b96a78dca64738a";
      #sha256 = pkgs.lib.fakeSha256;
      sha256 = "sha256-ZvPGcwXWth3/+Rq9ewcreq/ODz3Rk7wH17ZRZkUPTs4=";
    };
  };
}
