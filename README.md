# Nix Config

My NixOS (Framework 16) and nix-darwin (MacBook) configuration in one flake.

Main things that I focus on:
- Hyprland on Linux, AeroSpace on macOS
- Keeping things simple
- TUI where it makes sense
- Centralize into smaller atomic apps rather than many that do the same thing
- Shared program config across machines (`home/common`), OS-specific bits kept separate

## macOS bootstrap

```sh
# Provision the sops age key first (see .sops.yaml), then:
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .
```

After the first switch: `sudo darwin-rebuild switch --flake .`
