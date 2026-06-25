{ pkgs, ... }:

let
  pix = pkgs.writeShellScriptBin "pix" ''
    set -euo pipefail

    if [[ $# -ne 2 ]]; then
      echo "Usage: pix <window-name> <message>"
      echo "To directly invoke skills, start the message with '/skill:<skill-name> <other-text-instructions>'"
      exit 1
    fi

    window_name="$1"
    message="$2"

    resolve_name() {
      local base="$1"
      local candidate="$base"
      local suffix=2

      while tmux list-windows -F '#{window_name}' 2>/dev/null | grep -qx "$candidate"; do
        candidate="''${base}-''${suffix}"
        (( suffix++ ))
      done

      echo "$candidate"
    }

    resolved="$(resolve_name "$window_name")"

    tmux new-window -d -n "$resolved" -c "$PWD"
    tmux send-keys -t "$resolved" "pi" Enter
    sleep 0.5
    tmux send-keys -t "$resolved" "$message" Enter
  '';
in
{
  home.packages = [ pix ];
}
