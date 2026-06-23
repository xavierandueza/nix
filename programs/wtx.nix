{ pkgs, ... }:

let
  # Single source of truth — drives both the worktrunk config and the wtx script.
  worktreeBase = "projects/worktrees";

  wtx = pkgs.writeShellScriptBin "wtx" ''
    set -euo pipefail

    subcommand="''${1:-}"
    shift || true

    usage() {
      echo "Usage: wtx switch -c <new-branch> -b <base-branch> [-s <session-name>]"
      exit 1
    }

    case "$subcommand" in
      switch)
        session_label=""
        new_branch=""
        wt_args=()

        while [[ $# -gt 0 ]]; do
          case "$1" in
            -s) session_label="$2"; shift 2 ;;
            -c) new_branch="$2"; wt_args+=("-c" "$2"); shift 2 ;;
            *)  wt_args+=("$1"); shift ;;
          esac
        done

        if [[ -z "$new_branch" ]]; then
          echo "wtx: -c <new-branch> is required" >&2
          usage
        fi

        repo_name="$(basename "$(git rev-parse --show-toplevel)")"
        branch_slug="''${new_branch//\//-}"
        worktree_path="$HOME/${worktreeBase}/$repo_name/$branch_slug"

        if [[ -n "$session_label" ]]; then
          tmux_session="''${session_label}-''${repo_name}"
        else
          tmux_session="''${branch_slug}-''${repo_name}"
        fi

        wt switch "''${wt_args[@]}"

        if [[ -n "''${TMUX:-}" ]]; then
          tmux new-session -d -s "$tmux_session" -c "$worktree_path" 2>/dev/null || true
          tmux switch-client -t "$tmux_session"
        else
          tmux new-session -s "$tmux_session" -c "$worktree_path"
        fi
        ;;
      *)
        usage
        ;;
    esac
  '';
in
{
  home.file.".config/worktrunk/config.toml".text = ''
    worktree-path = "~/${worktreeBase}/{{ repo }}/{{ branch | sanitize }}"
    skip-shell-integration-prompt = true

    [projects]
  '';

  home.packages = [ wtx ];
}
