#!/bin/bash -e

session_id=$(tmux display-message -p '#S')
window_id=$(tmux display-message -p '#I')

tmux list-windows -t $session_id | awk -F':' '{print $1}' | while read -r idx; do
  is_window_pristine=$(tmux show-option -wqv -t $session_id:$idx @is_window_pristine)
  if [ $idx != $window_id ] && ([ -z $is_window_pristine ] || [ $is_window_pristine = "true" ]); then
    tmux kill-window -t $session_id:$idx
  fi
done
