#!/bin/sh

if pgrep -lx ".wofi-wrapped"; then
  pkill "wofi"
else
  CHOICE=$(echo -e "  Lock\n  Logout\n  Reboot\n  Shutdown\n  Suspend\n  Hibernate" | wofi --dmenu --width 250 --height 215)

  lock_and_execute() {
    hyprlock &
    sleep 1
    $1
  }

  case "$CHOICE" in
  "  Lock") hyprlock ;;
  "  Logout") hyprctl dispatch exit ;;
  "  Reboot") systemctl reboot ;;
  "  Shutdown") systemctl poweroff ;;
  "  Suspend") lock_and_execute "systemctl suspend" ;;
  "  Hibernate") lock_and_execute "systemctl hibernate" ;;
  esac
fi
