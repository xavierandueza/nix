{ pkgs, lib, ... }:
let
  # Not in nixpkgs; its bundled Playwright is ahead of nixpkgs' playwright-driver,
  # so point it at nixpkgs Chromium instead of Playwright-managed browsers.
  playwright-cli = pkgs.writeShellApplication {
    name = "playwright-cli";
    runtimeInputs = [ pkgs.nodejs_22 ];
    text = ''
      export PLAYWRIGHT_MCP_EXECUTABLE_PATH="''${PLAYWRIGHT_MCP_EXECUTABLE_PATH:-${lib.getExe pkgs.chromium}}"
      exec npx --yes @playwright/cli@0.1.23 "$@"
    '';
  };
in
{
  home.packages = [ playwright-cli ];
}
