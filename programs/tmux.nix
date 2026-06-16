{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    prefix = "C-n";
    keyMode = "vi";
    mouse = true;
    terminal = "tmux-256color";
    extraConfig = ''
      set -g allow-passthrough on
      set -s extended-keys on
      set -as terminal-features 'xterm*:extkeys'

      # Throttle status-bar refresh so the git/battery widgets don't spawn
      # subprocesses every second.
      set -g status-interval 5

      # prefix + S: lay out a standard set of named windows in the CURRENT session,
      # all rooted at the triggering pane's cwd. Renames the current window to nvim
      # (so you get indices 0-3) then adds the rest. Run it in a fresh session.
      bind S \
        rename-window nvim \;\
        new-window -n agent  -c "#{pane_current_path}" \;\
        new-window -n bash   -c "#{pane_current_path}" \;\
        new-window -n server -c "#{pane_current_path}" \;\
        select-window -t nvim

      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded"

      # vi-style pane navigation: prefix + h/j/k/l
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Copy-mode selection highlight
      set -g mode-style "bg=#283457,fg=#c0caf5"
      # Search match highlighting in copy mode
      set -g copy-mode-match-style "bg=#3d59a1,fg=#c0caf5"
      set -g copy-mode-current-match-style "bg=#7aa2f7,fg=#1a1b26"

      # vim-style copy: v to start selecting, y to yank to the macOS clipboard.
      # The display-message gives a brief "Copied" flash as confirmation, since
      # copy mode exits on yank (tmux has no highlight-on-yank like Neovim).
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "pbcopy" \; display-message "Copied to clipboard"
    '';
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = tokyo-night-tmux;
        # Options are read when the plugin's run-shell executes, so they must be
        # set here (emitted right before it) rather than in the main extraConfig.
        extraConfig = ''
          set -g @tokyo-night-tmux_theme night
          set -g @tokyo-night-tmux_transparent 0

          set -g @tokyo-night-tmux_window_id_style digital
          set -g @tokyo-night-tmux_pane_id_style hsquare

          set -g @tokyo-night-tmux_show_path 1
          set -g @tokyo-night-tmux_path_format relative

          set -g @tokyo-night-tmux_show_git 1

          set -g @tokyo-night-tmux_show_battery_widget 1

          # Disabled to keep the bar uncluttered.
          set -g @tokyo-night-tmux_show_netspeed 0
          set -g @tokyo-night-tmux_show_music 0
          set -g @tokyo-night-tmux_show_hostname 1
        '';
      }
    ];
  };
}
