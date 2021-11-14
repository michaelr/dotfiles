{
  description = "Home manager flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";

    # make home-manager use same nixpkgs we're using
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
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

          xdg.configFile."nix/nix.conf".text = ''
            experimental-features = nix-command flakes ca-references
          '';

          nixpkgs.config = { allowUnfree = true; };
	  nixpkgs.overlays = overlays;

          # Let Home Manager install and manage itself.
          programs.home-manager.enable = true;

          home.packages = with pkgs; [
            openssh 
            bashInteractive
            fishPlugins.foreign-env
          ];

          programs.git = {
            enable = true;
            userName = "Michael Reddick";
            userEmail = "michael.reddick@gmail.com";
      	  };

          programs.neovim = {
            enable = true;
            vimAlias = true; 
          };
	   
          programs.tmux = {
            enable = true;
            terminal = "xterm-256color";
          };

	  programs.fish = {
            enable = true;
            shellInit = ''
	      # add pkgs.fishPlugins.foreign-env to fish_function_path
              set --prepend fish_function_path "${pkgs.fishPlugins.foreign-env}/share/fish/vendor_functions.d"

              # add nix stuff to path (for non nixos install)
	      fenv source $HOME/.nix-profile/etc/profile.d/nix.sh

              contains $HOME/.nix-defexpr/channels $NIX_PATH; or set -x NIX_PATH "$HOME/.nix-defexpr/channels" $NIX_PATH
	      #fenv export NIX_PATH=$HOME/.nix-defexpr/channels:$NIX_PATH
	      #fenv source $HOME/.profile
	    '';
	  };
	};
      };
    };
  };
}
