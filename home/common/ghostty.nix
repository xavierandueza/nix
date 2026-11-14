{ pkgs, lib, ... }:

{
  programs.ghostty = lib.mkMerge [
    {
      enable = true;
      settings = {
        theme = "TokyoNight Moon";
        clipboard-read = "allow";
      };
    }
    (lib.mkIf pkgs.stdenv.isLinux {
      clearDefaultKeybinds = true; # Never use them
      settings = {
        font-size = 10;
        keybind = [
          "ctrl+shift+c=copy_to_clipboard"
          "ctrl+shift+v=paste_from_clipboard"
          "ctrl+shift+comma=reload_config"
        ];
      };
    })
    (lib.mkIf pkgs.stdenv.isDarwin {
      # nix-darwin installs the app into /Applications/Nix Apps; this only owns the config.
      package = null;
      settings = {
        font-family = "JetBrainsMono Nerd Font";
        macos-option-as-alt = "left";
      };
    })
  ];
}
