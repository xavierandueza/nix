{ pkgs }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "hypa";
  version = "0.1.6";

  src = pkgs.fetchurl {
    url = "https://github.com/Hypabolic/Hypa/releases/download/v0.1.6/hypa-osx-arm64.tar.gz";
    hash = "sha256-DXtFJHaz00mvn8AZX7vqN90ybLS/W9IJxGmHzKnrpu4=";
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -p "$out/bin"
    bin=$(find . -type f -name hypa | head -n 1)
    cp "$bin" "$out/bin/hypa"
    chmod +x "$out/bin/hypa"
  '';

  meta.platforms = [ "aarch64-darwin" ];
}
