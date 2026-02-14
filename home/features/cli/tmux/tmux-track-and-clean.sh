#!/usr/bin/env bash
set -euo pipefail

session="$(tmux display-message -p '#S')"
client="$(tmux display-message -p '#{client_tty}')"
cur_win_id="$(tmux display-message -p '#{window_id}')"

# Per-client storage key (so two terminals don't fight)
key="@prev_win_${client//\//_}"

prev_win_id="$(tmux show -gqv "$key" || true)"
tmux set -g "$key" "$cur_win_id"

# Nothing to do first time
[ -z "${prev_win_id}" ] && exit 0
[ "$prev_win_id" = "$cur_win_id" ] && exit 0

# If previous window no longer exists, stop
tmux list-windows -t "$session" -F '#{window_id}' | grep -qx "$prev_win_id" || exit 0

# Only auto-kill windows that were auto-created by your Alt+number behavior
autocreated="$(tmux show-option -wqv -t "$prev_win_id" @autocreated || true)"
[ "$autocreated" = "true" ] || exit 0

# If marked non-pristine, keep it
pristine="$(tmux show-option -wqv -t "$prev_win_id" @is_window_pristine || true)"
[ -z "$pristine" ] && pristine="true"
[ "$pristine" = "true" ] || exit 0

# Decide if something "happened" without relying on zsh preexec:
# Keep window if any pane is running a non-shell command OR has a non-empty command line.
# pane_current_command catches obvious programs; pane_start_command catches initial.
non_shell="$(
  tmux list-panes -t "$prev_win_id" -F '#{pane_current_command} #{pane_start_command}' |
    awk '
    {
      cmd=$1
      # treat shells as empty
      if (cmd ~ /^(zsh|bash|sh|dash|fish|ksh)$/) next
      exit 1
    }
    END{ exit 0 }
  ' && echo "no" || echo "yes"
)"

if [ "$non_shell" = "yes" ]; then
  tmux set-window-option -t "$prev_win_id" @is_window_pristine false >/dev/null 2>&1 || true
  exit 0
fi

# Otherwise kill it
tmux kill-window -t "$prev_win_id"
