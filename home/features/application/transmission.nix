{ pkgs, ... }:
let
  transmissionWayland = pkgs.symlinkJoin {
    name = "transmission-wayland";
    paths = [ pkgs.transmission_4-qt ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/transmission-qt
      makeWrapper ${pkgs.transmission_4-qt}/bin/transmission-qt $out/bin/transmission-qt \
        --unset DISPLAY \
        --set QT_QPA_PLATFORM "wayland" \
        --prefix QT_PLUGIN_PATH : "${pkgs.qt5.qtwayland.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}"

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
