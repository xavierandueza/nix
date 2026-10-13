{ ... }:
{
  programs.starship = {
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
}
