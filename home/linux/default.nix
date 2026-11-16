{ ... }:

{
  imports = [
    ./hypr
    ./screenshot.nix
    ./terminal.nix
    ./voxtype.nix
    ./wayvnc.nix
  ];

  fonts.fontconfig.enable = true;
}
