#!/usr/bin/env bash
set -euo pipefail

target="${1:?window index required}"

session="$(tmux display-message -p '#S')"

# If window index doesn't exist, create it and mark it autocreated+pristine
if ! tmux list-windows -t "$session" -F '#I' | grep -qx "$target"; then
  tmux new-window -t "${session}:${target}" -c "#{pane_current_path}" >/dev/null
  tmux set-window-option -t "${session}:${target}" @autocreated true
  tmux set-window-option -t "${session}:${target}" @is_window_pristine true
fi

tmux select-window -t "${session}:${target}"
