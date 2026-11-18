{
  config,
  lib,
  pkgs,
  ...
}:

let
  plugins = import ./plugins { inherit pkgs; };

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
  # Failures only warn so a network or auth problem can't block a rebuild.
  cloneVault =
    name: vault:
    let
      path = "${config.home.homeDirectory}/${vault.target}";
    in
    ''
      if [ -e ${lib.escapeShellArg "${path}/.git"} ]; then
        remote="$(${git} -C ${lib.escapeShellArg path} remote get-url origin 2>/dev/null || true)"
        if [ "$remote" != ${lib.escapeShellArg vault.repository} ]; then
          warnEcho "Obsidian vault '${name}' has unexpected origin: $remote"
        fi
        verboseEcho "Obsidian vault '${name}' already exists"
      elif [ -e ${lib.escapeShellArg path} ]; then
        warnEcho "Cannot clone Obsidian vault '${name}': ${path} already exists and is not a Git repository"
      else
        run ${git} clone -- ${lib.escapeShellArg vault.repository} ${lib.escapeShellArg path} \
          || warnEcho "Failed to clone Obsidian vault '${name}'"
      fi
    '';
in
{
  # Must clone before linkGeneration creates the vault folders for the managed .obsidian files.
  home.activation.cloneObsidianVaults =
    lib.hm.dag.entryBetween [ "linkGeneration" "obsidian" ] [ "writeBoundary" ]
      ''
        run mkdir -p ${lib.escapeShellArg "${config.home.homeDirectory}/obsidian"}
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList cloneVault vaults)}
      '';

  programs.obsidian = {
    enable = true;
    # nix-darwin installs the app system-wide so it lands in /Applications/Nix Apps.
    package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin null;
    cli.enable = true;
    vaults = lib.mapAttrs (_: vault: { inherit (vault) target; }) vaults;
    defaultSettings = {
      app.vimMode = true;
      communityPlugins = [
        plugins.advanced-line-numbers
        {
          pkg = plugins.obsidian-git;
          settings = {
            autoPullInterval = 5;
            autoPullOnBoot = true;
            autoSaveInterval = 10;
            pullBeforePush = true;
          };
        }
      ];
    };
  };
}
