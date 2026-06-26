{
  lib,
  pkgs,
  config,
  ...
}:
let
  browser = "zen.desktop";
  imageViewer = "org.gnome.Loupe.desktop";
  videoPlayer = "vlc.desktop";

  defaultsFor = desktopFile: mimeTypes: lib.genAttrs mimeTypes (_: [ desktopFile ]);

  webMimeTypes = [
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "text/html"
    "application/xhtml+xml"
  ];

  pdfMimeTypes = [
    "application/pdf"
  ];

  videoMimeTypes = [
    "video/x-matroska" # .mkv
    "video/mp4" # .mp4, .m4v
    "video/x-m4v" # .m4v
    "video/webm" # .webm
    "video/x-msvideo" # .avi
    "video/quicktime" # .mov
    "video/x-ms-wmv" # .wmv
    "video/mpeg" # .mpeg, .mpg
    "video/ogg" # .ogv
    "video/x-flv" # .flv
    "video/3gpp" # .3gp
    "video/3gpp2" # .3g2
    "video/mp2t" # .ts
    "application/vnd.rn-realmedia" # .rm
  ];

  imageMimeTypes = [
    "image/apng"
    "image/bmp"
    "image/gif"
    "image/jp2"
    "image/jpeg"
    "image/png"
    "image/qoi"
    "image/tiff"
    "image/vnd.microsoft.icon"
    "image/webp"
    "image/x-dds"
    "image/x-exr"
    "image/x-portable-anymap"
    "image/x-portable-bitmap"
    "image/x-portable-graymap"
    "image/x-portable-pixmap"
    "image/x-qoi"
    "image/x-tga"
    "image/x-win-bitmap"
    "image/x-xbitmap"
    "image/x-xpixmap"
    "image/svg+xml"
    "image/svg+xml-compressed"
    "image/avif"
    "image/heic"
    "image/jxl"
  ];

  defaultApplications =
    defaultsFor browser webMimeTypes
    // defaultsFor browser pdfMimeTypes
    // defaultsFor videoPlayer videoMimeTypes
    // defaultsFor imageViewer imageMimeTypes;
in
{
  xdg = {
    enable = true;

    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";

    mimeApps = lib.mkIf (!pkgs.stdenv.isDarwin) {
      enable = true;
      associations.added = defaultApplications;
      inherit defaultApplications;
    };
  };
}
