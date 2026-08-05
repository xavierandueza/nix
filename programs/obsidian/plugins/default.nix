{ pkgs }:

{
  advanced-line-numbers = import ./advanced-line-numbers.nix { inherit pkgs; };
  obsidian-git = import ./obsidian-git.nix { inherit pkgs; };
}
