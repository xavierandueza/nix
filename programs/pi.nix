{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  pkgs-pi = import inputs.nixpkgs-pi {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };

  # Source of truth for which pi packages should be installed.
  # Versioned specs (npm:foo@1.2.3) are pinned; pi skips them on `pi update`.
  piPackages = [
    "npm:@hypabolic/pi-hypa"
    "npm:pi-mcp-adapter"
    "npm:context-mode"
  ];

  # Emits a complete `if ...; then ... fi` block that installs `pkg` via pi
  # only if it isn't already recorded in settings.json's packages array
  # (string form or {source: pkg} object form).
  ensureInstalled = pkg: ''
    if ! ${pkgs.jq}/bin/jq -e --arg p "${pkg}" \
      '(.packages // []) | any(. == $p or (type == "object" and .source == $p))' \
      "''${HOME}/.pi/agent/settings.json" >/dev/null 2>&1; then
      $VERBOSE_ARG echo "Installing ${pkg}"
      ${pkgs-pi.pi-coding-agent}/bin/pi install "${pkg}" || \
        $VERBOSE_ARG echo "WARN: \`pi install ${pkg}\` failed (network?) — retry on next switch or \`pi update --extensions\`"
    fi
  '';
in
{
  home.packages = [ pkgs-pi.pi-coding-agent ];

  home.activation.installPiPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $VERBOSE_ARG echo "Ensuring pi packages are declared in settings.json"
    # `pi install` spawns npm, which isn't on PATH during activation.
    export PATH="${pkgs.nodejs_22}/bin:$PATH"
    mkdir -p "''${HOME}/.pi/agent"
    if [ ! -f "''${HOME}/.pi/agent/settings.json" ]; then
      echo '{}' > "''${HOME}/.pi/agent/settings.json"
    fi

    ${lib.concatMapStrings (pkg: ensureInstalled pkg) piPackages}
  '';
}
