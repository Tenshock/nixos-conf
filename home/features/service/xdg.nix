{lib, pkgs, config, ...}: {
  xdg = {
    enable = true;

    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";

    mimeApps = lib.mkIf (!pkgs.stdenv.isDarwin) {
      enable = true;
      defaultApplications = {
        # URLs
        "x-scheme-handler/http" = [ "zen.desktop" ];
        "x-scheme-handler/https" = [ "zen.desktop" ];
        "text/html" = [ "zen.desktop" ];
        "application/xhtml+xml" = [ "zen.desktop" ];

        # PDF
        "application/pdf" = [ "zen.desktop" ];

        # Videos
        "video/*" = [ "vlc.desktop" ];
        "application/vnd.rn-realmedia" = [ "vlc.desktop" ]; # .rm
      };
    };
  };
}

