{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";

    # Home/User-based management
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Homebrew + Taps
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };
  };
  
  outputs = inputs@{ self, ... }:
  let
    configuration = { pkgs, config, ... }: {
      # Specify user for home management
      users.users.xavier = {
        name = "xavier";
        home = "/Users/xavier";
	shell = pkgs.bashInteractive;
      };

      # Add the interactive bash shell to the shells
      environment.shells = [ pkgs.bashInteractive ];

      # Homebrew only packages
      homebrew = {
        enable = true;
        casks = [
          "zen"
        ];
      };

      # For MacOS default settings need to specify primary user
      system.primaryUser = "xavier";

      system.keyboard = {
        enableKeyMapping = true;
        userKeyMapping = [
          { 
            HIDKeyboardModifierMappingSrc = 30064771129;  # Caps Lock (0x700000039)
            HIDKeyboardModifierMappingDst = 30064771114;  # Backspace (0x70000002A)
	  }
        ];
      };
      
      # Allow non FOSS packages
      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
	  # Terminal
	  pkgs.ghostty-bin

	  # GUI
	  pkgs.slack
        ];

      services.aerospace = {
        enable = true;
        settings = {
	  "key-mapping".preset = "colemak";
          # your aerospace config as a Nix attrset → generated to TOML
          gaps = {
            inner.horizontal = 8;
            inner.vertical = 8;
            outer.left = 8;
            outer.right = 8;
            outer.top = 8;
            outer.bottom = 8;
          };

          # Monitor assignment
          "workspace-to-monitor-force-assignment" = {
            "1" = "secondary";
            "2" = "secondary";
	  };

          mode.main.binding = {
	    # Standards
            alt-enter = "exec-and-forget open -na Ghostty";
            alt-h = "focus --boundaries all-monitors-outer-frame --boundaries-action wrap-around-all-monitors left";
            alt-j = "focus --boundaries all-monitors-outer-frame --boundaries-action wrap-around-all-monitors down";
            alt-k = "focus --boundaries all-monitors-outer-frame --boundaries-action wrap-around-all-monitors up";
            alt-l = "focus --boundaries all-monitors-outer-frame --boundaries-action wrap-around-all-monitors right";

            # focus workspace
            alt-1 = "workspace 1";
            alt-2 = "workspace 2";
            alt-3 = "workspace 3";
            alt-4 = "workspace 4";
            alt-5 = "workspace 5";
            alt-6 = "workspace 6";
            alt-7 = "workspace 7";
            alt-8 = "workspace 8";
            alt-9 = "workspace 9";

            # move focused window to workspace
            alt-shift-1 = "move-node-to-workspace 1 --focus-follows-window";
            alt-shift-2 = "move-node-to-workspace 2 --focus-follows-window";
            alt-shift-3 = "move-node-to-workspace 3 --focus-follows-window";
            alt-shift-4 = "move-node-to-workspace 4 --focus-follows-window";
            alt-shift-5 = "move-node-to-workspace 5 --focus-follows-window";
            alt-shift-6 = "move-node-to-workspace 6 --focus-follows-window";
            alt-shift-7 = "move-node-to-workspace 7 --focus-follows-window";
            alt-shift-8 = "move-node-to-workspace 8 --focus-follows-window";
            alt-shift-9 = "move-node-to-workspace 9 --focus-follows-window";

          };
        };
      };

      services.jankyborders = {
        enable = true;
        active_color = "0xff00ffd2";
        inactive_color = "off";
        width = 7.0;
      };

      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # MacOS defaults
      system.defaults = {
        dock.autohide = true;
	NSGlobalDomain.AppleInterfaceStyle = "Dark";
	NSGlobalDomain.KeyRepeat = 2;
      };

      # set shell to bash - has to be post activation
      system.activationScripts.postActivation.text = ''
        CURRENT_SHELL=$(dscl . -read /Users/xavier UserShell 2>/dev/null | awk '{print $2}')
        TARGET_SHELL="/run/current-system/sw/bin/bash"
	echo "Current shell is $CURRENT_SHELL"
        if [ "$CURRENT_SHELL" != "$TARGET_SHELL" ]; then
          echo "Setting login shell to $TARGET_SHELL"
          dscl . -create /Users/xavier UserShell "$TARGET_SHELL"
        fi
      '';
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Xaviers-MacBook-Pro
    darwinConfigurations."Xaviers-MacBook-Pro" = inputs.nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        inputs.mac-app-util.darwinModules.default
	inputs.home-manager.darwinModules.home-manager
	{
	  home-manager.useGlobalPkgs = true;
	  home-manager.useUserPackages = true;
	  home-manager.users.xavier = import ./home.nix;
	}

	# Homebrew config	  
	inputs.nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = false;   # see note below
            user = "xavier";
            autoMigrate = true;      # adopt your EXISTING brew install
            taps = {
              "homebrew/homebrew-core" = inputs.homebrew-core;
              "homebrew/homebrew-cask" = inputs.homebrew-cask;
            };
            mutableTaps = false;
          };
        }
      ];                 	  
    };
  };
}
