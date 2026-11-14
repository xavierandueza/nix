{ pkgs, osConfig, ... }:

{
  home.packages = [
    pkgs.bluetui
    pkgs.charm-freeze
  ];

  programs = {
    impala.enable = true;

    ghostty = {
      enable = true;
      clearDefaultKeybinds = true; # Never use them

      settings = {
        font-size = 10;
        theme = "TokyoNight Moon";
        clipboard-read = "allow";
        keybind = [
          "ctrl+shift+c=copy_to_clipboard"
          "ctrl+shift+v=paste_from_clipboard"
          "ctrl+shift+comma=reload_config"
        ];
      };
    };

    bash = {
      enable = true;
      enableCompletion = true;
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      options = [
        "--cmd"
        "cd"
      ];
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
      # Hide status lines (loading, export diff); errors bypass the filter.
      config.global.log_filter = "^$";
    };

    ripgrep.enable = true;
    bottom.enable = true;

    atuin = {
      enable = true;
      enableBashIntegration = true;
      daemon.enable = true;
      settings = {
        enter_accept = true;
      };
    };

    starship = {
      enable = true;
      enableBashIntegration = true;
      settings = {
        add_newline = false;
        command_timeout = 200;
        format = "[$directory$git_branch$git_status]($style)\n$character";
        character = {
          success_symbol = "[❯](bold purple)";
          error_symbol = "[✗](bold purple)";
        };
        directory = {
          truncation_length = 2;
          truncation_symbol = "../";
          read_only = " 󰍁";
          read_only_style = "cyan";
          repo_root_style = "bold cyan";
          repo_root_format = "[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) ";
        };
        git_branch = {
          format = "[$branch]($style) ";
          style = "italic cyan";
        };
        git_status = {
          format = "[$all_status]($style)";
          style = "cyan";
          ahead = "\${count} ";
          diverged = "󰹹\${count} \${behind_count} ";
          behind = "\${count}";
          conflicted = " ";
          up_to_date = " ";
          modified = " ";
          stashed = "";
          staged = "";
          renamed = "";
          deleted = "";
        };
      };
    };

    gh.enable = true;
    lazygit = {
      enable = true;
      enableBashIntegration = true;
    };
    docker-cli = {
      enable = true;
      contexts.rootless.Endpoints.docker.Host =
        "unix:///run/user/${toString osConfig.users.users.xavier.uid}/docker.sock";
      settings.currentContext = "rootless";
    };
    lazydocker.enable = true;
    wiremix.enable = true;
  };
}
