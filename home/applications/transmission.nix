{ pkgs, ... }:
let
  transmissionWayland = pkgs.symlinkJoin {
    name = "transmission-wayland";
    paths = [ pkgs.transmission_4-qt ];
    postBuild = ''
      rm $out/bin/transmission-qt
      cat > $out/bin/transmission-qt <<'EOF'
      #!${pkgs.runtimeShell}
      unset DISPLAY
      export QT_QPA_PLATFORM=wayland
      export QT_PLUGIN_PATH="${pkgs.qt5.qtwayland.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}:''${QT_PLUGIN_PATH:-}"

      exec ${pkgs.systemd}/bin/systemd-inhibit \
        --what=sleep:handle-lid-switch \
        --who=Transmission \
        --why="Transmission is running" \
        ${pkgs.transmission_4-qt}/bin/transmission-qt "$@"
      EOF
      chmod +x $out/bin/transmission-qt

      rm $out/share/applications/transmission-qt.desktop
      substitute ${pkgs.transmission_4-qt}/share/applications/transmission-qt.desktop $out/share/applications/transmission-qt.desktop \
        --replace-fail "Exec=transmission-qt %U" "Exec=$out/bin/transmission-qt %U" \
        --replace-fail "Exec=transmission-qt --minimized" "Exec=$out/bin/transmission-qt --minimized"
    '';
  };
in
{
  home.packages = [ transmissionWayland ];
}
