{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let
  pi = inputs.pi.packages.${pkgs.system}.default;

  piPackages = [
    "npm:context-mode"
    "npm:@narumitw/pi-stamp"
    "npm:@gotgenes/pi-subagents@23.2.0"
    "npm:pi-claude-bridge"
  ];

  # Extension tools require explicit names; only MCP entries support wildcards.
  subagentTools = [
    "read"
    "bash"
    "edit"
    "write"
    "grep"
    "find"
    "ls"
    "codemode"
    "tool_search"
    "mcp__*"
    "list_mcp_resources"
    "list_mcp_resource_templates"
    "read_mcp_resource"
    "ctx_execute"
    "ctx_execute_file"
    "ctx_index"
    "ctx_search"
    "ctx_fetch_and_index"
    "ctx_batch_execute"
    "ctx_stats"
    "ctx_doctor"
    "ctx_upgrade"
    "ctx_purge"
    "ctx_insight"
  ];

  # Hard per-response output cap. Reserve covers it, pi's 4096-token request
  # safety margin, and slack for pi's token estimate running low.
  outputLimits = rec {
    maxTokens = 32000;
    reserveTokens = maxTokens + 4096 + 8192;
  };

  mainLimits = outputLimits // {
    contextWindow = 320000;
  };

  workerLimits = outputLimits // {
    contextWindow = 175000;
  };

  # Cap model context windows for models I use
  contextLimits = {
    claude-bridge = {
      claude-opus-5-5 = mainLimits;
      claude-haiku-5-5 = workerLimits;
    };
    openai-codex = {
      # Codex's real window is 272K, so it can't share Opus's 320K cap.
      "gpt-6.1-sol" = mainLimits // {
        contextWindow = 272000;
      };
      gpt-6-luna = workerLimits;
    };
  };

  modelOverrides = lib.mapAttrs (
    _: models: lib.mapAttrs (_: limits: removeAttrs limits [ "reserveTokens" ]) models
  ) contextLimits;

  compactionOverrides = lib.concatMapAttrs (
    provider: models:
    lib.mapAttrs' (
      model: limits:
      lib.nameValuePair "${provider}/${model}" {
        inherit (limits) reserveTokens;
      }
    ) (lib.filterAttrs (_: limits: limits ? reserveTokens) models)
  ) contextLimits;

  childAgentInstructions = ''
    You are a child agent working on a task delegated by a parent agent.
    You cannot spawn or manage other subagents. Complete the task yourself;
    if additional delegation is needed, use ask_parent to request it.
    Use notify_parent for progress updates.
  '';

  # Emits a complete `if ...; then ... fi` block that installs `pkg` via pi
  # only if it isn't already recorded in settings.json's packages array
  # (string form or {source: pkg} object form).
  ensureInstalled = pkg: ''
    if ! ${pkgs.jq}/bin/jq -e --arg p "${pkg}" \
      '(.packages // []) | any(. == $p or (type == "object" and .source == $p))' \
      "''${HOME}/.pi/agent/settings.json" >/dev/null 2>&1; then
      $VERBOSE_ARG echo "Installing ${pkg}"
      ${pi}/bin/pi install "${pkg}" || \
        $VERBOSE_ARG echo "WARN: \`pi install ${pkg}\` failed (network?) — retry on next switch or \`pi update --extensions\`"
    fi
  '';
in
{
  home.packages = [ pi ];

  # The bridge ignores Pi's maxTokens; enforce the cap in Claude Code instead.
  home.file.".pi/agent/bin/claude-bridge" = {
    executable = true;
    text = ''
      #!${pkgs.runtimeShell}
      set -eu
      export CLAUDE_CODE_MAX_OUTPUT_TOKENS=${toString outputLimits.maxTokens}
      exec ${lib.escapeShellArg "${config.home.homeDirectory}/.local/bin/claude"} "$@"
    '';
  };

  home.file.".pi/agent/pi-stamp.json".text = builtins.toJSON {
    hourCycle = "24h";
    timeZone = "Australia/Melbourne";
    toolStamps = true;
  };

  home.file.".pi/agent/keybindings.json".text = builtins.toJSON {
    "tui.input.submit" = "ctrl+enter";
    "tui.input.newLine" = [
      "enter"
      "shift+enter"
      "ctrl+j"
    ];
  };

  home.file.".pi/agent/subagents.json".text = builtins.toJSON {
    maxConcurrent = 25;
    defaultMaxTurns = 0;
    consumedSessionRetentionMinutes = 20160;
    unconsumedSessionRetentionMinutes = 20160;
    abortAllOnInterrupt = true;
    midRunUpdates = true;
    promptInheritance.claude-bridge = "portable";
  };

  home.file.".pi/agent/agents/general-purpose.md".text = ''
    ---
    description: General-purpose agent for complex, multi-step tasks
    display_name: Agent
    tools: ${builtins.toJSON subagentTools}
    prompt_mode: append
    inherit_context: false
    ---
    ${childAgentInstructions}
  '';

  home.file.".pi/agent/agents/Explore.md".text = ''
    ---
    description: Codebase exploration and understanding
    display_name: Explore
    tools: ${builtins.toJSON subagentTools}
    model: claude-bridge/claude-haiku-5-5
    thinking: xhigh
    prompt_mode: append
    inherit_context: false
    ---
    ${childAgentInstructions}

    You are a codebase exploration specialist. Search and analyse existing code,
    leaving project files unchanged. Follow inherited tool guidance, adapt your
    thoroughness to the task, and report findings with absolute file paths.
  '';

  home.file.".pi/agent/agents/Plan.md".text = ''
    ---
    enabled: false
    ---
  '';

  # Remove the former native-provider credential. Subscription auth now belongs
  # exclusively to Claude Code; preserve OpenAI and other local credentials.
  home.activation.removePiAnthropicAuth = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.writeShellScript "remove-pi-anthropic-auth" ''
      set -eu
      umask 077
      authFile="$HOME/.pi/agent/auth.json"
      [ -f "$authFile" ] || exit 0
      tempFile="$(${pkgs.coreutils}/bin/mktemp "$authFile.XXXXXX")"
      trap '${pkgs.coreutils}/bin/rm -f "$tempFile"' EXIT

      authJson="$(${pkgs.jq}/bin/jq \
        'if type != "object" then error("pi auth must be an object") else . end
         | del(.anthropic)' "$authFile")"
      printf '%s\n' "$authJson" > "$tempFile"
      ${pkgs.coreutils}/bin/chmod 0600 "$tempFile"
      ${pkgs.coreutils}/bin/mv -f "$tempFile" "$authFile"
    ''}
  '';

  home.activation.configurePiModel = lib.hm.dag.entryAfter [ "installPiPackages" ] ''
    settingsFile="''${HOME}/.pi/agent/settings.json"
    tempFile="$(${pkgs.coreutils}/bin/mktemp "$settingsFile.XXXXXX")"

    if ${pkgs.jq}/bin/jq \
      --argjson overrides '${builtins.toJSON compactionOverrides}' \
      '.defaultProvider = "claude-bridge"
        | .defaultModel = "claude-opus-5-5"
        | .defaultThinkingLevel = "high"
        | .compaction.modelOverrides = $overrides' \
      "$settingsFile" > "$tempFile"; then
      ${pkgs.coreutils}/bin/mv "$tempFile" "$settingsFile"
    else
      ${pkgs.coreutils}/bin/rm "$tempFile"
      exit 1
    fi
  '';

  home.activation.configurePiClaudeBridge = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    bridgeFile="''${HOME}/.pi/agent/claude-bridge.json"
    mkdir -p "''${HOME}/.pi/agent"
    if [ ! -f "$bridgeFile" ]; then
      echo '{}' > "$bridgeFile"
    fi
    tempFile="$(${pkgs.coreutils}/bin/mktemp "$bridgeFile.XXXXXX")"

    if ${pkgs.jq}/bin/jq \
      --arg executable "''${HOME}/.pi/agent/bin/claude-bridge" \
      '.provider.plan = "pro"
        | .provider.longContextExtraUsage = false
        | .provider.pathToClaudeCodeExecutable = $executable
        | .askClaude.enabled = false' \
      "$bridgeFile" > "$tempFile"; then
      ${pkgs.coreutils}/bin/mv "$tempFile" "$bridgeFile"
    else
      ${pkgs.coreutils}/bin/rm "$tempFile"
      exit 1
    fi
  '';

  # models.json also holds hand-added custom models, so merge rather than own it.
  home.activation.configurePiModelLimits = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    modelsFile="''${HOME}/.pi/agent/models.json"
    mkdir -p "''${HOME}/.pi/agent"
    if [ ! -f "$modelsFile" ]; then
      echo '{}' > "$modelsFile"
    fi
    tempFile="$(${pkgs.coreutils}/bin/mktemp "$modelsFile.XXXXXX")"

    if ${pkgs.jq}/bin/jq \
      --argjson overrides '${builtins.toJSON modelOverrides}' \
      'reduce ($overrides | to_entries[]) as $p (.;
        .providers[$p.key].modelOverrides = $p.value)' \
      "$modelsFile" > "$tempFile"; then
      ${pkgs.coreutils}/bin/mv "$tempFile" "$modelsFile"
    else
      ${pkgs.coreutils}/bin/rm "$tempFile"
      exit 1
    fi
  '';

  home.activation.installPiPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $VERBOSE_ARG echo "Ensuring pi packages are declared in settings.json"
    # `pi install` spawns npm, which isn't on PATH during activation.
    export PATH="${pkgs.nodejs_22}/bin:$PATH"
    mkdir -p "''${HOME}/.pi/agent/extensions"
    if [ ! -f "''${HOME}/.pi/agent/settings.json" ]; then
      echo '{}' > "''${HOME}/.pi/agent/settings.json"
    fi

    ${lib.concatMapStrings (pkg: ensureInstalled pkg) piPackages}

  '';
}
