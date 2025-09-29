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
        "x-scheme-handler/http" = [ "librewolf.desktop" ];
        "x-scheme-handler/https" = [ "librewolf.desktop" ];
        "text/html" = [ "librewolf.desktop" ];
        "application/xhtml+xml" = [ "librewolf.desktop" ];

        # PDF
        "application/pdf" = [ "librewolf.desktop" ];

        # Videos
        "video/*" = [ "vlc.desktop" ];
        "application/vnd.rn-realmedia" = [ "vlc.desktop" ]; # .rm
      };
    };
  };
}

