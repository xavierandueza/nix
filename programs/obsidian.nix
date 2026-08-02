{
  config,
  lib,
  ...
}:

let
  vaults = {
    personal = {
      target = "obsidian/personal";
      repository = "https://github.com/xavierandueza/personal-vault.git";
    };
    work = {
      target = "obsidian/work";
      repository = "https://github.com/xavierandueza/work-vault.git";
    };
  };

  git = lib.getExe config.programs.git.package;
  cloneVault =
    name: vault:
    let
      path = "${config.home.homeDirectory}/${vault.target}";
    in
    ''
      if [ -e ${lib.escapeShellArg "${path}/.git"} ]; then
        remote="$(${git} -C ${lib.escapeShellArg path} remote get-url origin 2>/dev/null || true)"
        if [ "$remote" != ${lib.escapeShellArg vault.repository} ]; then
          echo "Obsidian vault '${name}' has unexpected origin: $remote" >&2
          exit 1
        fi
        verboseEcho "Obsidian vault '${name}' already exists"
      elif [ -e ${lib.escapeShellArg path} ]; then
        echo "Cannot clone Obsidian vault '${name}': ${path} already exists and is not a Git repository" >&2
        exit 1
      else
        run ${git} clone -- ${lib.escapeShellArg vault.repository} ${lib.escapeShellArg path}
      fi
    '';
in
{
  home.activation.cloneObsidianVaults = lib.hm.dag.entryBetween [ "obsidian" ] [ "writeBoundary" ] ''
    run mkdir -p ${lib.escapeShellArg "${config.home.homeDirectory}/obsidian"}
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList cloneVault vaults)}
  '';

  programs.obsidian = {
    enable = true;
    package = null;
    cli.enable = true;
    vaults = lib.mapAttrs (_: vault: { inherit (vault) target; }) vaults;
  };
}
