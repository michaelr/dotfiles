{
  description = "Home manager flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };
  
  outputs = inputs: {
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

          # Let Home Manager install and manage itself.
          programs.home-manager.enable = true;

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

        };
      };
    };
  };
}
