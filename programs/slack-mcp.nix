{ pkgs, lib, ... }:
let
  slackMcpServer = import ../packages/slack-mcp-server.nix { inherit pkgs; };

  # The server registers write tools (usergroups_create, saved_update, ...) by
  # default, so allowlist the read-only ones.
  readOnlyTools = [
    "conversations_history"
    "conversations_replies"
    "conversations_search_messages"
    "conversations_unreads"
    "channels_list"
    "users_search"
    "usergroups_list"
    "saved_list"
  ];

  # Tokens live in the macOS Keychain so they never touch the nix store or disk.
  slackMcp = pkgs.writeShellApplication {
    name = "slack-mcp";
    text = ''
      keychain() {
        /usr/bin/security find-generic-password -s "$1" -w 2>/dev/null || true
      }

      xoxp="$(keychain slack-mcp-xoxp)"
      xoxc="$(keychain slack-mcp-xoxc)"
      xoxd="$(keychain slack-mcp-xoxd)"

      if [ -n "$xoxp" ]; then
        export SLACK_MCP_XOXP_TOKEN="$xoxp"
      elif [ -n "$xoxc" ] && [ -n "$xoxd" ]; then
        export SLACK_MCP_XOXC_TOKEN="$xoxc"
        export SLACK_MCP_XOXD_TOKEN="$xoxd"
      else
        echo "slack-mcp: no token in Keychain. Add slack-mcp-xoxp, or both slack-mcp-xoxc and slack-mcp-xoxd." >&2
        exit 1
      fi

      exec ${lib.getExe slackMcpServer} \
        --transport stdio \
        --enabled-tools ${lib.concatStringsSep "," readOnlyTools} \
        "$@"
    '';
  };

  piServer = {
    command = lib.getExe slackMcp;
    description = "Read-only access to Slack: search messages, read channels, threads, DMs and unreads";
  };
in
{
  home.packages = [ slackMcp ];

  # mcp.json is also edited by pi (/mcp exposure toggles) and holds other
  # servers, so merge the entry rather than own the file.
  home.activation.configurePiSlackMcp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mcpFile="''${HOME}/.pi/agent/mcp.json"
    mkdir -p "''${HOME}/.pi/agent"
    if [ ! -f "$mcpFile" ]; then
      echo '{}' > "$mcpFile"
    fi
    tempFile="$(${pkgs.coreutils}/bin/mktemp "$mcpFile.XXXXXX")"

    if ${pkgs.jq}/bin/jq \
      --argjson server '${builtins.toJSON piServer}' \
      '.mcpServers.slack = ((.mcpServers.slack // {}) + $server)' \
      "$mcpFile" > "$tempFile"; then
      ${pkgs.coreutils}/bin/mv "$tempFile" "$mcpFile"
    else
      ${pkgs.coreutils}/bin/rm "$tempFile"
      exit 1
    fi
  '';
}
