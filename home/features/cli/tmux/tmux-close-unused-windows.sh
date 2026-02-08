#!/bin/bash -e

session_id=$(tmux display-message -p '#S')

# Debounce rapid switches so we don't act on stale focus.
sleep 0.1

window_id=$(tmux display-message -p '#I')

tmux list-windows -t "$session_id" | awk -F':' '{print $1}' | while read -r idx; do
  is_window_pristine=$(tmux show-option -wqv -t "$session_id:$idx" @is_window_pristine)

  if [ "$idx" != "$window_id" ] && { [ -z "$is_window_pristine" ] || [ "$is_window_pristine" = "true" ]; }; then
    # If any pane runs a non-shell command (e.g. nvim), mark as used and keep it.
    if tmux list-panes -t "$session_id:$idx" -F "#{pane_current_command}" | awk '
      $1 !~ /^(zsh|bash|sh|dash|fish|ksh)$/ { exit 1 }
      END { exit 0 }
    '; then
      tmux kill-window -t "$session_id:$idx"
    else
      tmux set-window-option -t "$session_id:$idx" @is_window_pristine false 2>/dev/null
    fi
  fi
done
