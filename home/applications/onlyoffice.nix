{ pkgs, ... }:
let
  desktopFile = "onlyoffice-desktopeditors.desktop";
  wordDocumentMimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
in
{
  home.packages = with pkgs; [ onlyoffice-desktopeditors ];

  xdg.mimeApps = {
    associations.added.${wordDocumentMimeType} = [ desktopFile ];
    defaultApplications.${wordDocumentMimeType} = [ desktopFile ];
  };
}
