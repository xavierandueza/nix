# Nix Config

My NixOS (Framework 16) and nix-darwin (MacBook) configuration in one flake.

Main things that I focus on:
- Hyprland on Linux, AeroSpace on macOS
- Keeping things simple
- TUI where it makes sense
- Centralize into smaller atomic apps rather than many that do the same thing
- Shared program config across machines (`home/common`), OS-specific bits kept separate

## macOS bootstrap

1. Give the Mac its own sops identity:

   ```sh
   sudo mkdir -p /var/lib/sops-nix
   sudo nix shell nixpkgs#age -c age-keygen -o /var/lib/sops-nix/key.txt
   sudo chmod 600 /var/lib/sops-nix/key.txt
   sudo nix shell nixpkgs#age -c age-keygen -y /var/lib/sops-nix/key.txt   # public key
   ```

2. On a machine that can already decrypt (the Framework), add that public key to `.sops.yaml`, then re-encrypt and commit:

   ```sh
   nix shell nixpkgs#sops -c sops updatekeys secrets/secrets.yaml
   ```

3. Home Manager now owns `~/.local/bin/claude`, a wrapper that uses the sops setup-token. Move the native installer's symlink out of the way, because Home Manager won't back up symlinks:

   ```sh
   mv ~/.local/bin/claude ~/.local/bin/claude.native
   ```

4. First switch:

   ```sh
   sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .
   ```

After that: `sudo darwin-rebuild switch --flake .`
