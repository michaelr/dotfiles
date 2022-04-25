{
  description = "Home manager flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";

    # make home-manager use same nixpkgs we're using
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

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

    work-utils = {
      url = git+ssh://git@github.com/michaelr/work-utils.git;
      inputs.nixpkgs.follows = "nixpkgs";
      #flake = false;
    };

    flake-utils-plus.url = github:gytis-ivaskevicius/flake-utils-plus;
    deploy-rs = {
      url = github:serokell/deploy-rs;
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs@{ self, nixpkgs, flake-utils-plus, home-manager, fish-nix-env, fish-theme-bobthefish, work-utils, ... }:
    let
      overlays = [
        inputs.neovim-nightly-overlay.overlay
        inputs.work-utils.overlay
        inputs.nur.overlay
      ];

      nixosModules = flake-utils-plus.lib.exportModules (
        nixpkgs.lib.mapAttrsToList (name: value: ./nixosModules/${name}) (builtins.readDir ./nixosModules)
      );
    in

    flake-utils-plus.lib.mkFlake {
      inherit self inputs nixosModules;

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
          work-utils = work-utils;
        })

      ];
      # nixos-vmware = nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";
      #   modules = [
      #     (import ./hosts/nixos-vmware.nix
      #       {
      #         fish-theme-bobthefish = inputs.fish-theme-bobthefish;
      #         fish-nix-env = inputs.fish-nix-env;
      #       })
      #
      #     inputs.home-manager.nixosModules.home-manager
      #     {
      #       home-manager = {
      #         useGlobalPkgs = true;
      #         useUserPackages = true;
      #       };
      #       networking.hostName = "nixos-vmware";
      #     }
      #     { nixpkgs.overlays = overlays; }
      #   ];
      # };


      # nixosConfigurations = {
      # nixos-wsl = nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";
      #   modules = [
      #     (import ./hosts/nixos-wsl.nix
      #       {
      #         wsl-open = inputs.wsl-open;
      #         fish-theme-bobthefish = inputs.fish-theme-bobthefish;
      #         fish-nix-env = inputs.fish-nix-env;
      #       })
      #
      #     inputs.home-manager.nixosModules.home-manager
      #     {
      #       home-manager = {
      #         useGlobalPkgs = true;
      #         useUserPackages = true;
      #       };
      #       networking.hostName = "nixos-wsl";
      #     }
      #     { nixpkgs.overlays = overlays; }
      #   ];
      # };
      # nixos-vmware = nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";
      #   modules = [
      #     (import ./hosts/nixos-vmware.nix
      #       {
      #         fish-theme-bobthefish = inputs.fish-theme-bobthefish;
      #         fish-nix-env = inputs.fish-nix-env;
      #       })
      #
      #     inputs.home-manager.nixosModules.home-manager
      #     {
      #       home-manager = {
      #         useGlobalPkgs = true;
      #         useUserPackages = true;
      #       };
      #       networking.hostName = "nixos-vmware";
      #     }
      #     { nixpkgs.overlays = overlays; }
      #   ];
      # };
      # };

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
