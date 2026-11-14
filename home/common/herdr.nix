{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  herdr = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr;
  toml = pkgs.formats.toml { };
  herdrNotRunning = pkgs.writeShellScript "herdr-not-running" ''
    ! ${herdr}/bin/herdr status server | ${pkgs.gnugrep}/bin/grep -q '^status: running'
  '';
in
{
  home.packages = [ herdr ];

  # Keeps the default session alive across logouts and reboots so remote machines can attach.
  systemd.user.services.herdr = {
    Unit = {
      Description = "Herdr server";
      # Restarting on rebuild would kill every pane; restart manually after a Herdr upgrade.
      X-RestartIfChanged = false;
    };
    Service = {
      # Skip, rather than fail, when a TUI-started server already owns the session.
      ExecCondition = "${herdrNotRunning}";
      ExecStart = "${herdr}/bin/herdr server";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Run after the write boundary, and after Pi packages once that module is imported.
  home.activation.installHerdrPiIntegration =
    lib.hm.dag.entryAfter
      [
        "writeBoundary"
        "installPiPackages"
      ]
      ''
        echo "Installing Herdr Pi integration"
        run ${herdr}/bin/herdr integration install pi
      '';

  xdg.configFile."herdr/config.toml".source = toml.generate "herdr-config.toml" {
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
            # Popups skip shell init, so load the repo's direnv env for git hooks.
            command = ''root="$(git -C "''${HERDR_ACTIVE_PANE_CWD:-$PWD}" rev-parse --show-toplevel 2>/dev/null || printf '%s' "''${HERDR_ACTIVE_PANE_CWD:-$PWD}")"; cd "$root" && exec env DIRENV_LOG_FORMAT= direnv exec "$root" lazygit'';
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
      toast = {
        delivery = "system";
        delay_seconds = 1;
      };
    };
  };
}
