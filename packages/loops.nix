{ pkgs, inputs }:
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
in
# The upstream bin/loops uses `$(dirname "$0")` which breaks through nix symlinks,
# so we create a wrapper that invokes tsx and the source with absolute store paths.
pkgs.writeShellScriptBin "loops" ''
  exec ${loopsPkg}/lib/node_modules/loops/node_modules/.bin/tsx \
    ${loopsPkg}/lib/node_modules/loops/src/index.ts "$@"
''
