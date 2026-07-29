{
  pkgs,
  inputs,
  ...
}:

let
  herdr = inputs.llm-agents.packages.${pkgs.system}.herdr;

  pix = pkgs.writeShellApplication {
    name = "pix";
    runtimeInputs = [
      herdr
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.gnused
      pkgs.jq
    ];
    text = ''
      set -euo pipefail

      usage() {
        echo "Usage: pix [--session-id <id>] <tab-name> <message>"
        echo "       pix [--session-id=<id>] <tab-name> <message>"
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

      if [[ -z "''${HERDR_WORKSPACE_ID:-}" ]]; then
        echo "Error: pix must be run inside a Herdr workspace" >&2
        exit 1
      fi

      requested_name="''${positionals[0]}"
      message="''${positionals[1]}"

      tabs="$(herdr tab list --workspace "$HERDR_WORKSPACE_ID")"
      tab_name="$requested_name"
      suffix=2
      while jq -e --arg name "$tab_name" 'any(.result.tabs[]?; .label == $name)' <<<"$tabs" >/dev/null; do
        tab_name="$requested_name-$suffix"
        (( suffix++ ))
      done

      agent_base="$(
        printf '%s' "$tab_name" \
          | tr '[:upper:]' '[:lower:]' \
          | sed -E 's/[^a-z0-9_-]+/-/g; s/-+$//'
      )"
      if [[ ! "$agent_base" =~ ^[a-z] ]]; then
        agent_base="pi-$agent_base"
      fi
      agent_base="''${agent_base:0:32}"

      agents="$(herdr agent list)"
      agent_name="$agent_base"
      suffix=2
      while jq -e --arg name "$agent_name" \
        'any(.result.agents[]?; ((.name? // .agent_name? // "") == $name))' \
        <<<"$agents" >/dev/null; do
        suffix_text="-$suffix"
        agent_name="''${agent_base:0:$((32 - ''${#suffix_text}))}$suffix_text"
        (( suffix++ ))
      done

      created="$(
        herdr tab create \
          --workspace "$HERDR_WORKSPACE_ID" \
          --cwd "$PWD" \
          --label "$tab_name" \
          --no-focus
      )"
      tab_id="$(jq -er '.result.tab.tab_id' <<<"$created")"
      pane_id="$(jq -er '.result.root_pane.pane_id' <<<"$created")"

      cleanup() {
        status=$?
        trap - EXIT
        if [[ $status -ne 0 ]]; then
          herdr tab close "$tab_id" >/dev/null 2>&1 || true
        fi
        exit "$status"
      }
      trap cleanup EXIT

      shell_ready=false
      ready_checks=0
      for _ in {1..300}; do
        if process_info="$(herdr pane process-info --pane "$pane_id" 2>/dev/null)" \
          && jq -e '
            .result.process_info as $process
            | ($process.foreground_processes // []) as $foreground
            | ($process.shell_pid != null)
              and ($process.foreground_process_group_id == $process.shell_pid)
              and (($foreground | length) == 1)
              and ($foreground[0].pid == $process.shell_pid)
          ' <<<"$process_info" >/dev/null; then
          ready_checks=$((ready_checks + 1))
          if (( ready_checks >= 4 )); then
            shell_ready=true
            break
          fi
        else
          ready_checks=0
        fi
        sleep 0.1
      done

      if [[ "$shell_ready" != true ]]; then
        echo "Error: pane $pane_id did not reach a stable shell prompt within 30 seconds" >&2
        exit 1
      fi

      if [[ -n "$session_id" ]]; then
        herdr agent start "$agent_name" --kind pi --pane "$pane_id" -- --session-id "$session_id" >/dev/null
      else
        herdr agent start "$agent_name" --kind pi --pane "$pane_id" >/dev/null
      fi

      herdr agent prompt "$pane_id" "$message" >/dev/null
      trap - EXIT

      printf 'Started Pi agent %s in tab %s\n' "$agent_name" "$tab_name"
    '';
  };
in
{
  home.packages = [ pix ];
}
