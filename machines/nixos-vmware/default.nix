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

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  nixpkgs.config.pulseaudio = true;

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

    videoDrivers = [ "vmware" ];

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

  time.timeZone = "America/Chicago";

  users.mutableUsers = false;
  users.groups.plocate = { };
  users.users.${defaultUser} = {
    uid = 1000;
    isNormalUser = true;
    # NOTE: on nixos-wsl you have to use the nix-env fish plugin if $SHELL=fish
    shell = pkgs.fish;
    password = "michaelr";
    extraGroups = [ "wheel" "docker" "audio" "sound" "video" "jackaudio" ];
  };

  environment.systemPackages = with pkgs; [
    tailscale
    gnumake
    lsof
    killall
    rxvt-unicode-unwrapped
    xclip
    # This is needed for the vmware user tools clipboard to work.
    # You can test if you don't need this by deleting this and seeing
    # if the clipboard sill works.
    gtkmm3

  ];

  nixpkgs.config.allowUnfree = true;

  home-manager.users.${defaultUser} = {
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
        mpv
        pavucontrol

        ripgrep
        fzf
        jq
        fd
        tree-sitter
        glow # markdown previewer
        mdcat # kitty md previewer with images
        termpdfpy # kitty pdf, epub terminal viewer
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
        unzip

        flyctl # fly.io
        hcloud # hetzner cli
        glab # gitlab cli

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
        yt-dlp # multimedia archiver
        ffmpeg
        vlc
        volumeicon

        duf
        du-dust
        pgcli
        sd
        mtr
        plocate
        # magic-wormhole
        xh
        lazydocker
        lazygit
        ctop
        angle-grinder
        lnav

        open-vm-tools

        i3wsr # i3 workspace renamer

        ncspot
        spotdl
        downonspot

        discord
        weechat
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

      extraConfig = builtins.readFile ../../users/michaelr/tmux.conf;

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
          src = pkgs.fish-theme-bobthefish;
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

        # nix
        config = "nvim $HOME/.dotfiles";
        rebuild = "nixos-rebuild switch --use-remote-sudo --flake \"$HOME/.dotfiles\" -v";
        garbage = "sudo nix-collect-garbage -d";

        # select project directory to open/start tmux session
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

