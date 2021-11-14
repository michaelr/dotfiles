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

          programs.bash = {
            enable = true;
	    profileExtra = builtins.readFile ./bash-profileExtra;
          };
	};
      };
    };
  };
}
