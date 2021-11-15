{ config, pkgs, libs, ... }:
{
  home.packages = with pkgs; [
    git-crypt
    gitAndTools.delta
  ];
  programs.git = {
    enable = true;
    userName = "Michael Reddick";
    userEmail = "michael.reddick@gmail.com";
    extraConfig = {
      core = {
        pager = "delta";
      };
      pull.ff = "only";
      delta = {
        features = "side-by-side line-numbers decorations";
      };
      "delta \"decorations\"" = {
        commit-decoration-style = "bold yellow box ul";
        file-style = "bold yellow";
        file-decoration-style = "none";
      };
    };
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

}
