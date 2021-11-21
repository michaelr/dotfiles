{
  description = "Home manager flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";

    # make home-manager use same nixpkgs we're using
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    fish-nix-env = {
      url = github:lilyball/nix-env.fish;
      flake = false;
    };

    fish-theme-bobthefish = {
      url = github:oh-my-fish/theme-bobthefish;
      flake = false;
    };

    wsl-open = {
      url = github:4U6U57/wsl-open;
      flake = false;
    };

  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      overlays = [
        inputs.neovim-nightly-overlay.overlay
      ];
    in

    {
      nixosConfigurations = {
        nixos-wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            (import ./hosts/nixos-wsl.nix
              {
                wsl-open = inputs.wsl-open;
                fish-theme-bobthefish = inputs.fish-theme-bobthefish;
                fish-nix-env = inputs.fish-nix-env;
              })

            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
              };
              networking.hostName = "nixos-wsl";
            }
            { nixpkgs.overlays = overlays; }
          ];
        };

      };

      homeConfigurations = {
        wsl = inputs.home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          homeDirectory = "/home/michaelr";
          username = "michaelr";

          configuration = { config, lib, pkgs, ... }: {

            _module.args = {
              colorscheme = (import ./colorschemes/dracula.nix);
            };

            xdg.configFile."nix/nix.conf".text = ''
              experimental-features = nix-command flakes ca-references
            '';

            nixpkgs.config = { allowUnfree = true; };
            nixpkgs.overlays = overlays;

            # Let Home Manager install and manage itself.
            programs.home-manager.enable = true;

            home.file.".local/bin/wsl-open.sh".source = "${inputs.wsl-open}/wsl-open.sh";

            home.packages = with pkgs; [
              openssh
              ripgrep
              fzf
              htop
              jq
              fd

              # busybox versions of core utilities are limited
              coreutils
              less
            ];

            imports = [
              ./modules/nvim
              ./modules/git.nix
            ];

            programs.tmux = {
              enable = true;
              terminal = "xterm-256color";
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
                  src = inputs.fish-theme-bobthefish;
                }

                # this is only needed for non NixOS installs
                {
                  name = "nix-env";
                  src = inputs.fish-nix-env;
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

                # this is only needed for non NixOS installs
                fenv export NIX_PATH=\$HOME/.nix-defexpr/channels\''${NIX_PATH:+:}\$NIX_PATH
              '';
            };
          };
        };
      };
    };
}
