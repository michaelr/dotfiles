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
        nixos-vmware = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            (import ./hosts/nixos-vmware.nix
              {
                fish-theme-bobthefish = inputs.fish-theme-bobthefish;
                fish-nix-env = inputs.fish-nix-env;
              })

            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
              };
              networking.hostName = "nixos-vmware";
            }
            { nixpkgs.overlays = overlays; }
          ];
        };
      };
    };
}
