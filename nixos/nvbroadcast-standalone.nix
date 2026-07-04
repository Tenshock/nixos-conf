{ config, pkgs, ... }:
let
  # See https://github.com/Hkshoonya/nvidia-broadcast-linux
  sourceVersion = "v1.1.12";
  nvidiaBroadcastLinuxSrc = pkgs.fetchFromGitHub {
    owner = "Hkshoonya";
    repo = "nvidia-broadcast-linux";
    rev = sourceVersion;
    hash = "sha256-enLn5qB82SysIaS1XFIlCYKE+hNrDfw+FuPlMpuG0eE=";
  };

  pythonEnv = pkgs.python312.withPackages (
    pythonPackages: with pythonPackages; [
      pip
      pygobject3
    ]
  );

  runtimePackages = with pkgs; [
    pythonEnv
    cairo
    gdk-pixbuf
    glib
    gobject-introspection
    graphene
    gsettings-desktop-schemas
    gst_all_1.gstreamer.out
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gtk4
    libadwaita
    harfbuzz
    pango.out
    pipewire
    psmisc
    pulseaudio
    v4l-utils
  ];

  giTypelibPath = pkgs.lib.makeSearchPath "lib/girepository-1.0" runtimePackages;
  gstPluginPath = pkgs.lib.makeSearchPath "lib/gstreamer-1.0" runtimePackages;
  xdgDataDirs = pkgs.lib.makeSearchPath "share" runtimePackages;
  libraryPath = pkgs.lib.makeLibraryPath (
    with pkgs;
    [
      cairo
      glib
      gtk4
      libadwaita
      libglvnd
      libxcb
      stdenv.cc.cc
      zlib
    ]
  );

  runtimeEnvironment = ''
    export GI_TYPELIB_PATH="${giTypelibPath}''${GI_TYPELIB_PATH:+:''${GI_TYPELIB_PATH}}"
    export GST_PLUGIN_SYSTEM_PATH_1_0="${gstPluginPath}''${GST_PLUGIN_SYSTEM_PATH_1_0:+:''${GST_PLUGIN_SYSTEM_PATH_1_0}}"
    export LD_LIBRARY_PATH="${libraryPath}''${LD_LIBRARY_PATH:+:''${LD_LIBRARY_PATH}}"
    export XDG_DATA_DIRS="${xdgDataDirs}''${XDG_DATA_DIRS:+:''${XDG_DATA_DIRS}}"
  '';

  prepareSource = ''
    app_root="''${XDG_DATA_HOME:-$HOME/.local/share}/nvbroadcast"
    src="$app_root/nvidia-broadcast-linux-${sourceVersion}"
    venv="$app_root/.venv-${sourceVersion}"
    source_stamp="$src/.nix-source-version"

    mkdir -p "$app_root"

    if [ ! -f "$source_stamp" ] || [ "$(<"$source_stamp")" != "${sourceVersion}" ]; then
      rm -rf "$src"
      mkdir -p "$src"
      cp -R --no-preserve=mode,ownership "${nvidiaBroadcastLinuxSrc}/." "$src"
      chmod -R u+w "$src"
      printf '%s\n' "${sourceVersion}" > "$source_stamp"
    fi

    app_py="$src/src/nvbroadcast/app.py"
    if [ -f "$app_py" ]; then
      python3 - "$app_py" <<'PY'
    from pathlib import Path
    import sys

    path = Path(sys.argv[1])
    text = path.read_text()
    old = 'infer_h = b._MAX_INFER_HEIGHT if b else "?"'
    new = 'infer_h = getattr(b, "_MAX_INFER_HEIGHT", "?") if b else "?"'
    if old in text:
        path.write_text(text.replace(old, new))
    PY
    fi
  '';

  mkNVBroadcastLauncher =
    name: command:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = runtimePackages;
      text = ''
        set -euo pipefail

        ${runtimeEnvironment}
        ${prepareSource}

        if [ ! -x "$venv/bin/${command}" ]; then
          rm -rf "$venv"
          python3 -m venv "$venv" --system-site-packages
          "$venv/bin/pip" install --upgrade pip
          "$venv/bin/pip" install -e "$src"
        fi

        exec "$venv/bin/${command}" "$@"
      '';
    };

  nvbroadcast = mkNVBroadcastLauncher "nvbroadcast" "nvbroadcast";
  nvbroadcastVcam = mkNVBroadcastLauncher "nvbroadcast-vcam" "nvbroadcast-vcam";
  nvbroadcastInstallCuda = pkgs.writeShellApplication {
    name = "nvbroadcast-install-cuda";
    runtimeInputs = runtimePackages;
    text = ''
      set -euo pipefail

      ${runtimeEnvironment}
      ${prepareSource}

      if [ ! -x "$venv/bin/nvbroadcast" ]; then
        rm -rf "$venv"
        python3 -m venv "$venv" --system-site-packages
        "$venv/bin/pip" install --upgrade pip
        "$venv/bin/pip" install -e "$src"
      fi

      "$venv/bin/pip" install --upgrade -e "''${src}[cuda]"
      "$venv/bin/python" -c "import onnxruntime as ort; print(ort.get_available_providers())"
    '';
  };
  desktopItem = pkgs.makeDesktopItem {
    name = "nvbroadcast";
    desktopName = "NV Broadcast";
    exec = "nvbroadcast";
    categories = [
      "AudioVideo"
      "Video"
    ];
  };
in
{
  boot = {
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=10 card_label="NVbroadcast" exclusive_caps=1 max_buffers=4
    '';
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    kernelModules = [ "v4l2loopback" ];
  };

  environment.systemPackages = [
    nvbroadcast
    nvbroadcastVcam
    nvbroadcastInstallCuda
    desktopItem
  ];

  programs.nix-ld.libraries = [ pkgs.stdenv.cc.cc ];
}
