{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    mouse = true;
    focusEvents = true;
    baseIndex = 1;
    newSession = true;

    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor "mocha"
          set -g @catppuccin_window_status_style "rounded"
          set -q @catppuccin_status_background "#0f111a"
          set -g @catppuccin_window_current_number_color "#{@thm_teal}"
          set -q @catppuccin_pane_color "#{@thm_teal}"

          set -g status-right-length 100
          set -g status-left-length 100
          set -g status-left ""
          set -g status-right "#{E:@catppuccin_status_application}"
          set -ag status-right "#{E:@catppuccin_status_session}"
          set -ag status-right "#{E:@catppuccin_status_user}"
        '';
      }
      {
        plugin = tmuxPlugins.vim-tmux-navigator;
      }
    ];

    extraConfig = ''
      set-option -g status-position top

      # AZERTY Alt+number window switch
      bind-key -n M-&  run-shell 'if ! tmux list-windows | cut -d: -f1 | grep -q "^1$"; then tmux new-window -t 1; fi; tmux select-window -t 1'
      bind-key -n M-2  run-shell 'if ! tmux list-windows | cut -d: -f1 | grep -q "^2$"; then tmux new-window -t 2; fi; tmux select-window -t 2'
      bind-key -n M-\" run-shell 'if ! tmux list-windows | cut -d: -f1 | grep -q "^3$"; then tmux new-window -t 3; fi; tmux select-window -t 3'
      bind-key -n M-\' run-shell 'if ! tmux list-windows | cut -d: -f1 | grep -q "^4$"; then tmux new-window -t 4; fi; tmux select-window -t 4'
      bind-key -n M-\( run-shell 'if ! tmux list-windows | cut -d: -f1 | grep -q "^5$"; then tmux new-window -t 5; fi; tmux select-window -t 5'
      bind-key -n M--  run-shell 'if ! tmux list-windows | cut -d: -f1 | grep -q "^6$"; then tmux new-window -t 6; fi; tmux select-window -t 6'
      bind-key -n M-7  run-shell 'if ! tmux list-windows | cut -d: -f1 | grep -q "^7$"; then tmux new-window -t 7; fi; tmux select-window -t 7'
      bind-key -n M-_  run-shell 'if ! tmux list-windows | cut -d: -f1 | grep -q "^8$"; then tmux new-window -t 8; fi; tmux select-window -t 8'
      bind-key -n M-9  run-shell 'if ! tmux list-windows | cut -d: -f1 | grep -q "^9$"; then tmux new-window -t 9; fi; tmux select-window -t 9'
      bind-key -n M-0  run-shell 'if ! tmux list-windows | cut -d: -f1 | grep -q "^10$"; then tmux new-window -t 10; fi; tmux select-window -t 10'

      # Alt pane kill
      bind-key -n M-w kill-pane

      # More intuitive pane split bind
      bind-key -n M-h split-window -h # h for horizontal split
      bind-key -n M-H split-window -h -p 30 # h for horizontal split
      bind-key -n M-v split-window -v # v for vertical split
      bind-key -n M-V split-window -v -p 30 # v for vertical split

      # Alt+arrow pane resize
      bind-key -n M-Up              resize-pane -U 5
      bind-key -n M-Down            resize-pane -D 5
      bind-key -n M-Left            resize-pane -L 5
      bind-key -n M-Right           resize-pane -R 5
    '';
  };

  programs.zsh = {
    envExtra = ''
      export ZSH_TMUX_AUTOSTART=true
      export ZSH_TMUX_AUTOCONNECT=false
    '';
  };
}
