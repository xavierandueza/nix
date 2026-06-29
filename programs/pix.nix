{ pkgs, ... }:

let
  pix = pkgs.writeShellScriptBin "pix" ''
    set -euo pipefail

    usage() {
      echo "Usage: pix [--session-id <id>] <window-name> <message>"
      echo "       pix [--session-id=<id>] <window-name> <message>"
      echo "To directly invoke skills, start the message with '/skill:<skill-name> <other-text-instructions>'"
    }

    session_id=""
    positionals=()

    while [[ $# -gt 0 ]]; do
      case "$1" in
        --session-id)
          if [[ $# -lt 2 || -z "''${2:-}" ]]; then
            echo "Error: --session-id requires a value" >&2
            usage
            exit 1
          fi
          session_id="$2"
          shift 2
          ;;
        --session-id=*)
          session_id="''${1#--session-id=}"
          if [[ -z "$session_id" ]]; then
            echo "Error: --session-id requires a value" >&2
            usage
            exit 1
          fi
          shift
          ;;
        --)
          shift
          while [[ $# -gt 0 ]]; do
            positionals+=("$1")
            shift
          done
          ;;
        -*)
          echo "Error: unknown option: $1" >&2
          usage
          exit 1
          ;;
        *)
          positionals+=("$1")
          shift
          ;;
      esac
    done

    if [[ ''${#positionals[@]} -ne 2 ]]; then
      usage
      exit 1
    fi

    window_name="''${positionals[0]}"
    message="''${positionals[1]}"

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

    pi_cmd=(pi)
    if [[ -n "$session_id" ]]; then
      pi_cmd+=(--session-id "$session_id")
    fi
    pi_command="$(printf '%q ' "''${pi_cmd[@]}")"

    tmux new-window -d -n "$resolved" -c "$PWD"
    tmux send-keys -t "$resolved" "$pi_command" Enter
    sleep 1
    tmux send-keys -t "$resolved" "$message"
    sleep 0.3
    tmux send-keys -t "$resolved" Enter
  '';
in
{
  home.packages = [ pix ];
}
