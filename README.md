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

## New NixOS host bootstrap

New NixOS hosts are installed remotely from the Framework with [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) and partitioned by disko (`hosts/<host>/disk.nix`). Shared system config lives in `modules/nixos/common.nix`.

1. Once per repo: the `xavier-password` secret must exist, or every NixOS build fails. Generate a hash and add it as `xavier-password: '<hash>'`:

   ```sh
   nix shell nixpkgs#mkpasswd -c mkpasswd -m yescrypt
   nix shell nixpkgs#sops -c sops secrets/secrets.yaml
   ```

   It is only applied when the user is first created; change it later with `passwd`.

2. On the target, boot the NixOS installer in UEFI mode, get online, then:

   ```sh
   passwd                  # lets nixos-anywhere SSH in as `nixos`
   ip a                    # note the IP
   ls -l /dev/disk/by-id   # pick the internal disk
   ```

   Put that `/dev/disk/by-id/...` path in `hosts/<host>/disk.nix`.

3. On the Framework, stage the host's sops identity and disk passphrase in a private directory:

   ```sh
   umask 077
   stage=$(mktemp -d)
   mkdir -p "$stage/extra/var/lib/sops-nix"
   nix shell nixpkgs#age -c age-keygen -o "$stage/extra/var/lib/sops-nix/key.txt"
   nix shell nixpkgs#age -c age-keygen -y "$stage/extra/var/lib/sops-nix/key.txt"   # public key
   IFS= read -rs pw && printf '%s' "$pw" > "$stage/disk.key" && unset pw            # typed at every boot
   ```

4. Add the public key to `.sops.yaml` (anchor plus key group), re-encrypt, and check the new key can decrypt the password:

   ```sh
   nix shell nixpkgs#sops -c sops updatekeys secrets/secrets.yaml
   SOPS_AGE_KEY_FILE="$stage/extra/var/lib/sops-nix/key.txt" \
     nix shell nixpkgs#sops -c sops -d --extract '["xavier-password"]' secrets/secrets.yaml
   ```

5. Install:

   ```sh
   nix run github:nix-community/nixos-anywhere -- \
     --flake .#<host> \
     --generate-hardware-config nixos-generate-config ./hosts/<host>/hardware-configuration.nix \
     --disk-encryption-keys /tmp/disk.key "$stage/disk.key" \
     --extra-files "$stage/extra" \
     nixos@<ip>
   ```

6. Clean up and commit: `rm -rf "$stage"`, then commit `.sops.yaml`, `secrets/secrets.yaml` and the generated `hardware-configuration.nix`.

7. On the new host: join wifi with `iwctl`, run `sudo tailscale up`, clone this repo to `~/projects/nix` and `sudo ln -s ~/projects/nix /etc/nixos`.
