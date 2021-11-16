{ config, pkgs, libs, colorscheme, ... }:
{
  home.packages = with pkgs; [
    git-crypt
    gitAndTools.delta
  ];

  programs.bat = {
    enable = true;
    config.theme = colorscheme.bat-theme-name;
  };

  programs.git = {
    enable = true;
    userName = "Michael Reddick";
    userEmail = "michael.reddick@gmail.com";
    extraConfig = {
      core = {
        pager = "delta";
      };
      pull.ff = "only";
      alias = {
        co = "checkout";
      };
      delta = {
        features = "side-by-side line-numbers decorations";
        minus-style = "syntax \"#901011\"";
        minus-emph-style = "syntax \"#3f0001\"";
        plus-style = "syntax \"#006000\"";
        plus-emph-style = "syntax \"#002800\"";
      };
      "delta \"decorations\"" = {
        commit-decoration-style = "box ul";
        file-style = "bold";
        true-color = "always";
      };
    };
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

}
