{
  lib,
  pkgs,
  ...
}:

{
  home.activation.agentSkills = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    export DISABLE_TELEMETRY=1
    export PATH="${
      lib.makeBinPath [
        pkgs.nodejs_22
        pkgs.git
        pkgs.gh
      ]
    }:$PATH"

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
    install_skills herdrdev/herdr herdr
    install_skills langfuse/skills '*'
    install_skills microsoft/playwright-cli playwright-cli
    install_skills readmeio/skills thermo-nuclear-code-quality-review
    install_skills 'readmeio/skills#xavier/rm-19777-validation-slot-skill' validation-slot
    install_skills cursor/plugins \
      create-verification-skill \
      maintain-verification-skill
    install_skills mattpocock/skills \
      diagnosing-bugs \
      domain-modeling \
      grill-with-docs \
      implement \
      prototype \
      research \
      tdd \
      to-spec \
      to-tickets \
      wayfinder \
      grilling \
      writing-for-agents
  '';
}
