{ pkgs, ... }:

let
  # Single source of truth — drives both the worktrunk config and the wtx script.
  worktreeBase = "projects/worktrees";

  wtx = pkgs.writeShellScriptBin "wtx" ''
    set -euo pipefail

    subcommand="''${1:-}"
    shift || true

    usage() {
      echo "Usage: wtx switch <branch> [-s <session-name>]"
      echo "       wtx switch -c <new-branch> [-b <base-branch>] [-s <session-name>]"
      echo "       wtx remove [<branch>...] [--force] [--force-delete] [--no-delete-branch]"
      exit 1
    }

    case "$subcommand" in
      switch)
        session_label=""
        branch=""
        wt_args=()

        while [[ $# -gt 0 ]]; do
          case "$1" in
            -s) session_label="$2"; shift 2 ;;
            -c) branch="$2"; wt_args+=("-c" "$2"); shift 2 ;;
            *)
              if [[ -z "$branch" && "$1" != -* ]]; then
                branch="$1"
              fi
              wt_args+=("$1")
              shift
              ;;
          esac
        done

        if [[ -z "$branch" ]]; then
          echo "wtx: a branch name is required" >&2
          usage
        fi

        repo_name="$(basename "$(git rev-parse --show-toplevel)")"
        branch_slug="''${branch//\//-}"
        worktree_path="$HOME/${worktreeBase}/$repo_name/$branch_slug"

        tmux_session="''${session_label:-$branch_slug}-''${repo_name}"

        wt switch "''${wt_args[@]}"

        if [[ -n "''${TMUX:-}" ]]; then
          tmux new-session -d -s "$tmux_session" -c "$worktree_path" 2>/dev/null || true
          tmux switch-client -t "$tmux_session"
        else
          tmux new-session -s "$tmux_session" -c "$worktree_path"
        fi
        ;;
      remove)
        wt remove "$@"
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

    [pre-start]
    copy-ignored = "wt step copy-ignored"

    [post-remove]
    kill-tmux = "tmux list-sessions -F '#{session_name} #{session_path}' 2>/dev/null | awk '$2 == "{{ worktree_path }}" {print $1}' | xargs -I{} tmux kill-session -t {} 2>/dev/null || true"

    [projects]
  '';

  home.packages = [ wtx ];
}
