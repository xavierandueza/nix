{ config, lib, ... }:

let
  wallpaper = "${config.home.homeDirectory}/Pictures/Wallpapers/desktop.png";
in
{
  home.file."Pictures/Wallpapers/desktop.png".source = ../assets/wallpapers/desktop.png;

  home.activation.setDesktopWallpaper = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    /usr/bin/osascript - "${wallpaper}" <<'APPLESCRIPT'
    on run argv
      set wallpaperPath to item 1 of argv

      tell application "System Events"
        repeat with desktopItem in desktops
          set picture of desktopItem to POSIX file wallpaperPath
        end repeat
      end tell
    end run
    APPLESCRIPT
  '';
}
