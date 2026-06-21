# nix-darwin setup

Personal macOS configuration managed with **nix-darwin** + **home-manager** (flake-based).

## Conventions

- **Nix over Homebrew** — install everything via nix where possible. Only fall back to Homebrew (`flake.nix` `homebrew.casks`) when a package is mac-only/GUI and not viable through nix.
- **TUI over GUI** — prefer terminal tools (e.g. `lazygit`, `lazydocker`, `yazi`, `bottom`) over GUI apps.
- **Break out large configs** — any sizeable program config lives in its own file under `programs/` and is imported from `home.nix`. Keep `home.nix` lean.

## Rebuild

```sh
sudo nix run nix-darwin -- switch --flake ~/.config/nix
```

## Structure

```
.
├── flake.nix            # inputs, darwinConfiguration, system + homebrew config
├── flake.lock
├── home.nix             # home-manager: user packages, dotfiles, program modules
└── programs/            # broken-out per-program configs (imported by home.nix)
    ├── karabiner.nix
    ├── nvim.nix
    └── tmux.nix
```

## Notes

- Global agent instructions (this repo's source) are symlinked into each harness's config dir from `home.nix` (`.claude`, `.codex`, `opencode`, `.pi`). Symlink individual files/dirs — never a whole agent state dir, since those hold live state (auth, sessions, settings).
- `home.stateVersion` is set once; don't bump casually.
