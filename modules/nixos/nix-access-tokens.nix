{ config, ... }:

{
  # `sudo nixos-rebuild` fetches flake inputs as root, which has no GitHub login for private repos.
  sops.templates.nix-access-tokens = {
    content = "access-tokens = github.com=${config.sops.placeholder.github-token}";
    # Root-owned since root includes it; wheel can read it for `nix flake update`.
    owner = "root";
    group = "wheel";
    mode = "0440";
  };

  nix.extraOptions = "!include ${config.sops.templates.nix-access-tokens.path}";
}
