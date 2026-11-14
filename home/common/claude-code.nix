{ pkgs, osConfig, ... }:
{
  home.sessionPath = [ "$HOME/.local/bin" ];

  # Claude Code accepts subscription setup-tokens through this environment
  # variable. Read it at launch: plaintext must never enter the Nix store.
  # Both direct `claude` invocations and pi's bridge use this wrapper.
  home.file.".local/bin/claude" = {
    executable = true;
    text = ''
      #!${pkgs.runtimeShell}
      set -eu
      unset ANTHROPIC_API_KEY ANTHROPIC_AUTH_TOKEN
      token="$(${pkgs.coreutils}/bin/cat ${osConfig.sops.secrets.claude-subscription-key.path})"
      case "$token" in
        sk-ant-oat*) ;;
        *) echo "Expected a Claude subscription setup-token, not an API key" >&2; exit 1 ;;
      esac
      export CLAUDE_CODE_OAUTH_TOKEN="$token"
      exec ${pkgs.claude-code}/bin/claude "$@"
    '';
  };
}
