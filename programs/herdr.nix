{
  pkgs,
  inputs,
  ...
}:
let
  herdr = inputs.llm-agents.packages.${pkgs.system}.herdr;
  tomlFormat = pkgs.formats.toml { };
in
{
  home.packages = [ herdr ];
  xdg.configFile."herdr/config.toml".source = tomlFormat.generate "herdr/config.toml" {
    theme = {
      name = "tokyo-night";
    };

    terminal = {
      new_cwd = "~/projects/";
    };

    keys = {
      prefix = "ctrl+n";
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
  };
}
