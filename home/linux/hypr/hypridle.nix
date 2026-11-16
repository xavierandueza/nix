{ ... }:

{
  services = {
    hypridle = {
      enable = true;
      settings = {
        general = {
          # Own scope so restarting hypridle (e.g. on rebuild) doesn't kill the lock screen
          lock_cmd = "pidof hyprlock || systemd-run --user --scope hyprlock";
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
