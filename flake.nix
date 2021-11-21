{
  description = "michaelr nix/os config flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.3.0";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

  outputs = { self, nixpkgs, utils, ... }@inputs:
    utils.lib.mkFlake {
      inherit self inputs;

      channelsConfig.allowUnfree = true;

      sharedOverlays = [
        self.overlay
        inputs.neovim-nightly-overlay.overlay
      ];

      hostDefaults.modules = [
        inputs.home-manager.nixosModules.home-manager
        ./modules/sharedConfigurationBetweenHosts.nix
          {
            home-manager = {
              extraSpecialArgs = {
                inherit inputs self;
              };
            };
          }
      ];

      # https://github.com/fufexan/dotfiles/blob/443620bf03f3c3a3922598609b8fa7cacf4e865b/flake.nix
      hosts.nixos-wsl.modules = [
        ./hosts/nixos-wsl
        { home-manager.users.michaelr = import ./home; }
      ];

      overlay = import ./overlays;

      homeConfigurations = {
        "michaelr@nixos-wsl" = inputs.home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          homeDirectory = "/home/michaelr";
          username = "michaelr";
          extraSpecialArgs = { inherit inputs self; };
          generateHome = inputs.home-manager.lib.homeManagerConfiguration;

          extraModules = [ ./home ];
	};
      };
    };
}
