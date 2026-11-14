{ pkgs, ... }:

{
  home.username = "xavier";
  home.homeDirectory = "/home/xavier";
  home.stateVersion = "26.05";
  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.freecad
    pkgs.slack
    pkgs.discord
    pkgs.wl-clipboard
    pkgs.google-cloud-sdk
  ];

  imports = [
    ../../home/common
    ../../home/linux
    ./zen-browser.nix
  ];
}
