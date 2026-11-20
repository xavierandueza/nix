{ ... }:

{
  imports = [
    ../../home/common
    ../../home/linux
    ./zen-browser.nix
  ];

  home.stateVersion = "26.05";
}
