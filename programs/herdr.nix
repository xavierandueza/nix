{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let
  herdr = config.programs.herdr.package;
in
{
  programs.herdr = {
    enable = true;
    package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr;

    settings = {
      onboarding = false;

      theme = {
        name = "terminal";
        custom.panel_bg = "black";
      };

      terminal.new_cwd = "follow";

      keys = {
        prefix = "ctrl+space";
        reload_config = "prefix+q";
        help = "prefix+?";
        detach = "prefix+d";
        copy_mode = "prefix+[";

        split_horizontal = "prefix+-";
        split_vertical = "prefix+v";
        close_pane = "prefix+x";
        last_pane = "prefix+;";
        focus_pane_left = "prefix+h";
        focus_pane_down = "prefix+j";
        focus_pane_up = "prefix+k";
        focus_pane_right = "prefix+l";

        new_tab = "prefix+c";
        rename_tab = "prefix+shift+t";
        switch_tab = "prefix+1..9";
        previous_tab = "alt+left";
        next_tab = "alt+right";

        new_workspace = "prefix+shift+c";
        rename_workspace = "prefix+shift+w";
        close_workspace = "prefix+shift+d";
        previous_workspace = "alt+k";
        next_workspace = "alt+j";
        navigate_workspace_up = "k";
        navigate_workspace_down = "j";

        next_agent = "shift+alt+j";
        previous_agent = "shift+alt+k";
        focus_agent = "shift+alt+1..9";

        command =
          map
            (binding: {
              key = "ctrl+alt+shift+${binding.key}";
              type = "shell";
              command = "herdr pane resize --current --direction ${binding.direction} --amount 0.05";
            })
            [
              {
                key = "h";
                direction = "left";
              }
              {
                key = "j";
                direction = "down";
              }
              {
                key = "k";
                direction = "up";
              }
              {
                key = "l";
                direction = "right";
              }
            ]
          ++ [
            {
              key = "ctrl+shift+g";
              type = "popup";
              command = ''root="$(git -C "''${HERDR_ACTIVE_PANE_CWD:-$PWD}" rev-parse --show-toplevel 2>/dev/null || printf '%s' "''${HERDR_ACTIVE_PANE_CWD:-$PWD}")"; cd "$root" && exec lazygit'';
              description = "Open lazygit";
              width = "90%";
              height = "90%";
            }
          ];
      };

      ui = {
        accent = "blue";
        pane_gaps = true;
        pane_borders = true;
        pane_scrollbars = false;
        confirm_close = true;
        prompt_new_tab_name = true;
        mouse_capture = true;
        sound.enabled = true;
      };
    };
  };

  home.activation.installHerdrPiIntegration =
    lib.hm.dag.entryAfter
      [
        "writeBoundary"
        "installPiPackages"
      ]
      ''
        $VERBOSE_ARG echo "Installing Herdr Pi integration"
        run ${lib.getExe herdr} integration install pi
      '';

  # The home-manager module has no plugin option; linking a pinned store path is idempotent.
  home.activation.linkHerdrPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${lib.getExe herdr} plugin link ${inputs.herdr-worktreeinclude} >/dev/null
  '';
}
