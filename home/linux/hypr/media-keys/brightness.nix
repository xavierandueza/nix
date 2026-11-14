{ pkgs, ... }:

let
  brightnessControl = pkgs.writeShellApplication {
    name = "brightness-control";
    runtimeInputs = [
      pkgs.brightnessctl
      pkgs.gawk
      pkgs.libnotify
    ];
    text = ''
      # Target the screen backlight, not keyboard LEDs, and avoid a black screen.
      case "''${1:-}" in
        up) brightnessctl --class=backlight --min-value=1 set +5% > /dev/null ;;
        down) brightnessctl --class=backlight --min-value=1 set 5%- > /dev/null ;;
        *) echo "Usage: brightness-control up|down" >&2; exit 1 ;;
      esac

      current=$(brightnessctl --class=backlight get)
      maximum=$(brightnessctl --class=backlight max)
      brightness=$(awk -v current="$current" -v maximum="$maximum" \
        'BEGIN {printf "%.0f", current * 100 / maximum}')

      notify-send \
        --app-name=brightness \
        --icon=display-brightness \
        --hint=string:x-canonical-private-synchronous:brightness \
        --hint=boolean:transient:true \
        --hint=int:value:"$brightness" \
        "Brightness" "$brightness%"
    '';
  };
in
{
  home.packages = [ brightnessControl ];

  wayland.windowManager.hyprland.extraConfig = ''
    -- Screen brightness, in 5 percentage-point steps.
    hl.bind("F7", hl.dsp.exec_cmd("${brightnessControl}/bin/brightness-control down"));
    hl.bind("F8", hl.dsp.exec_cmd("${brightnessControl}/bin/brightness-control up"));
  '';
}
