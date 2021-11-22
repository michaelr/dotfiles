{ wsl-open, fish-theme-bobthefish, fish-nix-env }:

{ lib, pkgs, config, modulesPath, ... }:

with lib;
let
  defaultUser = "michaelr";
  syschdemd = import ./nixos-wsl/syschdemd.nix { inherit lib pkgs config defaultUser; };
in
{
  imports = [
    #../modules/unfree.nix
    #    ../profiles/common/fonts.nix
    #../profiles/common/nix-settings.nix
    #../users/will/less.nix
    ./nixos-wsl/build-tarball.nix
  ];

  time.timeZone = "America/Chicago";

  users.mutableUsers = false;

  users.users.${defaultUser} = {
    uid = 1000;
    isNormalUser = true;
    # on nixos-wsl you have to use the nix-env fish plugin if shell is set to fish
    shell = pkgs.fish;
    password = "michaelr";
    extraGroups = [ "wheel" ];
  };

  home-manager.users.${defaultUser} = {
    _module.args = {
      colorscheme = (import ../colorschemes/dracula.nix);
    };

    imports = [
      # ../users/profiles/bat.nix
      # ../users/profiles/pkgs/cli.nix
      # ../users/profiles/programs.nix
      # ../users/will/pkgs/cli.nix
      #     ../users/will/xdg.nix

      ../modules/nvim
      ../modules/git.nix
    ];
    xdg.enable = true;

    home = rec {
      stateVersion = "21.11";
      username = defaultUser;
      homeDirectory = "/home/${defaultUser}";

      sessionVariables = {
        EDITOR = "nvim";
      };

      file.".local/bin/wsl-open.sh".source = "${wsl-open}/wsl-open.sh";

      packages = with pkgs; [
        ripgrep
        fzf
        htop
        jq

      ];

    };

    programs.tmux = {
      enable = true;
      clock24 = true;
      plugins = with pkgs.tmuxPlugins; [
        #        sensible
        #        yank
        {
          plugin = dracula;
          extraConfig = ''
            set -g @dracula-plugins "cpu-usage time"
            set -g @dracula-show-powerline true
            set -g @dracula-refresh-rate 10
            set -g @dracula-show-left-icon session
            set -g @dracula-show-timezone false
          '';
        }
      ];

      extraConfig = ''
        #set -ga terminal-overrides ",xterm-256color*:Tc"
        set -g default-terminal "screen-256color"

        set -g mouse on
        set -g base-index 1
        set -g renumber-windows on

        unbind C-b
        set-option -g prefix C-a
        bind-key C-a send-prefix

        bind r source-file ~/.config/tmux/tmux.conf
      '';

    };

    programs.exa = {
      enable = true;
      enableAliases = false;
    };

    programs.fish = {
      enable = true;
      plugins = [
        {
          name = "foreign-env";
          src = pkgs.fishPlugins.foreign-env.src;
        }

        {
          name = "fzf";
          src = pkgs.fishPlugins.fzf-fish.src;
        }

        {
          name = "theme-bobthefish";
          src = fish-theme-bobthefish;
        }

        # this is only needed for non-NixOS or for NixOS-WSL installs
        {
          name = "nix-env";
          src = fish-nix-env;
        }
      ];

      shellAliases = {

        ls = "exa";
        ll = "exa -lg";
        la = "exa -a";
        lt = "exa --tree";
        lla = "exa -lag";

        # reload history - to use commands from a different fish shell
        hr = "history --merge";

        # to make open command work on WSL
        open = "wsl-open.sh";

        config = "nvim $HOME/.dotfiles";
      };

      shellAbbrs = {
        gc = "git commit";
        gcm = "git commit -m";
        gs = "git st";
        ga = "git add";
        gd = "git diff";
        gds = "git diff --staged";
        gl = "git l";
        gp = "git push";
        gpl = "git pull";
        gf = "git fetch";
      };

      interactiveShellInit = ''
        set -g SHELL ${pkgs.fish}/bin/fish
        # disable fish greeting
        set -g fish_greeting ""

        # theme-bobthefish settings
        set -g theme_color_scheme dracula
        set -g theme_nerd_fonts yes
        set -g theme_date_format "+%l:%M%p %a %b %d"
        set -g theme_display_cmd_duration no

        # this was causing slowdowns on wsl
        set -g theme_display_ruby no

      '';

      shellInit = ''
        fish_add_path ~/.local/bin

        # these shouldn't be needed but just for reference this will set the path right
        # fish_add_path -m /etc/profiles/per-user/michaelr/bin/
        # fish_add_path -m /run/current-system/sw/bin/
        # fish_add_path -m /run/wrappers/bin/

        # this is only needed for non NixOS installs
        # fenv export NIX_PATH=\$HOME/.nix-defexpr/channels\''${NIX_PATH:+:}\$NIX_PATH
      '';
    };

  };

  # WSL is closer to a container than anything else
  boot.isContainer = true;


  environment.extraInit = ''PATH="$PATH:$WSLPATH"'';

  # Install manpages and other documentation.
  documentation.enable = true;

  environment.etc.hosts.enable = false;
  environment.etc."resolv.conf".enable = false;

  networking.dhcpcd.enable = false;

  users.users.root = {
    shell = "${syschdemd}/bin/syschdemd";
    password = "root";
    # Otherwise WSL fails to login as root with "initgroups failed 5"
    extraGroups = [ "root" ];
  };

  security.sudo.wheelNeedsPassword = false;

  systemd = {
    # Don't allow emergency mode, because we don't have a console.
    enableEmergencyMode = false;

    # Disable systemd units that don't make sense on WSL
    services = {
      "serial-getty@ttyS0".enable = false;
      "serial-getty@hvc0".enable = false;
      "getty@tty1".enable = false;
      "autovt@".enable = false;

      firewall.enable = false;
      systemd-resolved.enable = false;
      systemd-udevd.enable = false;
    };
  };
}
