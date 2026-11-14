{ pkgs }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "anarlog";
  version = "1.0.47";

  src = pkgs.fetchurl {
    url = "https://github.com/fastrepl/anarlog/releases/download/desktop_v1.0.47/hyprnote-macos-aarch64.dmg";
    hash = "sha256-cRg8lU5RtGvXuwdPW92D1YEZy+cm45Yw3D2r+hM+icw=";
  };

  nativeBuildInputs = [ pkgs.undmg ];
  sourceRoot = ".";

  installPhase = ''
    mkdir -p "$out/Applications"
    cp -r *.app "$out/Applications/"
  '';

  meta.platforms = [ "aarch64-darwin" ];
}
