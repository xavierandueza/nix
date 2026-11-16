{ ... }:

{
  services = {
    hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          after_sleep_cmd = "hyprctl dispatch dpms on";

        };
        listener = [
          {
            on-timeout = "loginctl lock-session";
            timeout = 600;
          }
          {
            on-resume = "hyprctl dispatch dpms on";
            on-timeout = "hyprctl dispatch dpms off";
            timeout = 1500;
          }
        ];
      };
    };
  };
}
