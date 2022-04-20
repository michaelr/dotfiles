{ fish-nix-env, fish-theme-bobthefish }:
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

  networking.hostName = "nixos-vmware";

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
        ${pkgs.xorg.xset}/bin/xset r rate 300 50
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
  services.openssh.passwordAuthentication = false;
  services.openssh.permitRootLogin = "no";

  services.tailscale.enable = true;

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
  #
  time.timeZone = "America/Chicago";

  users.mutableUsers = false;
  users.groups.plocate = { };
  users.users.${defaultUser} = {
    uid = 1000;
    isNormalUser = true;
    # NOTE: on nixos-wsl you have to use the nix-env fish plugin if $SHELL=fish
    shell = pkgs.fish;
    password = "michaelr";
    extraGroups = [ "wheel" "docker" ];
  };

  environment.systemPackages = with pkgs; [
    tailscale
    gnumake
    lsof
    killall
    rxvt_unicode
    xclip
    # This is needed for the vmware user tools clipboard to work.
    # You can test if you don't need this by deleting this and seeing
    # if the clipboard sill works.
    gtkmm3

  ];

  # nix = {
  #   package = pkgs.nixFlakes;
  #   extraOptions = ''
  #     experimental-features = nix-command flakes
  #     keep-outputs = true
  #     keep-derivations = true
  #   '';
  # };

  nixpkgs.config.allowUnfree = true;

  home-manager.users.${defaultUser} = {
    # TODO: get rid of this hack
    _module.args = {
      colorscheme = (import ../../colorschemes/dracula.nix);
    };

    imports = [
      ../../modules/nvim
      ../../modules/git.nix
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
        fd
        tree-sitter
        glow # markdown previewer
        mdcat # kitty md previewer with images
        termpdfpy # kitty pdf, epub terminal viewer
        docker-compose_2
        docker-compose
        google-cloud-sdk
        cloud-sql-proxy
        mosh
        autossh
        nodePackages.sql-formatter
        fx # json viewer
        kubectl
        envsubst
        wget
        socat
        pup # command line html parser
        gitlab-runner
        kubernetes-helm

        flyctl # fly.io
        hcloud # hetzner cli

        exercism # coding exercises

        google-chrome
        rofi
        wezterm

        mariadb

        obsidian
        _1password-gui
        _1password
        gopass
        age

        libnotify
        dunst

        htop
        bottom

        tmatrix # l33t factor 5000

        duf
        du-dust
        pgcli
        sd
        mtr
        plocate
        magic-wormhole
        xh
        lazydocker
        lazygit
        ctop
        angle-grinder
        lnav

        open-vm-tools
      ];

      file.".local/bin/git-wt-clone".source = ../../users/michaelr/local-bin/git-wt-clone;
      file.".local/bin/project-session.sh".source = ../../users/michaelr/local-bin/project-session.sh;


    };

    xresources.extraConfig = builtins.readFile ../../users/michaelr/Xresources;


    xdg.configFile."i3/config".text = builtins.readFile ../../users/michaelr/i3;
    xdg.configFile."rofi/config.rasi".text = builtins.readFile ../../users/michaelr/rofi;
    xdg.configFile."glow/glow.yml".text = ''
      style: "auto"
      local: false
      mouse: true 
      pager: true
      width: 80
    '';

    programs.firefox = {
      enable = true;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        multi-account-containers
        old-reddit-redirect
        onepassword-password-manager
        vim-vixen
        facebook-container
      ];

      # Settings for the default Firefox profile.
      profiles.default.settings = {
        # Disable the warning on accessing about:config.
        "browser.aboutConfig.showWarning" = false;

        # Don't autohide the address bar and tab bar in fullscreen.
        "browser.fullscreen.autohide" = false;

        # Use dark mode in interfaces and websites.
        "browser.in-content.dark-mode" = true;

        # Remove the highlights from the new tab page.
        "browser.newtabpage.activity-stream.feeds.section.highlights" = false;

        # Remove the top stories from the new tab page.
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;

        # Remove the top sites from the new tab page.
        "browser.newtabpage.activity-stream.feeds.section.topsites" = false;

        # Don't warn if Firefox doesn't seem to be the default browser.
        "browser.shell.checkDefaultBrowser" = false;

        # Allow switching tabs by scrolling.
        "toolkit.tabbox.switchByScrolling" = true;

        # Don't show the menu when pressing ALT.
        "ui.key.menuAccessKeyFocuses" = false;

        # Set the system UI to dark themed.
        "ui.systemUsesDarkTheme" = 1;

        # Don't reveal your internal IP when WebRTC is enabled
        "media.peerconnection.ice.no_host" = false;

        # Disable face detection
        "camera.control.face_detection.enabled" = false;

        # Disable GeoIP lookup on your address to set default search engine region
        "browser.search.countryCode" = "US";
        "browser.search.region" = "US";
        "browser.search.geoip.url" = "";

        # Do not submit invalid URIs entered in the address bar to the default search engine
        "keyword.enabled" = true;

        # Don't trim HTTP off of URLs in the address bar
        "browser.urlbar.trimURLs" = false;

        # Disable Extension recommendations
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr" = false;

        # Enable contextual identity Containers feature
        "privacy.userContext.enabled" = true;

        # Enable blocking reported web forgeries
        "browser.safebrowsing.phishing.enabled" = true;

        # Enable blocking reported attack sites
        "browser.safebrowsing.malware.enabled" = true;

        # Disable querying Google Application Reputation database for downloaded binary files
        "browser.safebrowsing.downloads.remote.enabled" = false;

        # Disable pocket
        "browser.pocket.enabled" = false;
        "extensions.pocket.enabled" = false;

        # Disable search suggestions
        "browser.search.suggest.enabled" = false;

        # Disable "Show search suggestions in location bar results"
        "browser.urlbar.suggest.searches" = false;

        # Never check updates for search engines
        "browser.search.update" = false;

        # Enable insecure password warnings (login forms in non-HTTPS pages)
        "security.insecure_password.ui.enabled" = true;

        # Disable the "new tab page" feature and show a blank tab instead
        "browser.newtabpage.enabled" = false;
        "browser.newtab.url" = "about:blank";

        "browser.startup.homepage" = "about:blank";

        # Disable password manager
        "signon.rememberSignons" = false;

        "browser.newtabpage.activity-stream.default.sites" = "";
      };
    };

    programs.alacritty = {
      enable = true;
    };

    programs.kitty = {
      enable = true;
      extraConfig = builtins.readFile ../../users/michaelr/kitty;
    };

    programs.i3status-rust = {
      enable = true;

      bars = {
        bottom = {
          blocks = [
            {
              block = "focused_window";
              show_marks = "visible";
            }
            {
              block = "docker";
              format = "{running}/{total}";
            }
            {
              block = "disk_space";
              path = "/";
              alias = "/";
              info_type = "available";
              unit = "GB";
              alert_absolute = true;
              interval = 60;
              warning = 15.0;
              alert = 8.0;
            }
            {
              block = "memory";
              display_type = "memory";
              format_mem = "{mem_used_percents}";
              format_swap = "{swap_used_percents}";
            }
            {
              block = "cpu";
              interval = 1;
            }
            {
              block = "uptime";
            }
            {
              block = "notify";
            }
            {
              block = "time";
              interval = 60;
              format = "%a %m/%d %l:%M %p";
            }
          ];
          settings = {
            theme = {
              name = "dracula";
            };
          };
          icons = "material-nf";
          theme = "dracula";
        };
      };
    };


    programs.i3status = {
      enable = false;

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
      stdlib = builtins.readFile ../../users/michaelr/direnvrc;
    };

    programs.tmux = {
      enable = true;
      clock24 = true;
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = dracula;
          extraConfig = ''
            set -g @dracula-plugins "battery"
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
        bind-key "z" resize-pane -Z
        bind-key "!" break-pane
        bind-key ":" command-prompt
        bind-key "?" list-keys
        bind-key "E" select-layout -E
        bind-key "[" copy-mode
        bind-key "s" choose-session
        bind-key "r" source-file ~/.config/tmux/tmux.conf
        # change pane split orientation
        bind -n S-Up move-pane -h -t '.{up-of}'
        bind -n S-Right move-pane -t '.{right-of}'
        bind -n S-Left move-pane -t '.{left-of}'
        bind -n S-down move-pane -h -t '.{down-of}'

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


        p = "fd -H -td '^\.git$' -tf --search-path ~/code -x echo {//} | fzf | xargs project-session.sh";

        fly = "flyctl";
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
        gwc = "git-wt-clone";
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
