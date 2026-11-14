{ ... }:

{
  imports = [
    ./agent-instructions.nix
    ./claude-code.nix
    ./herdr.nix
    ./loops.nix
    ./mcp.nix
    ./nvim.nix
    ./pi.nix
    ./playwright.nix
    ./skills.nix
    ./terminal.nix
  ];

  fonts.fontconfig.enable = true;
}
