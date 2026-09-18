export HYPRLAND_GPU_PROFILE="${HYPRLAND_GPU_PROFILE:-igpu}"
export HYPRLAND_APP_PROFILE="${HYPRLAND_APP_PROFILE:-default}"

amd="/dev/dri/amd-igpu"
nvidia="/dev/dri/nvidia-egpu"

if [ "$HYPRLAND_GPU_PROFILE" = "egpu" ] && [ -e "$amd" ]; then
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    [ -e "$nvidia" ] && break
    sleep 1
  done
fi

if [ -e "$amd" ] && [ -e "$nvidia" ]; then
  if [ "$HYPRLAND_GPU_PROFILE" = "egpu" ]; then
    export AQ_DRM_DEVICES="$nvidia:$amd"
  else
    export AQ_DRM_DEVICES="$amd:$nvidia"
  fi
elif [ -e "$amd" ]; then
  export AQ_DRM_DEVICES="$amd"
elif [ -e "$nvidia" ]; then
  export AQ_DRM_DEVICES="$nvidia"
else
  # Other hosts (for example the Intel/NVIDIA ASUS) do not provide the
  # Framework-specific symlinks above. Let Aquamarine discover a KMS device.
  unset AQ_DRM_DEVICES
fi

export AQ_FORCE_LINEAR_BLIT=0
