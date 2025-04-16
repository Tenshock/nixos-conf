#!/bin/sh

if pgrep -lx ".wofi-wrapped"; then
  pkill "wofi"
else
  CHOICE=$(echo -e "  Lock\n  Logout\n  Reboot\n  Shutdown\n  Suspend\n  Hibernate" | wofi --dmenu --width 250 --height 223)

  case "$CHOICE" in
  "  Lock") hyprlock ;;
  "  Logout") hyprctl dispatch exit ;;
  "  Reboot") systemctl reboot ;;
  "  Shutdown") systemctl poweroff ;;
  "  Suspend") systemctl suspend-then-hibernate ;;
  "  Hibernate") systemctl hibernate ;;
  esac
fi
