{
  lib,
  pkgs,
  ...
}:

{
  home.activation.agentSkills = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    export DISABLE_TELEMETRY=1
    export PATH="${lib.makeBinPath [ pkgs.nodejs_22 pkgs.git ]}:$PATH"

    install_skills() {
      source="$1"
      shift

      $DRY_RUN_CMD ${pkgs.nodejs_22}/bin/npx --yes skills@latest add "$source" \
        --global \
        --agent pi \
        --skill "$@" \
        --yes
    }

    install_skills xavierandueza/agents '*'
    install_skills xavierandueza/loops '*'
    install_skills herdrdev/herdr '*'
    install_skills langfuse/skills '*'
    install_skills microsoft/playwright-cli playwright-cli
    install_skills mattpocock/skills \
      codebase-design \
      diagnosing-bugs \
      domain-modeling \
      grill-with-docs \
      implement \
      improve-codebase-architecture \
      prototype \
      research \
      resolving-merge-conflicts \
      setup-matt-pocock-skills \
      tdd \
      to-spec \
      to-tickets \
      wayfinder \
      grill-me \
      grilling \
      handoff \
      teach \
      wait-what \
      writing-for-agents
  '';
}
