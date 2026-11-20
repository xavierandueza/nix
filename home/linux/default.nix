{ pkgs, inputs, ... }:

{
  imports = [
    ./hypr
    ./screenshot.nix
    ./terminal.nix
    ./voxtype.nix
    ./wayvnc.nix
    inputs.work.homeModules.default
  ];

  home.username = "xavier";
  home.homeDirectory = "/home/xavier";

  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.freecad
    pkgs.slack
    pkgs.discord
  ];

  fonts.fontconfig.enable = true;

  # /etc/nixos symlinks to this repo
  programs.git.settings.safe.directory = "/etc/nixos";
}
