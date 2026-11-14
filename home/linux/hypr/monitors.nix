{ ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;

    extraConfig = ''
      -- Scaling xwayland apps
      hl.env("GDK_SCALE", "2")
      hl.env("XCURSOR_SIZE", "32")

      -- Monitors
      hl.monitor({
        output = "edp-1",
        mode = "preferred",
        scale = "auto"
      })

      hl.monitor({
        output = "DP-4",
        mode = "3840x2160@120.00",
        scale = "1.5"
      })

      hl.monitor({
        output = "DP-3",
        mode = "preferred",
        scale = "1.6666666",
      })
    '';
  };
}
