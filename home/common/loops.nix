{ pkgs, inputs, ... }:
let
  loopsPkg = pkgs.buildNpmPackage {
    pname = "loops";
    version = "0.1.0";
    src = inputs.loops;
    npmDepsHash = "sha256-r0mufCb2hlbVl75CFCtQyePxvONmWPvBwIbTkWFCYww=";
    npmInstallFlags = [ "--include=dev" ];
    dontNpmBuild = true;
    installPhase = ''
      mkdir -p $out/lib/node_modules/loops
      cp -r . $out/lib/node_modules/loops/
    '';
  };

  # Upstream bin/loops resolves paths via `$(dirname "$0")`, which breaks through
  # nix symlinks, so call tsx and the source with absolute store paths instead.
  loops = pkgs.writeShellScriptBin "loops" ''
    exec ${loopsPkg}/lib/node_modules/loops/node_modules/.bin/tsx \
      ${loopsPkg}/lib/node_modules/loops/src/index.ts "$@"
  '';
in
{
  home.packages = [ loops ];
}
