{ ... }:

{
  services = {
    hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "hyprlock";
          after_sleep_cmd = "hyprctl dispatch dpms on";

        };
        listener = [
          {
            on-timeout = "hyprlock";
            timeout = 600;
          }
          {
            on-resume = "hyprctl dispatch dpms on";
            on-timeout = "hyprctl dispatch dpms off";
            timout = 1500;
          }
        ];
      };
    };
  };
}
