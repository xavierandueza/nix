{ inputs, ... }:

{
  # Shared global instructions across coding agents.
  home.file.".claude/CLAUDE.md".source = inputs.agents + "/AGENTS.md";
  home.file.".codex/AGENTS.md".source = inputs.agents + "/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source = inputs.agents + "/AGENTS.md";
  home.file.".pi/agent/AGENTS.md".source = inputs.agents + "/AGENTS.md";
}
