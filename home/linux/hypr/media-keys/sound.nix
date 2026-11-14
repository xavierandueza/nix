{ pkgs, ... }:

let
  volumeControl = pkgs.writeShellApplication {
    name = "volume-control";
    runtimeInputs = [
      pkgs.wireplumber
      pkgs.gawk
      pkgs.libnotify
    ];
    text = ''
      case "''${1:-}" in
        up) wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ ;;
        down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
        mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
        *) echo "Usage: volume-control up|down|mute" >&2; exit 1 ;;
      esac

      # Read back the actual volume, including whether the output is muted.
      state=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
      volume=$(awk '{printf "%.0f", $2 * 100}' <<< "$state")
      progress=$volume
      if [[ "$state" == *"[MUTED]"* ]]; then
        message="Muted ($volume%)"
        icon=audio-volume-muted
        progress=0
      else
        message="$volume%"
        icon=audio-volume-high
      fi
      # Other applications may have raised the volume above 100%.
      if (( progress > 100 )); then
        progress=100
      fi

      notify-send \
        --app-name=volume \
        --icon="$icon" \
        --hint=string:x-canonical-private-synchronous:volume \
        --hint=boolean:transient:true \
        --hint=int:value:"$progress" \
        "Volume" "$message"
    '';
  };
in
{
  home.packages = [ volumeControl ];

  wayland.windowManager.hyprland.extraConfig = ''
    -- Sound: default output, in 5 percentage-point steps.
    hl.bind("F1", hl.dsp.exec_cmd("${volumeControl}/bin/volume-control mute"));
    hl.bind("F2", hl.dsp.exec_cmd("${volumeControl}/bin/volume-control down"));
    hl.bind("F3", hl.dsp.exec_cmd("${volumeControl}/bin/volume-control up"));
  '';
}
