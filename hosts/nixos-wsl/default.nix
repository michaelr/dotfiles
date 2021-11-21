{ lib, pkgs, config, ... }:

with lib;
let
  defaultUser = "michaelr";
  syschdemd = import ./syschdemd.nix { inherit lib pkgs config defaultUser; };
in
{

  # WSL is closer to a container than anything else
  boot.isContainer = true;

  environment.extraInit = ''PATH="$PATH:$WSLPATH"'';

  # Install manpages and other documentation.
  documentation.enable = true;

  # Run tzupdate service to auto-detect the time zone.
  services.tzupdate.enable = true;

  environment.etc.hosts.enable = false;
  environment.etc."resolv.conf".enable = false;

  networking.dhcpcd.enable = false;

  users.users.${defaultUser} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  users.users.root = {
    shell = "${syschdemd}/bin/syschdemd";
    # Otherwise WSL fails to login as root with "initgroups failed 5"
    extraGroups = [ "root" ];
  };

  security.sudo.wheelNeedsPassword = false;

  # Disable systemd units that don't make sense on WSL
  systemd.services."serial-getty@ttyS0".enable = false;
  systemd.services."serial-getty@hvc0".enable = false;
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@".enable = false;

  systemd.services.firewall.enable = false;
  systemd.services.systemd-resolved.enable = false;
  systemd.services.systemd-udevd.enable = false;

  # Don't allow emergency mode, because we don't have a console.
  systemd.enableEmergencyMode = false;
}
