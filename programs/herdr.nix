{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  herdr = inputs.llm-agents.packages.${pkgs.system}.herdr;
  tomlFormat = pkgs.formats.toml { };
in
{
  home.packages = [ herdr ];

  # Install the herdr pi integration
  home.activation.installHerdrPiIntegration = lib.hm.dag.entryAfter [ "installPiPackages" ] ''
    $VERBOSE_ARG echo "Installing Herdr Pi integration"
    ${herdr}/bin/herdr integration install pi
  '';

  # Yaml config setup
  xdg.configFile."herdr/config.toml".source = tomlFormat.generate "herdr/config.toml" {
    theme = {
      name = "tokyo-night";
    };

    terminal = {
      new_cwd = "follow";
    };

    keys = {
      prefix = "ctrl+n";
      navigate_workspace_up = "k";
      navigate_workspace_down = "j";
    };

    ui = {
      # Default width, scales based on workspace names
      sidebar_width = 26;

      # Minimum sidebar width when expanded (columns)
      sidebar_min_width = 18;

      # Maximum sidebar width when expanded (columns)
      sidebar_max_width = 36;

      pane_gaps = true;

      mouse_capture = true;
    };

    worktrees = {
      directory = "~/projects/worktrees/";
    };
  };
}
