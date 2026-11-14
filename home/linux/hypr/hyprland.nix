{ pkgs, ... }:

{
  home.packages = [
    pkgs.hyprshutdown
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    extraConfig = ''
      -- Application binds
      hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("ghostty"));
      hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("zen-beta"));
      hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("hyprlauncher"));
      hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" -t ppm - | satty --filename -"));

      -- General Window Binds
      hl.bind("SUPER + Q", hl.dsp.window.close());
      hl.bind("SUPER + F", hl.dsp.window.fullscreen({ action = "toggle" }));
      hl.bind("SUPER + MINUS", hl.dsp.window.resize({ x = -50, y=0, relative = true }));
      hl.bind("SUPER + EQUAL", hl.dsp.window.resize({ x = 50, y=0, relative = true }));

      -- Window Focus and Movement
      for _, item in ipairs({
        { key = "H", direction = "l" },
        { key = "J", direction = "d" },
        { key = "K", direction = "u" },
        { key = "L", direction = "r" },
      }) do
      	-- Focus
              hl.bind(
      	  "SUPER + " .. item.key,
      	  hl.dsp.focus({ direction = item.direction })
      	);

      	-- Movement
      	hl.bind(
      	  "SUPER + SHIFT + " .. item.key,
      	  hl.dsp.window.move({ direction = item.direction })
      	);

      	-- Move workspace to monitor
      	hl.bind(
      	  "SUPER + ALT + SHIFT + " .. item.key,
      	  hl.dsp.workspace.move({ monitor = item.direction })
      	);
      end

      -- Workspaces
      for i = 0, 9 do
      	local key = tostring(i);
      	local ws = i == 0 and 10 or i;

      	-- Focus workspace
      	hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = ws }));
      	
        -- Move window to workspace
      	hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = ws, follow = true }));
      end

      -- Styles
      hl.curve( "myBezier", { type = "bezier", points = { {0, 0.25}, {0.5, 1} } });
      hl.animation({ leaf = "windows", enabled = true, speed = 1.5, bezier = "myBezier", style = "popin" })
      hl.animation({ leaf = "fade", enabled = true, speed = 1.8, bezier = "myBezier" });
      hl.animation({ leaf = "workspaces", enabled = false });

      -- Scaling xwayland apps
      hl.env("GDK_SCALE", "2")
      hl.env("XCURSOR_SIZE", "32")
    '';

    settings = {
      config = {
        xwayland.force_zero_scaling = true;
        input = {
          kb_layout = "us";
          kb_variant = "colemak";
          accel_profile = "adaptive";
          repeat_delay = 250;
          repeat_rate = 50;
        };

        general = {
          border_size = 2;
          gaps_in = 5;
          gaps_out = 10;
          col = {
            active_border = "0xff86e1fc";
            inactive_border = "0xbb444a73";
          };
        };

        decoration = {
          rounding = 10;
          active_opacity = 1.0;
          inactive_opacity = 0.95;
        };

        cursor = {
          hide_on_key_press = true;
          inactive_timeout = 60;
        };

        misc = {
          middle_click_paste = false;
        };
      };
    };
  };
}
