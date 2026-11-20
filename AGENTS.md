# Nix config

Flake-based NixOS + nix-darwin config, both with Home Manager. One flake, one host per machine:

- `framework16`: Framework 16 running NixOS. This repo is symlinked to `/etc/nixos`.
- `dell`: Dell laptop running NixOS, LUKS-encrypted and partitioned by disko. Installed with nixos-anywhere (see README).
- `Xaviers-MacBook-Pro`: MacBook running nix-darwin. The output name matches the Mac's hostname, so `darwin-rebuild` picks it up automatically.

## Philosophy

- **Hyprland** desktop on Linux (Wayland); **AeroSpace** on macOS.
- **TUI over GUI** wherever a reasonable terminal tool exists
  (e.g. `impala` for wifi, `bluetui` for bluetooth, `lazygit`, `lazydocker`).
- **Nix over Homebrew** on macOS; casks only for mac-only GUI apps nix can't provide well.
- One program per file; larger categories get a sub-folder.

## Layout

```
flake.nix          # inputs + nixosConfigurations + darwinConfigurations, shared Home Manager settings
hosts/<host>/      # one machine: system config, home.nix (stateVersion, host packages), host-only programs
modules/nixos/     # NixOS system modules; common.nix is shared by every NixOS host
modules/shared/    # system modules valid on NixOS and nix-darwin (sops secrets)
home/common/       # Home Manager modules used on every host
home/linux/        # Home Manager modules that only work on Linux (Hyprland, Wayland tools)
home/darwin/       # Home Manager modules that only work on macOS
packages/          # custom derivations
assets/            # wallpapers etc.
secrets/           # sops-encrypted secrets
```

## Where things go

- Program used on every host → `home/common/`, even when it needs platform-specific bits. Branch inside the file with `lib.mkIf pkgs.stdenv.hostPlatform.isLinux` / `isDarwin` so one source of truth exists per program.
- Program tied to one OS → `home/linux/` or `home/darwin/`.
- Program or setting chosen for only one machine (e.g. per-machine Zen profiles, the Mac's git identity) → `hosts/<host>/`.
- Register new files in the folder's `default.nix` (or the host's `home.nix`).
- Terminal-environment things (shell, prompt, CLI/TUI tools) go in `home/common/terminal.nix`; Linux-only ones in `home/linux/terminal.nix`.
- Flake inputs are available in every module via `inputs` (`specialArgs` and `extraSpecialArgs`).
- New files must be tracked by git (`git add -N <file>` at minimum) or the flake won't see them.
- Format with `nixfmt`.

## Applying changes

NixOS:

```sh
sudo nixos-rebuild test     # try it out (not persisted to boot menu)
sudo nixos-rebuild switch   # only after `test` succeeds
```

macOS:

```sh
sudo darwin-rebuild switch --flake .
```

Quick eval checks without building:

```sh
nix eval .#nixosConfigurations.framework16.config.system.build.toplevel.drvPath
nix eval '.#darwinConfigurations."Xaviers-MacBook-Pro".system.drvPath'
```

The darwin eval needs a macOS machine (or darwin builder): the Obsidian Home Manager module reads plugin files at eval time. From Linux, check it with `programs.obsidian` forced off via `extendModules`.
