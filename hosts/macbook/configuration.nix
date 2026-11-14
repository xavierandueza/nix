{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ./aerospace.nix
    ./homebrew.nix
    ../../modules/shared/secrets.nix
  ];

  users.users.xavier = {
    name = "xavier";
    home = "/Users/xavier";
    shell = pkgs.bashInteractive;
  };

  environment.shells = [ pkgs.bashInteractive ];

  system.primaryUser = "xavier";

  system.keyboard = {
    enableKeyMapping = true;
    userKeyMapping = [
      {
        HIDKeyboardModifierMappingSrc = 30064771129; # Caps Lock (0x700000039)
        HIDKeyboardModifierMappingDst = 30064771114; # Backspace (0x70000002A)
      }
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    pkgs.ghostty-bin
    pkgs.obsidian
    pkgs.slack
    pkgs.mongodb-compass
  ];

  services.redis = {
    enable = true;
    port = 6379;
  };

  # The redis module hardcodes `dir /var/lib/redis` in /etc/redis.conf but never
  # creates it; without this the launchd agent crashes on startup.
  system.activationScripts.extraActivation.text = ''
    mkdir -p /var/lib/redis
    chown xavier:staff /var/lib/redis
  '';

  # Resolve readme.local and all *.readme.local subdomains to localhost.
  services.dnsmasq = {
    enable = true;
    bind = "127.0.0.1";
    addresses = {
      "readme.local" = "127.0.0.1";
    };
  };

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = "nix-command flakes";

  # A flake is either clean (rev) or dirty (dirtyRev), never both.
  system.configurationRevision = lib.mkMerge [
    (lib.mkIf (inputs.self ? rev) inputs.self.rev)
    (lib.mkIf (inputs.self ? dirtyRev) inputs.self.dirtyRev)
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  nixpkgs.hostPlatform = "aarch64-darwin";

  system.defaults = {
    WindowManager = {
      EnableStandardClickToShowDesktop = false;
      StandardHideWidgets = true;
      StageManagerHideWidgets = true;
    };
    dock = {
      autohide = true;
      persistent-apps = [
        "/Applications/Nix Apps/Slack.app"
        "/Applications/Nix Apps/Ghostty.app"
        "/Users/xavier/Applications/Home Manager Apps/Zen Browser (Beta).app"
      ];
      tilesize = 48;
    };
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    NSGlobalDomain.KeyRepeat = 2;
  };

  # Login shell can only be changed after activation has linked the new bash.
  system.activationScripts.postActivation.text = ''
    CURRENT_SHELL=$(dscl . -read /Users/xavier UserShell 2>/dev/null | awk '{print $2}')
    TARGET_SHELL="/run/current-system/sw/bin/bash"
    echo "Current shell is $CURRENT_SHELL"
    if [ "$CURRENT_SHELL" != "$TARGET_SHELL" ]; then
      echo "Setting login shell to $TARGET_SHELL"
      dscl . -create /Users/xavier UserShell "$TARGET_SHELL"
    fi
  '';
}
