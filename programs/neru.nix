{ ... }:

{
  xdg.configFile."neru/config.toml".text = ''
    [hotkeys]
    "Primary+Shift+Space" = "grid --action left_click"
    "Primary+Shift+C" = "__disabled__"

    [grid.hotkeys]
    "Shift+L" = ["action left_click", "idle"]
  '';
}
