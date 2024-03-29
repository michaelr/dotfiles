{ lib, pkgs, config, modulesPath, inputs, ... }:

with lib;
let
  defaultUser = "michaelr";
  userConf = ../../users + "/${defaultUser}";
  imgsPath = ../../imgs;
  localBinSrc = userConf + "/local-bin";
  localBin = ".local/bin";
  readUserConfFile = f: builtins.readFile (userConf + "/${f}");
  bin = import (userConf + "/bin.nix") {
    inherit (pkgs) writeShellScriptBin;
  };
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
        # background = "#282936";
      };
      autoLogin = {
        enable = true;
        user = "michaelr";

      };

      sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset r rate 235 60
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
      jetbrains-mono
    ];
  };
  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "no";
  };

  services.tailscale.enable = false;

  networking.firewall.enable = false;

  virtualisation.vmware.guest.enable = true;

  # timedatectl list-timezones
  # time.timeZone = "America/Bogota";
  # time.timeZone = "America/Denver";
  # time.timeZone = "America/Chicago";
  services.automatic-timezoned.enable = true;

  users.mutableUsers = false;
  users.groups.plocate = { };
  users.users.${defaultUser} = {
    uid = 1000;
    isNormalUser = true;
    # NOTE: on nixos-wsl you have to use the nix-env fish plugin if $SHELL=fish
    shell = pkgs.fish;
    password = defaultUser;
    extraGroups = [ "wheel" "docker" "audio" "sound" "video" "jackaudio" ];
  };

  environment.systemPackages = with pkgs; [
    tailscale
    gnumake
    gcc
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

      pointerCursor = {
        package = pkgs.vanilla-dmz;
        name = "Vanilla-DMZ";
        size = 128;
        x11.enable = true;
      };

      packages = with pkgs; [

        # command line utils
        ripgrep
        fzf
        jq
        fd
        tree-sitter
        glow # markdown previewer
        mdcat # kitty md previewer with images
        termpdfpy # kitty pdf, epub terminal viewer
        docker-compose
        mosh
        autossh
        nodePackages.sql-formatter
        fx # json viewer
        envsubst
        wget
        socat
        pup # command line html parser
        unzip
        w3m
        gopass
        age
        htop
        bottom
        tmatrix # l33t factor 5000
        yt-dlp # multimedia archiver
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
        ncspot
        spotdl
        downonspot
        mu # for parse-to-me-from-me-mail script
        procmail #ditto
        manix # nix doc searcher
        libgen-cli


        # cloud
        google-cloud-sdk
        cloud-sql-proxy
        flyctl # fly.io
        hcloud # hetzner cli
        glab # gitlab cli

        # coding
        exercism # coding exercises

        # desktop
        mpv
        pavucontrol
        rofi # app runner
        obsidian
        _1password-gui
        _1password
        libnotify
        dunst
        ffmpeg
        vlc
        volumeicon
        i3wsr # i3 workspace renamer
        discord
        inkscape-with-extensions
        slack

      ] ++ bin ++ [ inputs.devenv.packages.x86_64-linux.devenv ];

      file = {
        ".background-image".source = imgsPath + "/nixos-background-dracula.png";
        "${localBin}/git-wt-clone".source = localBinSrc + "/git-wt-clone";
        "${localBin}/parse-to-me-from-me-mail".source = localBinSrc + "/parse-to-me-from-me-mail";
        # for viewing html emails
        ".mailcap".text = "text/html;  w3m -dump -o document_charset=%{charset} -o display_link_number=1 '%s'; nametemplate=%s.html; copiousoutput";
      };

      # i could do something like this: file = map { ".local/bin/${name}.source = ${path} + "/${name}"


    };

    xresources.extraConfig = readUserConfFile "Xresources";


    xdg.configFile."i3/config".text = readUserConfFile "i3";
    xdg.configFile."rofi/config.rasi".text = readUserConfFile "rofi";
    xdg.configFile."glow/glow.yml".text = readUserConfFile "glow.yml";

    programs.firefox = {
      enable = true;
      profiles.default.extensions = with pkgs.nur.repos.rycee.firefox-addons; [
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

    programs.kitty = {
      enable = true;
      #theme = "Catppuccin-Latte";
      theme = "Catppuccin-Mocha";
      extraConfig = readUserConfFile "kitty";
    };

    programs.i3status-rust = {
      enable = true;

      bars = {
        bottom = {
          blocks = [
            {
              block = "focused_window";
            }
            {
              block = "pomodoro";
              notify_cmd = "notify-send '{msg}'";
            }
            {
              block = "docker";
              format = " $icon $running/$total ";
            }
            {
              block = "disk_space";
              path = "/";
              info_type = "available";
              alert_unit = "GB";
              interval = 60;
              warning = 15.0;
              alert = 8.0;
            }
            {
              block = "memory";
              format = " $icon $mem_avail.eng(prefix:M)($mem_used_percents.eng(w:2))";
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
              format = " $icon $timestamp.datetime(f:'%a %m/%d %l:%M %p')";
            }
          ];
          icons = "material-nf";
          theme = "dracula";
        };
      };
    };


    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      stdlib = readUserConfFile "direnvrc";
    };

    programs.tmux = {
      enable = true;
      clock24 = true;
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = dracula;
          extraConfig = readUserConfFile "tmux-dracula.conf";
        }
      ];

      extraConfig = readUserConfFile "tmux.conf";

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
        dots = "project-session ~/.dotfiles";
        rebuild = "nixos-rebuild switch --use-remote-sudo --flake \"$HOME/.dotfiles\" -v";
        garbage = "sudo nix-collect-garbage -d";
        optimise = "sudo nix store optimise";

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
        gu = "git reset --soft HEAD~";
      };

      interactiveShellInit = readUserConfFile "interactive-shell-init.fish";
      shellInit = readUserConfFile "shell-init.fish";
    };

    # mail
    programs.notmuch = {
      enable = true;
      new.tags = [ "new" ];
      search.excludeTags = [ "trash" "spam" ];
    };
    programs.neomutt = {
      enable = true;
      vimKeys = true;
    };
    programs.alot = {
      enable = true;
      settings = {
        colourmode = 256;
      };
      bindings = {
        global = {
          T = "search from:michael.reddick@gmail.com to:michael.reddick@gmail.com is:unread";
        };
        thread = {
          O = "pipeto --format=filepath send-mail-to-obsidian";
        };
      };

      hooks = ''
        def pre_buffer_focus(ui, dbm, buf):
        if buf.modename == 'search':
        buf.rebuild()
      '';
    };
    programs.lieer.enable = true;
    services.lieer.enable = true;

    accounts.email.accounts.gmail-michael = {
      primary = true;
      flavor = "gmail.com";
      realName = "Michael Reddick";
      userName = "michael.reddick@gmail.com";
      address = "michael.reddick@gmail.com";
      notmuch.enable = true;
      neomutt.enable = true;
      lieer.enable = true;
      lieer.sync.enable = true;
      passwordCommand = "";
      folders.inbox = "mail";
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




