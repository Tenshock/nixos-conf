#!/bin/sh

if pgrep -lx ".wofi-wrapped"; then
  pkill "wofi"
else
  uwsm app -- $(wofi --define=drun-print_desktop_file=true)
fi
