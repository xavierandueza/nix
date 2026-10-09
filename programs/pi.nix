{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  pi = inputs.pi.packages.${pkgs.system}.default;

  # Source of truth for which pi packages should be installed.
  # Versioned specs (npm:foo@1.2.3) are pinned; pi skips them on `pi update`.
  piPackages = [
    "npm:context-mode"
    "npm:@narumitw/pi-stamp"
    "npm:@gotgenes/pi-subagents@23.2.0"
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

  # Cap model context windows for models I use
  contextLimits = {
    anthropic = {
      claude-opus-5-5.contextWindow = 250000;
      claude-haiku-5-5 = {
        contextWindow = 128000;
        reserveTokens = 8000;
      };
    };
    openai-codex = {
      "gpt-6.1-sol".contextWindow = 250000;
      gpt-6-luna = {
        contextWindow = 128000;
        reserveTokens = 8000;
      };
    };
  };

  modelOverrides = lib.mapAttrs (
    _: models: lib.mapAttrs (_: limits: { inherit (limits) contextWindow; }) models
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

  home.file.".pi/agent/pi-stamp.json".text = builtins.toJSON {
    hourCycle = "24h";
    timeZone = "Australia/Melbourne";
    toolStamps = true;
  };

  home.file.".pi/agent/subagents.json".text = builtins.toJSON {
    maxConcurrent = 25;
    defaultMaxTurns = 0;
    consumedSessionRetentionMinutes = 20160;
    unconsumedSessionRetentionMinutes = 20160;
    abortAllOnInterrupt = true;
    midRunUpdates = true;
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
    model: openai-codex/gpt-6-luna
    thinking: max
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

  home.activation.configurePiModel = lib.hm.dag.entryAfter [ "installPiPackages" ] ''
    settingsFile="''${HOME}/.pi/agent/settings.json"
    tempFile="$(${pkgs.coreutils}/bin/mktemp "$settingsFile.XXXXXX")"

    if ${pkgs.jq}/bin/jq \
      --argjson overrides '${builtins.toJSON compactionOverrides}' \
      '.defaultProvider = "anthropic"
        | .defaultModel = "claude-opus-5-5"
        | .compaction.modelOverrides = $overrides' \
      "$settingsFile" > "$tempFile"; then
      ${pkgs.coreutils}/bin/mv "$tempFile" "$settingsFile"
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
