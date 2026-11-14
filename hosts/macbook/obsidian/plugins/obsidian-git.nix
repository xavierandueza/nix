{ pkgs }:

let
  version = "2.38.6";
in
pkgs.fetchzip {
  name = "obsidian-git-${version}";
  url = "https://github.com/Vinzent03/obsidian-git/releases/download/${version}/obsidian-git-${version}.zip";
  hash = "sha256-GHaYFW9IL/T4dCxJLZ6A5Y6eQ4h+4aIJs095+/rxdic=";
}
