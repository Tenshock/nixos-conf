export HYPRLAND_GPU_PROFILE="${HYPRLAND_GPU_PROFILE:-igpu}"
export HYPRLAND_APP_PROFILE="${HYPRLAND_APP_PROFILE:-default}"

amd="/dev/dri/amd-igpu"
nvidia="/dev/dri/nvidia-egpu"

if [ "$HYPRLAND_GPU_PROFILE" = "egpu" ]; then
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    [ -e "$nvidia" ] && break
    sleep 1
  done

  if [ -e "$nvidia" ]; then
    export AQ_DRM_DEVICES="$nvidia:$amd"
  else
    export AQ_DRM_DEVICES="$amd"
  fi
elif [ -e "$nvidia" ]; then
  export AQ_DRM_DEVICES="$amd:$nvidia"
else
  export AQ_DRM_DEVICES="$amd"
fi

export AQ_FORCE_LINEAR_BLIT=0
