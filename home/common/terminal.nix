{ pkgs, ... }:

{
  home.packages = [ pkgs.charm-freeze ];

  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      # Home Manager's own guard is a bare `return`, which leaks the failed test's
      # status as $? into non-interactive ssh commands (e.g. `ssh host exit` → 1).
      bashrcExtra = ''
        [[ $- == *i* ]] || return 0
      '';
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
      settings.git.overrideGpg = true;
    };
    lazydocker.enable = true;
  };
}
