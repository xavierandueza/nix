{ ... }:

{
  services.aerospace = {
    enable = true;
    settings = {
      "key-mapping".preset = "colemak";
      gaps = {
        inner.horizontal = 8;
        inner.vertical = 8;
        outer.left = 8;
        outer.right = 8;
        outer.top = 8;
        outer.bottom = 8;
      };

      # Monitor assignment
      "workspace-to-monitor-force-assignment" = {
        "1" = "secondary";
        "2" = "secondary";
        "0" = "secondary";
      };

      mode.main.binding = {
        # Standards
        alt-enter = "exec-and-forget open -na Ghostty";
        alt-h = "focus --boundaries all-monitors-outer-frame --boundaries-action wrap-around-all-monitors left";
        alt-l = "focus --boundaries all-monitors-outer-frame --boundaries-action wrap-around-all-monitors right";

        # Resize workspaces
        alt-minus = "resize smart -50";
        alt-equal = "resize smart +50";

        # focus workspace
        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";
        alt-0 = "workspace 0";

        # Move focused window up/down/left/right
        alt-shift-h = "move left";
        alt-shift-l = "move right";

        # move focused window to workspace
        alt-shift-1 = "move-node-to-workspace 1 --focus-follows-window";
        alt-shift-2 = "move-node-to-workspace 2 --focus-follows-window";
        alt-shift-3 = "move-node-to-workspace 3 --focus-follows-window";
        alt-shift-4 = "move-node-to-workspace 4 --focus-follows-window";
        alt-shift-5 = "move-node-to-workspace 5 --focus-follows-window";
        alt-shift-6 = "move-node-to-workspace 6 --focus-follows-window";
        alt-shift-7 = "move-node-to-workspace 7 --focus-follows-window";
        alt-shift-8 = "move-node-to-workspace 8 --focus-follows-window";
        alt-shift-9 = "move-node-to-workspace 9 --focus-follows-window";
        alt-shift-0 = "move-node-to-workspace 0 --focus-follows-window";
      };
    };
  };

  services.jankyborders = {
    enable = true;
    active_color = "0xff00ffd2";
    inactive_color = "off";
    width = 7.0;
  };
}
