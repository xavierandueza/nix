{
  description = "NixOS and nix-darwin configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";
    pi.url = "github:earendil-works/pi/stable";

    agents = {
      url = "github:xavierandueza/agents";
      flake = false;
    };

    herdr-include = {
      url = "github:xavierandueza/herdrinclude";
      flake = false;
    };

    loops = {
      url = "github:xavierandueza/loops";
      flake = false;
    };

    work = {
      url = "github:xavierandueza/work-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util.url = "github:hraban/mac-app-util";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    y3owk1n-tap = {
      url = "github:y3owk1n/homebrew-tap";
      flake = false;
    };
    anthropics-tap = {
      url = "github:anthropics/homebrew-tap";
      flake = false;
    };
  };

  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    let
      homeManager =
        { pkgs, ... }:
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          # Timestamped so repeated clobbers never collide with an earlier backup.
          home-manager.backupCommand = pkgs.writeShellScript "home-manager-timestamped-backup" ''
            set -eu

            target="$1"
            timestamp="$(${pkgs.coreutils}/bin/date +%Y%m%d-%H%M%S)"
            backup="$target.bak.$timestamp"
            suffix=1

            while [ -e "$backup" ]; do
              backup="$target.bak.$timestamp.$suffix"
              suffix=$((suffix + 1))
            done

            ${pkgs.coreutils}/bin/mv -- "$target" "$backup"
          '';
        };
    in
    {
      nixosConfigurations.framework16 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/framework16/configuration.nix
          inputs.sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          homeManager
          { home-manager.users.xavier = import ./hosts/framework16/home.nix; }
        ];
      };

      # Named after the Mac's hostname so `darwin-rebuild switch --flake .` picks it up.
      darwinConfigurations."Xaviers-MacBook-Pro" = inputs.nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/macbook/configuration.nix
          inputs.sops-nix.darwinModules.sops
          inputs.mac-app-util.darwinModules.default
          inputs.nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          homeManager
          {
            home-manager.sharedModules = [ inputs.mac-app-util.homeManagerModules.default ];
            home-manager.users.xavier = import ./hosts/macbook/home.nix;
          }
        ];
      };
    };
}
