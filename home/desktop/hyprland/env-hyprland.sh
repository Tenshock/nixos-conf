export HYPRLAND_GPU_PROFILE="${HYPRLAND_GPU_PROFILE:-igpu}"
export HYPRLAND_APP_PROFILE="${HYPRLAND_APP_PROFILE:-default}"

amd="/dev/dri/amd-igpu"
nvidia="/dev/dri/nvidia-egpu"
nvidia_ready=0

if [ "$HYPRLAND_GPU_PROFILE" = "egpu" ] && [ -e "$amd" ]; then
  ready_checks=0

  for _ in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    if [ -e "$nvidia" ] \
      && command -v nvidia-smi >/dev/null 2>&1 \
      && timeout 3 nvidia-smi --query-gpu=name --format=csv,noheader >/dev/null 2>&1; then
      ready_checks=$((ready_checks + 1))
      if [ "$ready_checks" -ge 5 ]; then
        nvidia_ready=1
        break
      fi
    else
      ready_checks=0
    fi

    sleep 1
  done
fi

if [ -e "$amd" ] && [ -e "$nvidia" ]; then
  if [ "$HYPRLAND_GPU_PROFILE" = "egpu" ] && [ "$nvidia_ready" -eq 1 ]; then
    export AQ_DRM_DEVICES="$nvidia:$amd"
  elif [ "$HYPRLAND_GPU_PROFILE" = "egpu" ]; then
    export AQ_DRM_DEVICES="$amd"
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

if command -v systemd-cat >/dev/null 2>&1; then
  printf 'profile=%s devices=%s nvidia_ready=%s\n' \
    "$HYPRLAND_GPU_PROFILE" "${AQ_DRM_DEVICES:-automatic}" "$nvidia_ready" \
    | systemd-cat --identifier=hyprland-gpu-profile --priority=info || true
fi
