_: {
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    keyMode = "vi";
    mouse = true;
    terminal = "tmux-256color";
    extraConfig = ''
      set -g allow-passthrough on
      set -s extended-keys on
      set -as terminal-features 'xterm*:extkeys'

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
  };
}
