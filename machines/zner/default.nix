{ config, pkgs, modulesPath, ... }:

{
  imports = [ ./hardware-configuration.nix <home-manager/nixos> ];

  networking.hostName = "zner";
}
