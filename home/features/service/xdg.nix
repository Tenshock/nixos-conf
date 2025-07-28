{
  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        # URLs
        "x-scheme-handler/http"  = [ "librewolf.desktop" ];
        "x-scheme-handler/https" = [ "librewolf.desktop" ];
        "text/html"              = [ "librewolf.desktop" ];
        "application/xhtml+xml"  = [ "librewolf.desktop" ];

        # PDF
        "application/pdf" = [ "librewolf.desktop" ];

        # Videos
        "video/*"       = [ "vlc.desktop" ];
        "application/vnd.rn-realmedia" = [ "vlc.desktop" ]; # .rm
      };
    };
  };
}

