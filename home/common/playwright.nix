{ pkgs, lib, ... }:
let
  # Not in nixpkgs; its bundled Playwright is ahead of nixpkgs' playwright-driver,
  # so on Linux point it at nixpkgs Chromium instead of Playwright-managed browsers.
  # nixpkgs Chromium doesn't build on macOS, so there it uses the installed Chrome.
  chromiumOverride = lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
    export PLAYWRIGHT_MCP_EXECUTABLE_PATH="''${PLAYWRIGHT_MCP_EXECUTABLE_PATH:-${lib.getExe pkgs.chromium}}"
  '';

  playwright-cli = pkgs.writeShellApplication {
    name = "playwright-cli";
    runtimeInputs = [ pkgs.nodejs_22 ];
    text = ''
      ${chromiumOverride}
      exec npx --yes @playwright/cli@0.1.23 "$@"
    '';
  };
in
{
  home.packages = [ playwright-cli ];
}
