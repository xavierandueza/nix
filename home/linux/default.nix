{ ... }:

{
  imports = [
    ./hypr
    ./screenshot.nix
    ./terminal.nix
    ./voxtype.nix
  ];

  fonts.fontconfig.enable = true;
}
