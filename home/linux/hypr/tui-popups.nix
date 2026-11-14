{ pkgs, ... }:

let
  # Runs a TUI in ghostty under the class `tui.<command>`, or focuses it if already open.
  launchOrFocusTui = pkgs.writeShellApplication {
    name = "launch-or-focus-tui";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      app_id="tui.$(basename "$1")"
      address=$(hyprctl clients -j | jq -r --arg id "$app_id" '.[] | select(.class == $id) | .address' | head -n1)

      if [ -n "$address" ]; then
        hyprctl dispatch "hl.dsp.focus({ window = \"address:$address\" })"
      else
        exec setsid ghostty --class="$app_id" -e "$@"
      fi
    '';
  };
in
{
  home.packages = [ launchOrFocusTui ];

  wayland.windowManager.hyprland.extraConfig = ''
    -- TUI popups: small floating ghostty windows centred over everything else.
    hl.window_rule({
      name = "tui-popups",
      match = { class = "^tui\\.(impala|bluetui|wiremix)$" },
      float = true,
      center = true,
      size = { 875, 600 },
    })

    hl.window_rule({
      name = "tui-popups-large",
      match = { class = "^tui\\.btm$" },
      float = true,
      center = true,
      size = { 1280, 800 },
    })

    hl.bind("SUPER + CTRL + N", hl.dsp.exec_cmd("rfkill unblock wifi; launch-or-focus-tui impala"));
    hl.bind("SUPER + CTRL + B", hl.dsp.exec_cmd("rfkill unblock bluetooth; launch-or-focus-tui bluetui"));
    hl.bind("SUPER + CTRL + A", hl.dsp.exec_cmd("launch-or-focus-tui wiremix"));
    hl.bind("SUPER + CTRL + T", hl.dsp.exec_cmd("launch-or-focus-tui btm"));
    hl.bind("SUPER + CTRL + D", hl.dsp.exec_cmd("launch-or-focus-tui lazydocker"));
  '';
}
