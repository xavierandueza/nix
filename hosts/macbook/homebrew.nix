{ inputs, ... }:

{
  nix-homebrew = {
    enable = true;
    enableRosetta = false;
    user = "xavier";
    # Adopts the Homebrew install that existed before nix-homebrew.
    autoMigrate = true;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "y3owk1n/homebrew-tap" = inputs.y3owk1n-tap;
      "anthropics/homebrew-tap" = inputs.anthropics-tap;
    };
    mutableTaps = false;
  };

  homebrew = {
    enable = true;
    casks = [
      "steam"
      "anthropics/tap/ant"
      "loom"
      "karabiner-elements"
      "signal" # Although on nixpkgs needs constant updates
      "discord"
      "betterdisplay"
      "keepingyouawake"
      "y3owk1n/tap/neru"
      "music-decoy"
    ];
  };
}
