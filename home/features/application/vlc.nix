{ pkgs, ... }:
let
  vlcWayland = pkgs.symlinkJoin {
    name = "vlc-wayland";
    paths = [ pkgs.vlc ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/vlc
      makeWrapper ${pkgs.vlc}/bin/vlc $out/bin/vlc \
        --unset DISPLAY \
        --set QT_QPA_PLATFORM "wayland;xcb" \
        --prefix QT_PLUGIN_PATH : "${pkgs.qt5.qtwayland.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}"

      rm $out/share/applications/vlc.desktop
      substitute ${pkgs.vlc}/share/applications/vlc.desktop $out/share/applications/vlc.desktop \
        --replace-fail "Exec=${pkgs.vlc}/bin/vlc" "Exec=$out/bin/vlc"
    '';
  };
in
{
  home.packages = [ vlcWayland ];
}
