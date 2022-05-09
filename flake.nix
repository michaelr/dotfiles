{
  description = "Home manager flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-sumneko-3-2.url = "github:NixOS/nixpkgs?rev=36563d95276f3bf4b144e6e3b355e666ca9f97f4";

    nur.url = "github:nix-community/NUR";

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

    flake-utils-plus.url = github:gytis-ivaskevicius/flake-utils-plus;

    deploy-rs = {
      url = github:serokell/deploy-rs;
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs@{ self, nixpkgs, flake-utils-plus, home-manager, fish-nix-env, fish-theme-bobthefish, nixpkgs-sumneko-3-2, ... }:
    let
      sumneko-overlay = final: prev: {
        sumneko-3-2 = nixpkgs-sumneko-3-2.legacyPackages.${prev.system};
      };
      overlays = [
        inputs.neovim-nightly-overlay.overlay
        inputs.nur.overlay
        sumneko-overlay
      ];

      nixosModules = flake-utils-plus.lib.exportModules (
        nixpkgs.lib.mapAttrsToList (name: value: ./nixosModules/${name}) (builtins.readDir ./nixosModules)
      );
    in

    flake-utils-plus.lib.mkFlake {
      inherit self inputs nixosModules;

      channelsConfig.allowUnfree = true;

      hostDefaults = {
        system = "x86_64-linux";
        modules = [
          nixosModules.common
          nixosModules.admin
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
            };
          }

        ];
      };

      sharedOverlays = overlays;

      hosts.zner.modules = [ ./machines/zner nixosModules.docker ];
      hosts.nixos-vmware.modules = [
        (import ./machines/nixos-vmware {
          fish-nix-env = fish-nix-env;
          fish-theme-bobthefish = fish-theme-bobthefish;
        })

      ];

      outputsBuilder = (channels: {
        devShell = channels.nixpkgs.mkShell {
          name = "my-deploy-shell";
          buildInputs = with channels.nixpkgs; [
            nixUnstable
            inputs.deploy-rs.defaultPackage.${system}
          ];
        };
      });

      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy)
        inputs.deploy-rs.lib;
    };
}
