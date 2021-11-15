{
  description = "Home manager flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";

    # make home-manager use same nixpkgs we're using
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    fish-nix-env = {
      url = github:lilyball/nix-env.fish;
      flake = false;
    };
  };

  outputs = { self, ... }@inputs:
    let
      overlays = [
        inputs.neovim-nightly-overlay.overlay
      ];
    in

    {
      homeConfigurations = {
        wsl = inputs.home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          homeDirectory = "/home/michaelr";
          username = "michaelr";

          configuration = { config, lib, pkgs, ... }: {

            #NOTE:Here we are injecting colorscheme so that it is passed down all the imports
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

            home.packages = with pkgs; [
              openssh
              ripgrep
              less # busybox version is limited
              fzf
              htop
              jq
              fd
              bat
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

                # this is only needed for non NixOS installs
                {
                  name = "nix-env";
                  src = inputs.fish-nix-env;
                }
              ];

              shellAliases = {

                gc = "git commit";
                gs = "git status";
                ga = "git add";
                gd = "git diff";

                ls = "exa";
                ll = "exa -l";
                la = "exa -a";
                lt = "exa --tree";
                lla = "exa -la";

                config = "nvim $HOME/.dotfiles";
              };

              interactiveShellInit = ''
                # disable fish greeting
                set --universal --erase fish_greeting
                function fish_greeting; end
                funcsave fish_greeting
              '';

              shellInit = ''
                # this is only needed for non NixOS installs
                fenv export NIX_PATH=\$HOME/.nix-defexpr/channels\''${NIX_PATH:+:}\$NIX_PATH
              '';
            };
          };
        };
      };
    };
}
