{ fish-theme-bobthefish, fish-nix-env }:

{ lib, pkgs, config, modulesPath, ... }:

with lib;
let
  defaultUser = "michaelr";
in
{

  ## hardware conf

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "mptspi"
    "uhci_hcd"
    "ehci_pci"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

  swapDevices = [ ];
  ##


  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.useDHCP = false;
  networking.interfaces.ens33.useDHCP = true;

  virtualisation.docker.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";

  # setup windowing environment
  services.xserver = {
    enable = true;
    layout = "us";

    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "scale";
    };

    displayManager = {
      defaultSession = "none+i3";
      lightdm = {
        enable = true;
        background = "#282936";
      };
      autoLogin = {
        enable = true;
        user = "michaelr";

      };

      sessionCommands = ''
        ${pkgs.xlibs.xset}/bin/xset r rate 300 50
      '';
    };

    windowManager = {
      i3.enable = true;
    };

    xkbOptions = "ctrl:nocaps";
  };

  fonts = {
    fontDir.enable = true;

    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "Hack" ]; })
    ];
  };
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = true;
  services.openssh.permitRootLogin = "no";

  networking.firewall.enable = false;

  virtualisation.vmware.guest.enable = true;


  # fileSystems."/host" = {
  #   fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
  #   device = ".host:/";
  #   options = [
  #     "umask=22"
  #     "uid=1000"
  #     "gid=1000"
  #     "allow_other"
  #     "auto_unmount"
  #     "defaults"
  #   ];
  # };

  time.timeZone = "America/Chicago";

  users.mutableUsers = false;

  users.users.${defaultUser} = {
    uid = 1000;
    isNormalUser = true;
    # NOTE: on nixos-wsl you have to use the nix-env fish plugin if $SHELL=fish
    shell = pkgs.fish;
    password = "michaelr";
    extraGroups = [ "wheel" "docker" ];
  };

  environment.systemPackages = with pkgs; [
    gnumake
    killall
    rxvt_unicode
    xclip
    # This is needed for the vmware user tools clipboard to work.
    # You can test if you don't need this by deleting this and seeing
    # if the clipboard sill works.
    gtkmm3

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
        LANG = "en_US.UTF-8";
        LC_CTYPE = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
        EDITOR = "nvim";
        PAGER = "less -FirSwX";
        MANPAGER = "less -FirSwX";
      };

      packages = with pkgs; [
        ripgrep
        fzf
        jq
        tree-sitter
        glow # markdown previewer
        mdcat # kitty md previewer with images
        termpdfpy # kitty pdf, epub terminal viewer

        exercism # coding exercises

        firefox
        rofi
        wezterm

        htop
        bottom

        tmatrix # l33t factor 5000
      ];

      file.".local/bin/git-wt-clone".source = ../users/michaelr/local-bin/git-wt-clone;

    };

    xresources.extraConfig = builtins.readFile ../users/michaelr/Xresources;


    xdg.configFile."i3/config".text = builtins.readFile ../users/michaelr/i3;
    xdg.configFile."rofi/config.rasi".text = builtins.readFile ../users/michaelr/rofi;
    xdg.configFile."glow/glow.yml".text = ''
      style: "auto"
      local: false
      mouse: true 
      pager: true
      width: 80
    '';

    programs.alacritty = {
      enable = true;
    };

    programs.kitty = {
      enable = true;
      extraConfig = builtins.readFile ../users/michaelr/kitty;
    };


    programs.i3status = {
      enable = true;

      general = {
        colors = true;
        color_good = "#50FA7B";
        color_degraded = "#F1FA8C";
        color_bad = "#FF5555";
      };

      modules = {
        ipv6.enable = false;
        "wireless _first_".enable = false;
        "battery all".enable = false;
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      stdlib = builtins.readFile ../users/michaelr/direnvrc;
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

  # Install manpages and other documentation.
  documentation.enable = true;

  users.users.root = {
    password = "root";
    extraGroups = [ "root" ];
  };

  security.sudo.wheelNeedsPassword = false;

}

