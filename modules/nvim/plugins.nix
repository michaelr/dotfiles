{ pkgs, ... }:
{
  nvim-plugin-typescript = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvim-typescript";
    version = "0.1";
    src = nvim-plugin-typescript;
  };


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

}
