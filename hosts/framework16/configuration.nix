{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
  ];

  networking.hostName = "framework16";

  # First NixOS release installed on this machine. Never change it.
  system.stateVersion = "26.05";
}
