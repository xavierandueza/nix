{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk.nix
    ../../modules/nixos/common.nix
  ];

  networking.hostName = "dell";

  # First NixOS release installed on this machine. Never change it.
  system.stateVersion = "26.11";
}
