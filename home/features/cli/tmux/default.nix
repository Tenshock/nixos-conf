{ pkgs, ... }: {
  home.packages = with pkgs; [
    (writeShellScriptBin "tmux-goto-window"
      (builtins.readFile ./tmux-goto-window.sh))
    (writeShellScriptBin "tmux-track-and-clean"
      (builtins.readFile ./tmux-track-and-clean.sh))
    (writeShellScriptBin "us" (builtins.readFile ./unyka-session.sh))
  ];

  programs.tmux = {
    enable = true;
    mouse = true;
    focusEvents = true;
    baseIndex = 1;
    escapeTime = 10;
    keyMode = "vi";
    terminal = "screen-256color";

    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor "mocha"
          set -g @catppuccin_window_status_style "rounded"
          set -g @catppuccin_status_background "#0f111a"
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
      { plugin = tmuxPlugins.vim-tmux-navigator; }
    ];

    extraConfig = ''
      set-option -ga terminal-overrides ",tmux-256color:Tc"
      set-option -g status-position top
      bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel wl-copy
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "wl-copy"

      set-hook -g client-session-changed 'run-shell "tmux-track-and-clean"'
      set-hook -g session-window-changed 'run-shell "tmux-track-and-clean"'

      # AZERTY Alt+number window switch
      bind-key -n M-&  run-shell 'tmux-goto-window 1'
      bind-key -n M-2  run-shell 'tmux-goto-window 2'
      bind-key -n M-\" run-shell 'tmux-goto-window 3'
      bind-key -n M-\' run-shell 'tmux-goto-window 4'
      bind-key -n M-\( run-shell 'tmux-goto-window 5'
      bind-key -n M--  run-shell 'tmux-goto-window 6'
      bind-key -n M-7  run-shell 'tmux-goto-window 7'
      bind-key -n M-_  run-shell 'tmux-goto-window 8'
      bind-key -n M-9  run-shell 'tmux-goto-window 9'
      bind-key -n M-0  run-shell 'tmux-goto-window 10'

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
    initContent = ''
      tmux set-window-option @is_window_pristine true 2>/dev/null

      preexec() {
        if [[ -n "''${1//[[:space:]]/}" ]]; then
          tmux set-window-option @is_window_pristine false 2>/dev/null
        fi
      }
    '';
  };
}
