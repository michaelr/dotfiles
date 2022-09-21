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

}
