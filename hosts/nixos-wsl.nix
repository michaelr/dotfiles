{ wsl-open, fish-theme-bobthefish, fish-nix-env }:

{ lib, pkgs, config, modulesPath, ... }:

with lib;
let
  defaultUser = "michaelr";
  syschdemd = import ./nixos-wsl/syschdemd.nix { inherit lib pkgs config defaultUser; };
in
{
  imports = [
    ./nixos-wsl/build-tarball.nix
  ];

  time.timeZone = "America/Chicago";

  users.mutableUsers = false;

  users.users.${defaultUser} = {
    uid = 1000;
    isNormalUser = true;
    # NOTE: on nixos-wsl you have to use the nix-env fish plugin if $SHELL=fish
    shell = pkgs.fish;
    password = "michaelr";
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
  ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };

  home-manager.users.${defaultUser} = {
    # TODO: get rid of this hack
    _module.args = {
      colorscheme = (import ../colorschemes/dracula.nix);
    };

    imports = [
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

      packages = with pkgs; [
        ripgrep
        fzf
        jq
        tree-sitter
        glow # markdown previewer

        exercism # coding exercises

        htop
        bottom

        tmatrix # l33t factor 5000
      ];

      file.".local/bin/wsl-open.sh".source = "${wsl-open}/wsl-open.sh";

    };


    xdg.configFile."glow/glow.yml".text = ''
      style: "auto"
      local: false
      mouse: true 
      pager: true
      width: 80
    '';

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.tmux = {
      enable = true;
      clock24 = true;
      plugins = with pkgs.tmuxPlugins; [
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
                set -ga terminal-overrides ",xterm-256color*:Tc"
                set -g default-terminal "screen-256color"

                set -g mouse on
                set -g base-index 1
                set -g renumber-windows on
                set -g mode-keys "vi"

                # unbind all keys
                unbind-key -a

                set-option -g prefix C-Space
                bind-key C-Space send-prefix

                bind-key "c" new-window -c "#{pane_current_path}"
                bind-key "$" command-prompt -I "#S" "rename-session -- '%%'"
                bind-key "!" break-pane
                bind-key ":" command-prompt
                bind-key "?" list-keys
                bind-key "E" select-layout -E
                bind-key "[" copy-mode
                bind-key "s" choose-session
                bind-key "r" source-file ~/.config/tmux/tmux.conf

                # splits (shift splits current pane, no shift is full width split)
        	    bind-key "|" split-window -h -c "#{pane_current_path}"
        	    bind-key "\\" split-window -fh -c "#{pane_current_path}"
        	    bind-key "-" split-window -v -c "#{pane_current_path}"
        	    bind-key "_" split-window -fv -c "#{pane_current_path}"

                # Alt-key mappings
                bind-key -n 'M-n' next-window

                # Smart pane switching with awareness of Vim splits.
                # See: https://github.com/christoomey/vim-tmux-navigator
                is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
                    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
                bind-key -n 'M-h' if-shell "$is_vim" 'send-keys M-h'  'select-pane -L'
                bind-key -n 'M-j' if-shell "$is_vim" 'send-keys M-j'  'select-pane -D'
                bind-key -n 'M-k' if-shell "$is_vim" 'send-keys M-k'  'select-pane -U'
                bind-key -n 'M-l' if-shell "$is_vim" 'send-keys M-l'  'select-pane -R'

                bind-key -T copy-mode-vi 'M-h' select-pane -L
                bind-key -T copy-mode-vi 'M-j' select-pane -D
                bind-key -T copy-mode-vi 'M-k' select-pane -U
                bind-key -T copy-mode-vi 'M-l' select-pane -R

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

        # direnv hook
        direnv hook fish | source

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
