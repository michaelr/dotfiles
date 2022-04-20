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
    ignores = [ ".nvimrc" ".envrc" ".direnv/" ];

    extraConfig = {

      core = {
        pager = "delta";
      };

      pull.ff = "only";
      push.default = "current";

      merge.conflictStyle = "zdiff3";

      alias = {
        co = "checkout";
        l = "log --pretty=oneline -n 50 --graph --abbrev-commit";
        st = "status -sb";
        p = "pull --ff-only";
        prb = "pull --rebase";

        # an alternative to git worktree
        # https://nicolaiarocci.com/git-worktree-vs-git-savepoints/
        save = "!git add -A && git commit -v -m 'SAVEPOINT'";
        undo = "reset HEAD^ --mixed";
      };

      delta = {
        features = "side-by-side line-numbers decorations";
        minus-style = "syntax \"#3F2E32\"";
        minus-emph-style = "syntax \"#5D3437\"";
        plus-style = "syntax \"#273732\"";
        plus-emph-style = "syntax \"#335D3C\"";
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
